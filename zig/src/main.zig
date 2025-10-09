const std = @import("std");
const http = std.http;
const net = std.net;
const print = std.debug.print;
const ArrayList = std.ArrayList;

const HttpClient = struct {
    allocator: std.mem.Allocator,
    client: http.Client,

    fn init(allocator: std.mem.Allocator) HttpClient {
        return HttpClient{
            .allocator = allocator,
            .client = http.Client{ .allocator = allocator },
        };
    }

    fn deinit(self: *HttpClient) void {
        self.client.deinit();
    }

    fn fetchUrl(self: *HttpClient, url: []const u8) !?[]u8 {
        const uri = std.Uri.parse(url) catch return null;
        
        // Allocate buffer for server headers
        const server_header_buffer: []u8 = self.allocator.alloc(u8, 1024 * 8) catch return null;
        defer self.allocator.free(server_header_buffer);

        var req = self.client.open(.GET, uri, .{
            .server_header_buffer = server_header_buffer,
        }) catch return null;
        defer req.deinit();

        req.send() catch return null;
        req.finish() catch return null;
        req.wait() catch return null;

        if (req.response.status != .ok) return null;

        const body = req.reader().readAllAlloc(self.allocator, 1024 * 1024) catch return null;
        return body;
    }
};

fn parseQuery(allocator: std.mem.Allocator, query: []const u8) !std.StringHashMap([]const u8) {
    var params = std.StringHashMap([]const u8).init(allocator);
    
    var iter = std.mem.split(u8, query, "&");
    while (iter.next()) |pair| {
        var pair_iter = std.mem.split(u8, pair, "=");
        const key = pair_iter.next() orelse continue;
        const value = pair_iter.next() orelse "";
        try params.put(key, value);
    }
    
    return params;
}

fn handleRequest(allocator: std.mem.Allocator, request: []const u8) ![]const u8 {
    var lines = std.mem.split(u8, request, "\r\n");
    const request_line = lines.next() orelse {
        return try allocator.dupe(u8, "HTTP/1.1 400 Bad Request\r\n\r\n");
    };
    
    var parts = std.mem.split(u8, request_line, " ");
    const method = parts.next() orelse {
        return try allocator.dupe(u8, "HTTP/1.1 400 Bad Request\r\n\r\n");
    };
    const path_query = parts.next() orelse {
        return try allocator.dupe(u8, "HTTP/1.1 400 Bad Request\r\n\r\n");
    };
    
    if (!std.mem.eql(u8, method, "GET")) {
        return try allocator.dupe(u8, "HTTP/1.1 405 Method Not Allowed\r\n\r\n");
    }
    
    var path_parts = std.mem.split(u8, path_query, "?");
    const path = path_parts.next() orelse "/";
    const query = path_parts.next() orelse "";
    
    if (!std.mem.eql(u8, path, "/")) {
        return try allocator.dupe(u8, "HTTP/1.1 404 Not Found\r\n\r\n");
    }
    
    var params = parseQuery(allocator, query) catch {
        return try allocator.dupe(u8, "HTTP/1.1 500 Internal Server Error\r\n\r\n");
    };
    defer params.deinit();
    
    const keyword = params.get("keyword") orelse "";
    const target = params.get("target") orelse "";
    var found: []const u8 = "false";
    
    if (keyword.len > 0 and target.len > 0) {
        var client = HttpClient.init(allocator);
        defer client.deinit();
        
        if (client.fetchUrl(target)) |maybe_body| {
            if (maybe_body) |body| {
                defer allocator.free(body);
                if (std.mem.indexOf(u8, body, keyword) != null) {
                    found = "true";
                }
                print("found={s}, keyword={s}, uri={s}\n", .{ found, keyword, target });
            }
        } else |_| {}
    }
    
    const response = std.fmt.allocPrint(allocator, 
        "HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\nContent-Length: {d}\r\n\r\n{s}",
        .{ found.len, found }
    ) catch {
        return try allocator.dupe(u8, "HTTP/1.1 500 Internal Server Error\r\n\r\n");
    };
    
    return response;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    
    const address = try net.Address.resolveIp("0.0.0.0", 31337);
    var listener = try address.listen(.{ .reuse_address = true });
    defer listener.deinit();
    
    print("listening on 0.0.0.0:31337\n", .{});
    
    while (true) {
        const connection = listener.accept() catch continue;
        defer connection.stream.close();
        
        var buffer: [4096]u8 = undefined;
        const bytes_read = connection.stream.read(&buffer) catch continue;
        
        const response = handleRequest(allocator, buffer[0..bytes_read]) catch continue;
        defer allocator.free(response);
        
        connection.stream.writeAll(response) catch |err| {
            print("Failed to write response: {}\n", .{err});
        };
    }
}