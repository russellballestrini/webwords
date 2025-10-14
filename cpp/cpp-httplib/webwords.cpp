/*
 * WebWords C++ implementation using cpp-httplib (header-only)
 * HTTP server on port 31337 that checks if keyword exists in target URL
 */

#include <iostream>
#include <string>
#include "httplib.h"

std::string fetchUrl(const std::string& url) {
    // Parse URL to extract host, port, path, and protocol
    size_t proto_end = url.find("://");
    if (proto_end == std::string::npos) return "";

    bool is_https = (url.substr(0, proto_end) == "https");
    std::string rest = url.substr(proto_end + 3);
    size_t slash = rest.find("/");

    std::string host_port = (slash != std::string::npos) ? rest.substr(0, slash) : rest;
    std::string path = (slash != std::string::npos) ? rest.substr(slash) : "/";

    std::string host;
    int port;
    size_t colon = host_port.find(":");
    if (colon != std::string::npos) {
        host = host_port.substr(0, colon);
        port = std::stoi(host_port.substr(colon + 1));
    } else {
        host = host_port;
        port = is_https ? 443 : 80;
    }

    httplib::Result res;
    if (is_https) {
        httplib::SSLClient cli(host.c_str(), port);
        cli.set_connection_timeout(0, 10000000); // 10 sec
        cli.set_read_timeout(10, 0);
        cli.enable_server_certificate_verification(false); // For simplicity
        res = cli.Get(path.c_str());
    } else {
        httplib::Client cli(host.c_str(), port);
        cli.set_connection_timeout(0, 10000000); // 10 sec
        cli.set_read_timeout(10, 0);
        res = cli.Get(path.c_str());
    }

    if (res && res->status == 200) {
        return res->body;
    }

    return "";
}

int main() {
    httplib::Server svr;

    svr.Get("/", [](const httplib::Request &req, httplib::Response &res) {
        std::string keyword = req.has_param("keyword") ? req.get_param_value("keyword") : "";
        std::string target = req.has_param("target") ? req.get_param_value("target") : "";

        std::string found = "false";

        if (!keyword.empty() && !target.empty()) {
            std::string body = fetchUrl(target);
            if (body.find(keyword) != std::string::npos) {
                found = "true";
            }

            std::cout << "found=" << found << ", keyword=" << keyword << ", uri=" << target << std::endl;
        }

        res.set_content(found, "text/plain");
    });

    std::cout << "listening on 0.0.0.0:31337" << std::endl;
    svr.listen("0.0.0.0", 31337);

    return 0;
}
