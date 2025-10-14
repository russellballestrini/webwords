/*
 * WebWords C++ implementation using Boost.Beast
 * HTTP server on port 31337 that checks if keyword exists in target URL
 */

#include <boost/beast/core.hpp>
#include <boost/beast/http.hpp>
#include <boost/asio/connect.hpp>
#include <boost/asio/ip/tcp.hpp>
#include <iostream>
#include <string>
#include <thread>

namespace beast = boost::beast;
namespace http = beast::http;
namespace net = boost::asio;
using tcp = net::ip::tcp;

// URL parsing helper
struct ParsedUrl {
    std::string host;
    std::string port;
    std::string path;
};

ParsedUrl parseUrl(const std::string& url) {
    ParsedUrl result;
    size_t proto_end = url.find("://");
    if (proto_end == std::string::npos) return result;

    std::string rest = url.substr(proto_end + 3);
    size_t slash = rest.find("/");

    std::string host_port = (slash != std::string::npos) ? rest.substr(0, slash) : rest;
    result.path = (slash != std::string::npos) ? rest.substr(slash) : "/";

    size_t colon = host_port.find(":");
    if (colon != std::string::npos) {
        result.host = host_port.substr(0, colon);
        result.port = host_port.substr(colon + 1);
    } else {
        result.host = host_port;
        result.port = (url.find("https://") == 0) ? "443" : "80";
    }

    return result;
}

std::string fetchUrl(const std::string& url) {
    try {
        auto parsed = parseUrl(url);
        if (parsed.host.empty()) return "";

        net::io_context ioc;
        tcp::resolver resolver(ioc);
        beast::tcp_stream stream(ioc);

        auto const results = resolver.resolve(parsed.host, parsed.port);
        stream.connect(results);

        http::request<http::string_body> req{http::verb::get, parsed.path, 11};
        req.set(http::field::host, parsed.host);
        req.set(http::field::user_agent, "WebWords-Beast");

        http::write(stream, req);

        beast::flat_buffer buffer;
        http::response<http::string_body> res;
        http::read(stream, buffer, res);

        beast::error_code ec;
        stream.socket().shutdown(tcp::socket::shutdown_both, ec);

        return res.body();
    } catch (...) {
        return "";
    }
}

// HTTP server session
class Session : public std::enable_shared_from_this<Session> {
    tcp::socket socket_;
    beast::flat_buffer buffer_;
    http::request<http::string_body> request_;

public:
    explicit Session(tcp::socket socket) : socket_(std::move(socket)) {}

    void run() {
        doRead();
    }

private:
    void doRead() {
        auto self = shared_from_this();
        http::async_read(socket_, buffer_, request_,
            [self](beast::error_code ec, std::size_t) {
                if (!ec) self->handleRequest();
            });
    }

    void handleRequest() {
        // Parse query parameters
        std::string url(request_.target());
        std::string keyword, target;

        size_t query_start = url.find('?');
        if (query_start != std::string::npos) {
            std::string query = url.substr(query_start + 1);
            size_t pos = 0;
            while (pos < query.length()) {
                size_t eq = query.find('=', pos);
                size_t amp = query.find('&', pos);
                if (eq == std::string::npos) break;

                std::string key = query.substr(pos, eq - pos);
                std::string value = (amp != std::string::npos)
                    ? query.substr(eq + 1, amp - eq - 1)
                    : query.substr(eq + 1);

                if (key == "keyword") keyword = value;
                if (key == "target") target = value;

                pos = (amp != std::string::npos) ? amp + 1 : query.length();
            }
        }

        std::string found = "false";
        if (!keyword.empty() && !target.empty()) {
            std::string body = fetchUrl(target);
            if (body.find(keyword) != std::string::npos) {
                found = "true";
            }
            std::cout << "found=" << found << ", keyword=" << keyword << ", uri=" << target << std::endl;
        }

        http::response<http::string_body> res{http::status::ok, request_.version()};
        res.set(http::field::server, "WebWords-Beast");
        res.set(http::field::content_type, "text/plain");
        res.body() = found;
        res.prepare_payload();

        auto self = shared_from_this();
        http::async_write(socket_, res,
            [self](beast::error_code ec, std::size_t) {
                self->socket_.shutdown(tcp::socket::shutdown_send, ec);
            });
    }
};

// HTTP server listener
class Listener : public std::enable_shared_from_this<Listener> {
    net::io_context& ioc_;
    tcp::acceptor acceptor_;

public:
    Listener(net::io_context& ioc, tcp::endpoint endpoint)
        : ioc_(ioc), acceptor_(ioc) {
        beast::error_code ec;
        acceptor_.open(endpoint.protocol(), ec);
        acceptor_.set_option(net::socket_base::reuse_address(true), ec);
        acceptor_.bind(endpoint, ec);
        acceptor_.listen(net::socket_base::max_listen_connections, ec);
    }

    void run() {
        doAccept();
    }

private:
    void doAccept() {
        acceptor_.async_accept(
            [self = shared_from_this()](beast::error_code ec, tcp::socket socket) {
                if (!ec) {
                    std::make_shared<Session>(std::move(socket))->run();
                }
                self->doAccept();
            });
    }
};

int main() {
    try {
        auto const address = net::ip::make_address("0.0.0.0");
        auto const port = static_cast<unsigned short>(31337);

        net::io_context ioc{1};

        std::make_shared<Listener>(ioc, tcp::endpoint{address, port})->run();

        std::cout << "listening on 0.0.0.0:31337" << std::endl;

        ioc.run();
    } catch (std::exception const& e) {
        std::cerr << "Error: " << e.what() << std::endl;
        return 1;
    }

    return 0;
}
