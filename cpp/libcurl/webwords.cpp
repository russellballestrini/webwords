#include <iostream>
#include <string>
#include <map>
#include <sstream>
#include <thread>
#include <chrono>
#include <regex>
#include <curl/curl.h>
#include <microhttpd.h>

struct MemoryStruct {
    char *memory;
    size_t size;
};

static size_t WriteMemoryCallback(void *contents, size_t size, size_t nmemb, struct MemoryStruct *userp) {
    size_t realsize = size * nmemb;
    char *ptr = (char*)realloc(userp->memory, userp->size + realsize + 1);
    if (!ptr) {
        printf("not enough memory (realloc returned NULL)\n");
        return 0;
    }

    userp->memory = ptr;
    memcpy(&(userp->memory[userp->size]), contents, realsize);
    userp->size += realsize;
    userp->memory[userp->size] = 0;

    return realsize;
}

std::map<std::string, std::string> parseQuery(const std::string& query) {
    std::map<std::string, std::string> result;
    std::istringstream queryStream(query);
    std::string pair;
    
    while (std::getline(queryStream, pair, '&')) {
        auto pos = pair.find('=');
        if (pos != std::string::npos) {
            result[pair.substr(0, pos)] = pair.substr(pos + 1);
        }
    }
    
    return result;
}

std::string fetchUrl(const std::string& url) {
    CURL *curl;
    CURLcode res;
    struct MemoryStruct chunk;
    
    chunk.memory = (char*)malloc(1);
    chunk.size = 0;
    
    curl = curl_easy_init();
    if (curl) {
        curl_easy_setopt(curl, CURLOPT_URL, url.c_str());
        curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, WriteMemoryCallback);
        curl_easy_setopt(curl, CURLOPT_WRITEDATA, (void *)&chunk);
        curl_easy_setopt(curl, CURLOPT_TIMEOUT, 10L);
        
        res = curl_easy_perform(curl);
        curl_easy_cleanup(curl);
        
        if (res != CURLE_OK) {
            free(chunk.memory);
            return "";
        }
    }
    
    std::string result(chunk.memory);
    free(chunk.memory);
    return result;
}

static enum MHD_Result answer_to_connection(void *cls, struct MHD_Connection *connection,
                                          const char *url, const char *method,
                                          const char *version, const char *upload_data,
                                          size_t *upload_data_size, void **con_cls) {
    const char *keyword = MHD_lookup_connection_value(connection, MHD_GET_ARGUMENT_KIND, "keyword");
    const char *target = MHD_lookup_connection_value(connection, MHD_GET_ARGUMENT_KIND, "target");
    
    std::string found = "false";
    
    if (keyword && target) {
        std::string body = fetchUrl(target);
        if (body.find(keyword) != std::string::npos) {
            found = "true";
        }
        
        std::cout << "found=" << found << ", keyword=" << keyword << ", uri=" << target << std::endl;
    }
    
    struct MHD_Response *response;
    enum MHD_Result ret;
    
    response = MHD_create_response_from_buffer(found.length(), (void*)found.c_str(), MHD_RESPMEM_MUST_COPY);
    ret = MHD_queue_response(connection, MHD_HTTP_OK, response);
    MHD_destroy_response(response);
    
    return ret;
}

int main() {
    struct MHD_Daemon *daemon;
    
    daemon = MHD_start_daemon(MHD_USE_INTERNAL_POLLING_THREAD, 31337, NULL, NULL,
                             &answer_to_connection, NULL, MHD_OPTION_END);
    if (NULL == daemon) return 1;
    
    std::cout << "listening on 0.0.0.0:31337" << std::endl;
    
    // Keep server running indefinitely
    while (true) {
        std::this_thread::sleep_for(std::chrono::seconds(1));
    }
    
    MHD_stop_daemon(daemon);
    return 0;
}