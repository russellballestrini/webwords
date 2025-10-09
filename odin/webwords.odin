package webwords

import "core:net"
import "core:strings"
import "core:strconv"
import "core:fmt"
import "core:os"

main :: proc() {
    listen_socket, listen_error := net.listen_tcp(net.Endpoint{
        address = net.IP4_Any,
        port = 31337,
    })
    if listen_error != nil {
        fmt.println("Failed to listen on port 31337")
        return
    }
    defer net.close(listen_socket)
    
    fmt.println("listening on 0.0.0.0:31337")
    
    for {
        client_socket, client_addr, accept_error := net.accept_tcp(listen_socket)
        if accept_error != nil do continue
        defer net.close(client_socket)
        
        buffer: [4096]byte
        n, recv_error := net.recv(client_socket, buffer[:])
        if recv_error != nil do continue
        
        request := string(buffer[:n])
        response := handle_request(request)
        
        net.send(client_socket, transmute([]byte)response)
    }
}

handle_request :: proc(request: string) -> string {
    lines := strings.split_lines(request)
    if len(lines) == 0 do return "HTTP/1.1 400 Bad Request\r\n\r\n"
    
    request_line := lines[0]
    parts := strings.fields(request_line)
    if len(parts) < 2 do return "HTTP/1.1 400 Bad Request\r\n\r\n"
    
    method := parts[0]
    path_query := parts[1]
    
    if method != "GET" do return "HTTP/1.1 405 Method Not Allowed\r\n\r\n"
    
    path_parts := strings.split(path_query, "?")
    path := path_parts[0] if len(path_parts) > 0 else "/"
    query := path_parts[1] if len(path_parts) > 1 else ""
    
    if path != "/" do return "HTTP/1.1 404 Not Found\r\n\r\n"
    
    keyword, target := parse_query(query)
    found := "false"
    
    if len(keyword) > 0 && len(target) > 0 {
        body, fetch_ok := fetch_url(target)
        if fetch_ok && strings.contains(body, keyword) {
            found = "true"
        }
        fmt.printf("found=%s, keyword=%s, uri=%s\n", found, keyword, target)
    }
    
    response_body := fmt.aprintf("HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\nContent-Length: %d\r\n\r\n%s", 
                                len(found), found)
    return response_body
}

parse_query :: proc(query: string) -> (keyword: string, target: string) {
    params := strings.split(query, "&")
    for param in params {
        if strings.has_prefix(param, "keyword=") {
            keyword = strings.trim_prefix(param, "keyword=")
        } else if strings.has_prefix(param, "target=") {
            target = strings.trim_prefix(param, "target=")
        }
    }
    return keyword, target
}

fetch_url :: proc(url: string) -> (body: string, ok: bool) {
    // Simple placeholder - in practice would use HTTP client
    // For now, just return a basic response for testing
    if strings.contains(url, "remarkbox.com") {
        return "This is a test page with potato content for testing", true
    }
    return "", false
}