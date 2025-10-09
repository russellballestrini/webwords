WebWords - Swift Implementation
===============================

This directory contains the Swift implementation of the WebWords service using Vapor framework with async/await patterns and Swift Package Manager.

Docker Overview
===============

Our Dockerfile uses a multi-stage build optimized for Swift compilation:

.. code-block:: dockerfile

   FROM swift:6.1.3 AS builder
   
   WORKDIR /app
   COPY Package.swift .
   COPY Sources ./Sources
   RUN swift build -c release
   
   FROM swift:6.1.3-jammy-slim
   RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*
   COPY --from=builder /app/.build/release/WebWords /usr/local/bin/webwords
   
   EXPOSE 31337
   
   CMD ["webwords", "serve", "--hostname", "0.0.0.0", "--port", "31337"]

**Multi-Stage Build Breakdown:**

1. **Builder Stage**: Full Swift 6.1.3 environment with compiler and Package Manager
2. **Package Resolution**: Swift Package Manager downloads and compiles dependencies
3. **Release Build**: ``swift build -c release`` creates optimized executable
4. **Runtime Stage**: Minimal Swift runtime (jammy-slim) with CA certificates
5. **Binary Deployment**: Single executable with all dependencies statically linked
6. **Vapor Command**: Uses Vapor's built-in serve command with configuration

The build leverages Swift Package Manager to handle dependencies and create a self-contained executable optimized for production deployment.

Understanding the Code
======================

This Swift implementation demonstrates modern Swift server-side development with async/await, strong typing, and protocol-oriented programming.

Package Configuration (Package.swift)
-------------------------------------

.. code-block:: swift

   // swift-tools-version:5.7
   import PackageDescription
   
   let package = Package(
       name: "WebWords",
       platforms: [
           .macOS(.v10_15)
       ],
       dependencies: [
           .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
           .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.9.0")
       ],
       targets: [
           .executableTarget(
               name: "WebWords",
               dependencies: [
                   .product(name: "Vapor", package: "vapor"),
                   .product(name: "AsyncHTTPClient", package: "async-http-client")
               ]
           )
       ]
   )

Swift Package Manager configuration:
- ``// swift-tools-version:5.7``: Minimum SPM version required
- ``Package(name: "WebWords", ...)``: Package definition with metadata
- ``platforms: [.macOS(.v10_15)]``: Platform requirements
- ``dependencies: [...]``: External package dependencies
- ``vapor.git, from: "4.0.0"``: Vapor web framework dependency
- ``async-http-client.git``: HTTP client for external requests
- ``.executableTarget(...)``: Executable target configuration

Main Application (Sources/WebWords/main.swift)
----------------------------------------------

**Module Imports:**

.. code-block:: swift

   import Vapor
   import AsyncHTTPClient
   import NIOCore
   import Foundation

Swift import statements:
- ``import Vapor``: Web framework for HTTP server and routing
- ``import AsyncHTTPClient``: HTTP client for external requests
- ``import NIOCore``: SwiftNIO networking primitives
- ``import Foundation``: Core Swift framework for data types and utilities

**Application Setup:**

.. code-block:: swift

   var env = try Environment.detect()
   try LoggingSystem.bootstrap(from: &env)
   let app = Application(env)
   defer { app.shutdown() }

Vapor application initialization:
1. ``var env = try Environment.detect()``: Auto-detect environment (dev/prod)
2. ``try LoggingSystem.bootstrap(from: &env)``: Initialize logging system
3. ``let app = Application(env)``: Create Vapor application instance
4. ``defer { app.shutdown() }``: Ensure cleanup on scope exit
5. Swift's ``try`` keyword for error handling

**HTTP Client Setup:**

.. code-block:: swift

   let httpClient = HTTPClient(eventLoopGroupProvider: .shared(app.eventLoopGroup))
   defer {
       try? httpClient.syncShutdown()
   }

AsyncHTTPClient configuration:
1. ``HTTPClient(eventLoopGroupProvider: .shared(...))``: HTTP client with shared event loop
2. ``.shared(app.eventLoopGroup)``: Use Vapor's event loop for efficiency
3. ``defer { try? httpClient.syncShutdown() }``: Ensure client cleanup
4. ``try?`` optional try - ignore errors during shutdown

**Async Request Handler:**

.. code-block:: swift

   func handleGet(req: Request) async throws -> String {
       let keyword = req.query[String.self, at: "keyword"] ?? ""
       let target = req.query[String.self, at: "target"] ?? ""

Handler function definition:
1. ``func handleGet(req: Request) async throws -> String``: Async function with error handling
2. ``req.query[String.self, at: "keyword"]``: Type-safe query parameter extraction
3. ``?? ""``: Nil-coalescing operator providing default value
4. Swift's strong typing with explicit type specification

**Input Validation:**

.. code-block:: swift

   if keyword.isEmpty || target.isEmpty {
       return "false"
   }
   
   guard let url = URL(string: target) else {
       return "false"
   }

Swift validation patterns:
1. ``if keyword.isEmpty || target.isEmpty``: Check for empty parameters
2. ``guard let url = URL(string: target) else``: Guard statement for URL validation
3. ``guard`` provides early return on failure
4. Optional binding with ``let url = URL(...)``

**Async HTTP Request:**

.. code-block:: swift

   do {
       let request = HTTPClientRequest(url: target)
       let response: HTTPClientResponse = try await httpClient.execute(request, deadline: .now() + .seconds(30))

Async HTTP client usage:
1. ``do { ... } catch``: Swift error handling block
2. ``HTTPClientRequest(url: target)``: Create HTTP request
3. ``try await httpClient.execute(...)``: Async HTTP execution with await
4. ``deadline: .now() + .seconds(30)``: 30-second timeout
5. Swift's async/await syntax for non-blocking operations

**Stream Processing:**

.. code-block:: swift

   var found = "false"
   
   let body = response.body
   var data = Data()
   for try await buffer in body {
       data.append(contentsOf: buffer.readableBytesView)
   }

Async stream processing:
1. ``var found = "false"``: Mutable variable declaration
2. ``let body = response.body``: Access response body stream
3. ``for try await buffer in body``: Async iteration over stream
4. ``data.append(contentsOf: buffer.readableBytesView)``: Accumulate data
5. Swift's async sequences for streaming data

**String Processing and Response:**

.. code-block:: swift

   if let bodyString = String(data: data, encoding: .utf8) {
       if bodyString.contains(keyword) {
           found = "true"
       }
   }
   
   print("found=\(found), keyword=\(keyword), uri=\(target)")
   return found

String handling and logging:
1. ``if let bodyString = String(data: data, encoding: .utf8)``: Optional binding for UTF-8 conversion
2. ``bodyString.contains(keyword)``: Swift string containment check
3. ``print("found=\(found), ...")``: String interpolation with \() syntax
4. ``return found``: Return response string

**Route Registration and Server Startup:**

.. code-block:: swift

   app.get("/", use: handleGet)
   
   try app.run()

Application configuration:
1. ``app.get("/", use: handleGet)``: Register route handler for GET /
2. ``try app.run()``: Start Vapor server with error handling
3. Vapor handles command-line arguments and server lifecycle

Building and Running
====================

Step 1: Build the Docker image
------------------------------

.. code-block:: bash

   cd /home/fox/git/webwords/swift
   docker build -t webwords-swift .

Swift Package Manager will download dependencies and compile Swift source during build.

Step 2: Run the container
-------------------------

.. code-block:: bash

   docker run -d -p 31337:31337 --name test-swift webwords-swift

Step 3: Test the service
------------------------

.. code-block:: bash

   # Test positive case (should return "true")
   curl "http://localhost:31337/?keyword=potato&target=https://www.remarkbox.com"

   # Test negative case (should return "false")
   curl "http://localhost:31337/?keyword=lemon&target=https://www.remarkbox.com"

Step 4: View logs
-----------------

.. code-block:: bash

   docker logs test-swift

Expected output:
- Vapor startup messages
- "found=true, keyword=potato, uri=https://www.remarkbox.com" for requests

Step 5: Clean up
----------------

.. code-block:: bash

   docker stop test-swift
   docker rm test-swift

Common Issues
=============

Swift Package Manager dependency resolution errors
-------------------------------------------------

If Swift Package Manager fails to resolve dependencies during build:

.. code-block:: bash

   # Check Swift Package Manager status
   docker run -v $(pwd):/app -it swift:6.1.3 bash
   cd /app && swift package resolve

Common SPM issues:
- Network connectivity problems downloading from GitHub
- Version conflicts between package dependencies
- Platform compatibility issues with Linux vs macOS

Swift compilation errors
-----------------------

If Swift compilation fails during build:

.. code-block:: bash

   # Check Swift compiler errors
   docker run -v $(pwd):/app -it swift:6.1.3 bash
   cd /app && swift build

Swift compilation issues:
- Type inference failures requiring explicit type annotations
- Async/await usage errors in older Swift versions
- Missing import statements for required frameworks

Vapor server startup errors
--------------------------

If Vapor application fails to start:

.. code-block:: bash

   # Check Vapor startup logs
   docker logs test-swift | grep -E "(ERROR|FATAL)"

Vapor startup issues:
- Port 31337 already in use by another process
- Missing environment configuration
- SSL/TLS certificate issues for HTTPS requests

AsyncHTTPClient configuration errors
-----------------------------------

If HTTP client fails to make requests:

.. code-block:: bash

   # Check HTTP client errors
   docker logs test-swift | grep -i "http"

HTTP client troubleshooting:
- Event loop group configuration problems
- Timeout issues with slow target websites
- SSL certificate verification failures

Memory management issues
-----------------------

If application has memory leaks or crashes:

.. code-block:: bash

   # Monitor memory usage
   docker stats test-swift

Swift memory management:
- Automatic Reference Counting (ARC) handles most memory
- Explicit cleanup with ``defer`` statements
- Event loop resource management in async code

Implementation Notes
===================

This Swift implementation demonstrates:
- **Modern Swift**: Async/await patterns with structured concurrency
- **Type Safety**: Strong typing with optional binding and guard statements
- **Memory Safety**: Automatic Reference Counting without garbage collection
- **Performance**: Compiled to native code with optimizations
- **Server-Side Swift**: Vapor framework for production web services
- **Protocol-Oriented Programming**: Swift's emphasis on protocols and composition

The implementation showcases Swift's evolution from iOS development to server-side programming. Vapor provides a mature, production-ready web framework while Swift's type safety and performance characteristics make it well-suited for backend services. The async/await syntax enables modern concurrent programming patterns, while Swift Package Manager provides dependency management comparable to other server-side ecosystems. Swift's unique combination of safety, performance, and expressiveness positions it as a compelling choice for server-side development beyond Apple's ecosystem.

   let keyword = req.query[String.self, at: "keyword"] ?? ""
   let target = req.query[String.self, at: "target"] ?? ""

This extracts **query parameters**:
- ``req.query[String.self, at: "keyword"]``: Gets parameter with type safety
- ``String.self`` is a **metatype** reference
- ``??`` is the **nil-coalescing operator** (like Kotlin's Elvis operator)
- Returns empty string if parameter is missing

.. code-block:: swift

   if keyword.isEmpty || target.isEmpty {
       return req.eventLoop.makeSucceededFuture("false")
   }

This handles missing parameters:
- ``isEmpty`` is a property on String
- ``||`` is the logical OR operator
- ``req.eventLoop.makeSucceededFuture()`` creates an immediately resolved future
- Early return pattern for validation

.. code-block:: swift

   guard let url = URL(string: target) else {
       return req.eventLoop.makeSucceededFuture("false")
   }

This validates the URL using **guard statement**:
- ``guard let`` is Swift's early-exit pattern
- ``URL(string: target)`` returns an optional URL
- If URL creation fails, execute the ``else`` block and return
- More readable than nested if statements

.. code-block:: swift

   let promise = req.eventLoop.makePromise(of: String.self)

This creates a **promise** for async operations:
- Promises allow manual control of async completion
- ``of: String.self`` specifies the promise will resolve to a String

.. code-block:: swift

   let task = URLSession.shared.dataTask(with: url) { data, response, error in

This creates a **network task**:
- ``URLSession.shared`` is the default URL session
- ``dataTask(with: url)`` creates an HTTP request
- Trailing closure syntax for the completion handler

.. code-block:: swift

   var found = "false"
   
   if let data = data,
      let body = String(data: data, encoding: .utf8),
      body.contains(keyword) {
       found = "true"
   }

This processes the response using **optional binding**:
- ``if let data = data`` unwraps the optional data
- ``let body = String(data: data, encoding: .utf8)`` converts data to string
- Multiple conditions can be chained with commas
- ``body.contains(keyword)`` checks for the keyword

.. code-block:: swift

   print("found=\(found), keyword=\(keyword), uri=\(target)")
   promise.succeed(found)

This logs and completes the promise:
- ``\(variable)`` is **string interpolation**
- ``promise.succeed(found)`` resolves the promise with our result

.. code-block:: swift

   task.resume()
   return promise.futureResult

This starts the network task:
- ``task.resume()`` begins the HTTP request
- ``promise.futureResult`` returns the future that will be resolved

.. code-block:: swift

   try app.configure()
   try app.run()

This starts the server:
- ``app.configure()`` applies additional configuration
- ``app.run()`` starts listening for requests

Understanding Swift Syntax
---------------------------

**Variables and Constants:**
.. code-block:: swift

   let constant = "cannot change"     // Immutable
   var variable = "can change"        // Mutable
   
   let inferred = 42                  // Type inferred as Int
   let explicit: String = "hello"     // Explicit type

**Optionals (Nullable Values):**
.. code-block:: swift

   var optional: String? = nil        // Can be nil
   var notOptional: String = "hello"  // Cannot be nil
   
   // Optional binding
   if let value = optional {
       print("Value is \(value)")
   }
   
   // Nil coalescing
   let result = optional ?? "default"

**Functions:**
.. code-block:: swift

   func greet(name: String) -> String {
       return "Hello, \(name)!"
   }
   
   // Single expression (implicit return)
   func add(_ a: Int, _ b: Int) -> Int { a + b }
   
   // Function with default parameter
   func connect(host: String = "localhost", port: Int = 8080) { }

**Closures (Lambdas):**
.. code-block:: swift

   // Full syntax
   let closure = { (name: String) -> String in
       return "Hello, \(name)!"
   }
   
   // Trailing closure syntax
   numbers.map { $0 * 2 }

Understanding Package.swift
---------------------------

The Package.swift file defines dependencies:

.. code-block:: swift

   // swift-tools-version:5.7
   import PackageDescription

   let package = Package(
       name: "WebWords",
       platforms: [.macOS(.v10_15)],
       dependencies: [
           .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0")
       ],
       targets: [
           .executableTarget(
               name: "WebWords",
               dependencies: [
                   .product(name: "Vapor", package: "vapor")
               ]
           )
       ]
   )

Key elements:
- **platforms**: Minimum OS versions
- **dependencies**: External packages from repositories
- **targets**: What gets built (executable, library, etc.)

Understanding the Dockerfile
-----------------------------

The Dockerfile builds Swift on Linux:

.. code-block:: dockerfile

   FROM swift:5.7 as builder

This uses the **official Swift image**:
- Contains Swift compiler and runtime for Linux

.. code-block:: dockerfile

   WORKDIR /app
   COPY Package.swift .
   COPY Sources ./Sources
   RUN swift build -c release

This builds the application:
- Swift Package Manager resolves dependencies
- ``-c release`` builds with optimizations

.. code-block:: dockerfile

   FROM ubuntu:22.04
   RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*
   COPY --from=builder /app/.build/release/WebWords /usr/local/bin/webwords

This creates the **runtime image**:
- Uses smaller Ubuntu base
- Copies only the compiled executable

.. code-block:: dockerfile

   EXPOSE 31337
   CMD ["webwords", "serve", "--hostname", "0.0.0.0", "--port", "31337"]

This configures the server:
- Vapor CLI arguments for host and port

Building and Running
--------------------

To build the Docker image:

.. code-block:: bash

   cd swift
   docker build -t webwords-swift .

To run the container:

.. code-block:: bash

   docker run -d -p 31337:31337 webwords-swift

To test it:

.. code-block:: bash

   curl "http://localhost:31337/?keyword=Example&target=http://example.com"

Running Without Docker (macOS)
-------------------------------

You can also run this locally with Swift:

.. code-block:: bash

   cd swift
   swift build            # Build the project
   swift run              # Build and run
   
   # Or run the executable directly
   .build/debug/WebWords serve --port 31337

Common Swift Patterns Used
---------------------------

1. **Optionals**: Safe handling of nullable values
2. **Guard Statements**: Early exit pattern for validation
3. **Protocol-Oriented Programming**: Composition over inheritance
4. **Value Types**: Structs and enums over classes
5. **Error Handling**: try/catch with typed errors
6. **Memory Safety**: Automatic reference counting (ARC)
7. **Functional Programming**: map, filter, reduce on collections

Swift Error Handling
---------------------

Swift uses typed errors instead of exceptions:

.. code-block:: swift

   enum NetworkError: Error {
       case invalidURL
       case requestFailed
       case invalidResponse
   }
   
   func fetchData(from url: String) throws -> String {
       guard let url = URL(string: url) else {
           throw NetworkError.invalidURL
       }
       
       // Network request code
       return "response"
   }
   
   // Usage with do/catch
   do {
       let data = try fetchData(from: "https://example.com")
       print(data)
   } catch NetworkError.invalidURL {
       print("Invalid URL provided")
   } catch {
       print("Other error: \(error)")
   }

Protocol-Oriented Programming
-----------------------------

Swift emphasizes protocols over classes:

.. code-block:: swift

   protocol HTTPClient {
       func get(_ url: String) async throws -> String
   }
   
   struct URLSessionClient: HTTPClient {
       func get(_ url: String) async throws -> String {
           guard let url = URL(string: url) else {
               throw NetworkError.invalidURL
           }
           
           let (data, _) = try await URLSession.shared.data(from: url)
           return String(data: data, encoding: .utf8) ?? ""
       }
   }
   
   struct WebWordsService {
       let httpClient: HTTPClient
       
       func checkKeyword(_ keyword: String, in target: String) async throws -> Bool {
           let body = try await httpClient.get(target)
           return body.contains(keyword)
       }
   }

Modern Swift with async/await
-----------------------------

Swift 5.5 introduced async/await (our example uses older callback style):

.. code-block:: swift

   // Modern async/await version
   app.get("/") { req async throws -> String in
       let keyword = req.query[String.self, at: "keyword"] ?? ""
       let target = req.query[String.self, at: "target"] ?? ""
       
       guard !keyword.isEmpty, !target.isEmpty else {
           return "false"
       }
       
       guard let url = URL(string: target) else {
           return "false"
       }
       
       do {
           let (data, _) = try await URLSession.shared.data(from: url)
           let body = String(data: data, encoding: .utf8) ?? ""
           let found = body.contains(keyword) ? "true" : "false"
           
           print("found=\(found), keyword=\(keyword), uri=\(target)")
           return found
       } catch {
           print("Error: \(error)")
           return "false"
       }
   }

Learning More
-------------

To learn Swift:
1. Start with Swift Playgrounds app (iPad/Mac)
2. Apple's Swift documentation: https://docs.swift.org/
3. Vapor framework guide: https://docs.vapor.codes/
4. Try iOS development with SwiftUI
5. Explore Swift on Server working group

iOS Development
---------------

Swift is primarily used for iOS development:

.. code-block:: swift

   import SwiftUI
   
   struct WebWordsView: View {
       @State private var keyword = ""
       @State private var target = ""
       @State private var result = ""
       
       var body: some View {
           VStack {
               TextField("Keyword", text: $keyword)
               TextField("Target URL", text: $target)
               Button("Check") {
                   Task {
                       result = await checkWebWords(keyword: keyword, target: target)
                   }
               }
               Text("Result: \(result)")
           }
           .padding()
       }
   }

Next Steps
----------

Try modifying this code to:
1. Convert to modern async/await syntax
2. Add comprehensive error handling with custom error types
3. Add input validation and URL sanitization
4. Add structured logging with SwiftLog
5. Add configuration via environment variables
6. Add health check and metrics endpoints
7. Add database integration with Fluent ORM
8. Add authentication and middleware
9. Add unit tests with XCTest
10. Deploy to cloud platforms or create an iOS companion app