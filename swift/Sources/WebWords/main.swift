import Vapor
import AsyncHTTPClient
import NIOCore
import Foundation

var env = try Environment.detect()
try LoggingSystem.bootstrap(from: &env)
let app = Application(env)
defer { app.shutdown() }

// Create HTTP client for making requests
let httpClient = HTTPClient(eventLoopGroupProvider: .shared(app.eventLoopGroup))
defer {
    try? httpClient.syncShutdown()
}

app.get("/") { req -> String in
    let keyword = req.query[String.self, at: "keyword"] ?? ""
    let target = req.query[String.self, at: "target"] ?? ""
    
    if keyword.isEmpty || target.isEmpty {
        return "false"
    }
    
    guard URL(string: target) != nil else {
        return "false"
    }
    
    do {
        // Use AsyncHTTPClient for HTTP requests on Linux
        let request = HTTPClientRequest(url: target)
        let response: HTTPClientResponse = try await httpClient.execute(request, deadline: .now() + .seconds(30))
        
        var found = "false"
        
        let body = response.body
        var data = Data()
        for try await buffer in body {
            data.append(contentsOf: buffer.readableBytesView)
        }
        
        if let bodyString = String(data: data, encoding: .utf8) {
            if bodyString.contains(keyword) {
                found = "true"
            }
        }
        
        print("found=\(found), keyword=\(keyword), uri=\(target)")
        return found
    } catch {
        print("Error fetching \(target): \(error)")
        return "false"
    }
}

try app.run(.hostname("0.0.0.0", port: 31337))