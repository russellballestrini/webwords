#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <curl/curl.h>
#include <ctype.h>

#define PORT 31337
#define BUFFER_SIZE 4096
#define MAX_URL_SIZE 2048
#define MAX_KEYWORD_SIZE 256

// Structure to hold response data from curl
struct MemoryStruct {
    char *memory;
    size_t size;
};

// Callback function for curl to write response data
static size_t WriteMemoryCallback(void *contents, size_t size, size_t nmemb, void *userp) {
    size_t realsize = size * nmemb;
    struct MemoryStruct *mem = (struct MemoryStruct *)userp;

    char *ptr = realloc(mem->memory, mem->size + realsize + 1);
    if (!ptr) {
        printf("Not enough memory (realloc returned NULL)\n");
        return 0;
    }

    mem->memory = ptr;
    memcpy(&(mem->memory[mem->size]), contents, realsize);
    mem->size += realsize;
    mem->memory[mem->size] = 0;

    return realsize;
}

// URL decode function
void url_decode(char *dst, const char *src) {
    char *p = dst;
    char code[3];
    
    while (*src) {
        if (*src == '%') {
            memcpy(code, src + 1, 2);
            code[2] = '\0';
            *p++ = (char)strtol(code, NULL, 16);
            src += 3;
        } else if (*src == '+') {
            *p++ = ' ';
            src++;
        } else {
            *p++ = *src++;
        }
    }
    *p = '\0';
}

// Parse query parameters from URL
void parse_query_params(const char *query, char *keyword, char *target) {
    char *query_copy = strdup(query);
    char *token = strtok(query_copy, "&");
    
    keyword[0] = '\0';
    target[0] = '\0';
    
    while (token != NULL) {
        if (strncmp(token, "keyword=", 8) == 0) {
            url_decode(keyword, token + 8);
        } else if (strncmp(token, "target=", 7) == 0) {
            url_decode(target, token + 7);
        }
        token = strtok(NULL, "&");
    }
    
    free(query_copy);
}

// Fetch URL content using libcurl
int fetch_url(const char *url, char **content) {
    CURL *curl_handle;
    CURLcode res;
    struct MemoryStruct chunk;

    chunk.memory = malloc(1);
    chunk.size = 0;

    curl_global_init(CURL_GLOBAL_DEFAULT);
    curl_handle = curl_easy_init();

    if (curl_handle) {
        curl_easy_setopt(curl_handle, CURLOPT_URL, url);
        curl_easy_setopt(curl_handle, CURLOPT_WRITEFUNCTION, WriteMemoryCallback);
        curl_easy_setopt(curl_handle, CURLOPT_WRITEDATA, (void *)&chunk);
        curl_easy_setopt(curl_handle, CURLOPT_USERAGENT, "webwords-c/1.0");
        curl_easy_setopt(curl_handle, CURLOPT_FOLLOWLOCATION, 1L);
        curl_easy_setopt(curl_handle, CURLOPT_TIMEOUT, 10L);

        res = curl_easy_perform(curl_handle);
        curl_easy_cleanup(curl_handle);
    }

    curl_global_cleanup();

    if (res != CURLE_OK) {
        free(chunk.memory);
        return 0;
    }

    *content = chunk.memory;
    return 1;
}

// Case-insensitive search for keyword in content
int search_keyword(const char *content, const char *keyword) {
    if (!content || !keyword) return 0;
    
    size_t content_len = strlen(content);
    size_t keyword_len = strlen(keyword);
    
    if (keyword_len == 0) return 0;
    
    for (size_t i = 0; i <= content_len - keyword_len; i++) {
        if (strncasecmp(content + i, keyword, keyword_len) == 0) {
            return 1;
        }
    }
    
    return 0;
}

// Send HTTP response
void send_response(int client_socket, const char *result) {
    char response[512];
    snprintf(response, sizeof(response),
        "HTTP/1.1 200 OK\r\n"
        "Content-Type: text/plain\r\n"
        "Content-Length: %zu\r\n"
        "Connection: close\r\n"
        "\r\n"
        "%s", strlen(result), result);
    
    send(client_socket, response, strlen(response), 0);
}

// Handle HTTP request
void handle_request(int client_socket) {
    char buffer[BUFFER_SIZE];
    char keyword[MAX_KEYWORD_SIZE];
    char target[MAX_URL_SIZE];
    char *content = NULL;
    const char *result;
    
    // Read HTTP request
    ssize_t bytes_received = recv(client_socket, buffer, BUFFER_SIZE - 1, 0);
    if (bytes_received <= 0) {
        close(client_socket);
        return;
    }
    
    buffer[bytes_received] = '\0';
    
    // Parse HTTP request line
    char *request_line = strtok(buffer, "\r\n");
    if (!request_line) {
        send_response(client_socket, "false");
        close(client_socket);
        return;
    }
    
    // Find query string
    char *query_start = strchr(request_line, '?');
    if (!query_start) {
        send_response(client_socket, "false");
        close(client_socket);
        return;
    }
    
    query_start++; // Skip the '?'
    
    // Find end of query string (space before HTTP version)
    char *query_end = strchr(query_start, ' ');
    if (query_end) {
        *query_end = '\0';
    }
    
    // Parse query parameters
    parse_query_params(query_start, keyword, target);
    
    // Check if we have both parameters
    if (strlen(keyword) == 0 || strlen(target) == 0) {
        send_response(client_socket, "false");
        close(client_socket);
        return;
    }
    
    // Fetch URL content
    if (fetch_url(target, &content)) {
        // Search for keyword
        if (search_keyword(content, keyword)) {
            result = "true";
        } else {
            result = "false";
        }
        free(content);
    } else {
        result = "false";
    }
    
    send_response(client_socket, result);
    close(client_socket);
}

int main() {
    int server_socket, client_socket;
    struct sockaddr_in server_addr, client_addr;
    socklen_t client_len = sizeof(client_addr);
    
    // Create socket
    server_socket = socket(AF_INET, SOCK_STREAM, 0);
    if (server_socket < 0) {
        perror("Socket creation failed");
        exit(1);
    }
    
    // Set socket options to reuse address
    int opt = 1;
    if (setsockopt(server_socket, SOL_SOCKET, SO_REUSEADDR, &opt, sizeof(opt)) < 0) {
        perror("setsockopt failed");
        exit(1);
    }
    
    // Configure server address
    memset(&server_addr, 0, sizeof(server_addr));
    server_addr.sin_family = AF_INET;
    server_addr.sin_addr.s_addr = INADDR_ANY;
    server_addr.sin_port = htons(PORT);
    
    // Bind socket
    if (bind(server_socket, (struct sockaddr*)&server_addr, sizeof(server_addr)) < 0) {
        perror("Bind failed");
        exit(1);
    }
    
    // Listen for connections
    if (listen(server_socket, 10) < 0) {
        perror("Listen failed");
        exit(1);
    }
    
    printf("WebWords C server listening on port %d\n", PORT);
    
    // Main server loop
    while (1) {
        client_socket = accept(server_socket, (struct sockaddr*)&client_addr, &client_len);
        if (client_socket < 0) {
            perror("Accept failed");
            continue;
        }
        
        handle_request(client_socket);
    }
    
    close(server_socket);
    return 0;
}