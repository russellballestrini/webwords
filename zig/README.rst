WebWords - Zig Implementation
=============================

This directory contains the Zig implementation of the WebWords service using manual HTTP server implementation with explicit memory management and systems programming patterns.

Docker Overview
===============

Our Dockerfile uses a multi-stage build with manual Zig installation:

.. code-block:: dockerfile

   FROM alpine:latest AS builder
   
   RUN apk add --no-cache curl tar xz && \
       curl -L https://ziglang.org/download/0.13.0/zig-linux-x86_64-0.13.0.tar.xz | tar -xJ && \
       mv zig-linux-x86_64-0.13.0 /opt/zig
   
   WORKDIR /app
   COPY . .
   RUN /opt/zig/zig build -Doptimize=ReleaseSafe
   
   FROM alpine:latest
   RUN apk add --no-cache ca-certificates
   COPY --from=builder /app/zig-out/bin/webwords /usr/local/bin/webwords
   
   EXPOSE 31337
   
   CMD ["webwords"]

**Multi-Stage Build Breakdown:**

1. **Builder Stage**: Alpine with manual Zig 0.13.0 installation from official releases
2. **Zig Installation**: Download and extract Zig compiler from ziglang.org
3. **Build Process**: ``zig build -Doptimize=ReleaseSafe`` creates optimized executable
4. **Runtime Stage**: Minimal Alpine with CA certificates only
5. **Binary Deployment**: Single statically-linked executable with no dependencies
6. **Release Safety**: Optimized build with safety checks enabled

The build demonstrates Zig's zero-dependency philosophy - the final executable requires no runtime libraries.

Understanding the Code
======================

This Zig implementation demonstrates systems programming with explicit memory management, manual HTTP protocol handling, and compile-time safety guarantees.

Build Configuration (build.zig)
-------------------------------

.. code-block:: zig

   const std = @import("std");
   
   pub fn build(b: *std.Build) void {
       const target = b.standardTargetOptions(.{});
       const optimize = b.standardOptimizeOption(.{});
   
       const exe = b.addExecutable(.{
           .name = "webwords",
           .root_source_file = b.path("src/main.zig"),
           .target = target,
           .optimize = optimize,
       });

Zig build system:
- ``const std = @import("std");``: Import Zig standard library
- ``pub fn build(b: *std.Build)``: Build function with pointer to build context
- ``b.standardTargetOptions(.{})``: Standard cross-compilation target options
- ``b.standardOptimizeOption(.{})``: Standard optimization level options
- ``.addExecutable(...)``: Define executable target configuration
- ``b.path("src/main.zig")``: Root source file path

Main Application (src/main.zig)
------------------------------

**Imports and Type Definitions:**

.. code-block:: zig

   const std = @import("std");
   const http = std.http;
   const net = std.net;
   const print = std.debug.print;
   const ArrayList = std.ArrayList;

Zig imports and aliases:
- ``const std = @import("std");``: Standard library import
- ``const http = std.http;``: HTTP client functionality
- ``const net = std.net;``: Networking primitives
- ``const print = std.debug.print;``: Debug printing function
- Type aliases for commonly used standard library types

**HTTP Client Structure:**

.. code-block:: zig

   const HttpClient = struct {
       allocator: std.mem.Allocator,
       client: http.Client,
   
       fn init(allocator: std.mem.Allocator) HttpClient {
           return HttpClient{
               .allocator = allocator,
               .client = http.Client{ .allocator = allocator },
           };
       }

Zig struct definition:
1. ``const HttpClient = struct { ... };``: Struct type definition
2. ``allocator: std.mem.Allocator``: Explicit allocator field
3. ``client: http.Client``: HTTP client instance
4. ``fn init(...) HttpClient``: Constructor function
5. Struct literal initialization with ``.field = value`` syntax

**Memory Management and Resource Cleanup:**

.. code-block:: zig

   fn deinit(self: *HttpClient) void {
       self.client.deinit();
   }
   
   fn fetchUrl(self: *HttpClient, url: []const u8) !?[]u8 {
       const uri = std.Uri.parse(url) catch return null;
       
       const server_header_buffer: []u8 = self.allocator.alloc(u8, 1024 * 8) catch return null;
       defer self.allocator.free(server_header_buffer);

Explicit resource management:
1. ``fn deinit(self: *HttpClient) void``: Cleanup function with mutable pointer
2. ``self.client.deinit();``: Explicit resource deallocation
3. ``!?[]u8``: Error union optional slice return type
4. ``catch return null``: Error handling with early return
5. ``defer self.allocator.free(...)``: Deferred cleanup execution

**HTTP Request Processing:**

.. code-block:: zig

   var req = self.client.open(.GET, uri, .{
       .server_header_buffer = server_header_buffer,
   }) catch return null;
   defer req.deinit();
   
   req.send() catch return null;
   req.finish() catch return null;
   req.wait() catch return null;

HTTP client operations:
1. ``self.client.open(.GET, uri, .{ ... })``: Create HTTP request
2. ``defer req.deinit();``: Ensure request cleanup
3. ``req.send() catch return null``: Send request with error handling
4. ``req.finish() catch return null``: Finalize request
5. ``req.wait() catch return null``: Wait for response
6. Explicit step-by-step HTTP protocol handling

**Query Parameter Parsing:**

.. code-block:: zig

   fn parseQuery(allocator: std.mem.Allocator, query: []const u8) !std.StringHashMap([]const u8) {
       var params = std.StringHashMap([]const u8).init(allocator);
       
       var iter = std.mem.split(u8, query, "&");
       while (iter.next()) |pair| {
           var pair_iter = std.mem.split(u8, pair, "=");
           const key = pair_iter.next() orelse continue;
           const value = pair_iter.next() orelse "";
           try params.put(key, value);
       }

Manual query parsing:
1. ``!std.StringHashMap([]const u8)``: Error union hash map return type
2. ``std.StringHashMap([]const u8).init(allocator)``: Hash map with explicit allocator
3. ``std.mem.split(u8, query, "&")``: Split string into iterator
4. ``while (iter.next()) |pair|``: Optional capture with while loop
5. ``orelse continue``: Handle missing values with control flow

**HTTP Request Handler:**

.. code-block:: zig

   fn handleRequest(allocator: std.mem.Allocator, request: []const u8) ![]const u8 {
       var lines = std.mem.split(u8, request, "\r\n");
       const request_line = lines.next() orelse {
           return try allocator.dupe(u8, "HTTP/1.1 400 Bad Request\r\n\r\n");
       };

Request processing:
1. ``![]const u8``: Error union slice return type
2. ``std.mem.split(u8, request, "\r\n")``: Split HTTP request into lines
3. ``orelse { return try ... }``: Error handling with block
4. ``allocator.dupe(u8, ...)``: Duplicate string with allocator
5. Manual HTTP protocol parsing

**TCP Server Loop:**

.. code-block:: zig

   pub fn main() !void {
       var gpa = std.heap.GeneralPurposeAllocator(.{}){};
       defer _ = gpa.deinit();
       const allocator = gpa.allocator();
       
       const address = try net.Address.resolveIp("0.0.0.0", 31337);
       var listener = try address.listen(.{ .reuse_address = true });

Main function and server setup:
1. ``pub fn main() !void``: Main function returning error union
2. ``std.heap.GeneralPurposeAllocator(.{}){}``: Create allocator instance
3. ``defer _ = gpa.deinit();``: Deferred allocator cleanup
4. ``net.Address.resolveIp("0.0.0.0", 31337)``: Create network address
5. ``address.listen(.{ .reuse_address = true })``: Create TCP listener

**Connection Handling:**

.. code-block:: zig

   while (true) {
       const connection = listener.accept() catch continue;
       defer connection.stream.close();
       
       var buffer: [4096]u8 = undefined;
       const bytes_read = connection.stream.read(&buffer) catch continue;
       
       const response = handleRequest(allocator, buffer[0..bytes_read]) catch continue;
       defer allocator.free(response);

Server event loop:
1. ``while (true)`` : Infinite server loop
2. ``listener.accept() catch continue``: Accept connections with error handling
3. ``defer connection.stream.close()``: Ensure connection cleanup
4. ``var buffer: [4096]u8 = undefined``: Stack-allocated buffer
5. ``buffer[0..bytes_read]``: Slice syntax for partial buffer
6. ``defer allocator.free(response)``: Deferred memory cleanup

Building and Running
====================

Step 1: Build the Docker image
------------------------------

.. code-block:: bash

   cd /home/fox/git/webwords/zig
   docker build -t webwords-zig .

Zig compiler will create optimized executable during build.

Step 2: Run the container
-------------------------

.. code-block:: bash

   docker run -d -p 31337:31337 --name test-zig webwords-zig

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

   docker logs test-zig

Expected output:
- "listening on 0.0.0.0:31337" on startup
- "found=true, keyword=potato, uri=https://www.remarkbox.com" for requests

Step 5: Clean up
----------------

.. code-block:: bash

   docker stop test-zig
   docker rm test-zig

Common Issues
=============

Zig compiler installation errors
-------------------------------

If Zig compiler installation fails during Docker build:

.. code-block:: bash

   # Check Zig installation manually
   docker run -v $(pwd):/app -it alpine:latest sh
   apk add curl tar xz
   curl -L https://ziglang.org/download/0.13.0/zig-linux-x86_64-0.13.0.tar.xz | tar -xJ

Common installation issues:
- Network connectivity problems downloading from ziglang.org
- Archive extraction errors with tar/xz tools
- Incorrect Zig version or architecture mismatch

Zig compilation errors
---------------------

If Zig compilation fails during build:

.. code-block:: bash

   # Check Zig compilation
   docker run -v $(pwd):/app -it alpine:latest sh
   /opt/zig/zig build -Doptimize=ReleaseSafe

Common Zig compilation issues:
- Memory management errors (allocation/deallocation mismatches)
- Type system errors with error unions and optionals
- Incorrect use of defer statements or resource cleanup

Memory allocation errors
-----------------------

If application crashes with allocation errors:

.. code-block:: bash

   # Check memory allocation logs
   docker logs test-zig | grep -E "(alloc|free|OutOfMemory)"

Memory management troubleshooting:
- GeneralPurposeAllocator detects double-free and use-after-free
- Ensure all allocations have corresponding deallocations
- Use ``defer`` statements for guaranteed cleanup

HTTP client configuration errors
-------------------------------

If HTTP requests fail or timeout:

.. code-block:: bash

   # Check HTTP client errors
   docker logs test-zig | grep -E "(HTTP|fetch|request)"

HTTP client issues:
- SSL/TLS certificate verification problems
- Network connectivity to target URLs
- Buffer size limitations for large responses

TCP server binding errors
------------------------

If TCP server fails to start:

.. code-block:: bash

   # Check server binding errors
   docker logs test-zig | grep -E "(bind|listen|address)"

Server binding troubleshooting:
- Port 31337 already in use by another process
- Address resolution failures
- Socket configuration problems

Implementation Notes
===================

This Zig implementation demonstrates:
- **Systems Programming**: Manual HTTP protocol implementation with explicit control
- **Memory Safety**: Compile-time safety guarantees with explicit allocation management
- **Zero Dependencies**: Self-contained executable with no runtime requirements
- **Performance**: Optimized native code generation with predictable behavior
- **Error Handling**: Explicit error unions with comprehensive error propagation
- **Resource Management**: RAII patterns with defer statements for cleanup

The implementation showcases Zig's unique position as a modern systems programming language that provides C-like control with modern safety features. The explicit memory management demonstrates Zig's philosophy of "no hidden control flow" - every allocation, deallocation, and error condition is visible in the code. The manual HTTP server implementation highlights Zig's suitability for low-level network programming while maintaining safety guarantees that prevent common systems programming errors like buffer overflows and use-after-free bugs.
- Excellent debugging and error handling capabilities

What is Manual Memory Management?
=================================

Memory management is how programs allocate and deallocate computer memory. There are two main approaches:

**Automatic Memory Management** (like JavaScript, Python):
- Language runtime automatically handles memory allocation/deallocation
- Garbage collector periodically cleans up unused memory
- Convenient but can cause unpredictable performance pauses
- Higher memory overhead due to tracking mechanisms

**Manual Memory Management** (like C, Zig):
- Programmer explicitly allocates and frees memory
- Complete control over when and how memory is used
- Predictable performance with no garbage collection pauses
- Lower memory overhead and faster execution
- Requires careful programming to avoid memory leaks and use-after-free bugs

Zig's approach to memory management:
- Explicit allocators that you pass to functions
- Compile-time detection of many memory safety issues
- Debug mode can detect memory leaks and double-free errors
- Standard library provides safe memory management patterns

Docker Overview
===============

Docker is a tool that packages applications into containers - think of containers as lightweight, portable virtual machines that include everything needed to run an application.

Why use Docker for Zig?
- **Environment Consistency**: Ensures the Zig compiler and dependencies work the same everywhere
- **Build Reproducibility**: Guarantees identical build environments across different machines
- **Dependency Isolation**: Prevents conflicts with other development tools
- **Easy Distribution**: Share exact development environment with other developers
- **Cross-Compilation**: Build for different architectures in consistent environment

Our Dockerfile Breakdown
=========================

Let's examine each line of our Dockerfile and understand what it does:

.. code-block:: dockerfile

   FROM alpine:latest AS builder

**Line 1 - Multi-Stage Build Setup**:
This starts a multi-stage Docker build using Alpine Linux as the build environment. Alpine is chosen because:
- Minimal size (only ~5MB base image)
- Fast package installation with apk
- Commonly used for building system software
- Good support for compiling native applications

.. code-block:: dockerfile

   RUN apk add --no-cache curl tar xz && \\
       curl -L https://ziglang.org/download/0.13.0/zig-linux-x86_64-0.13.0.tar.xz | tar -xJ && \\
       mv zig-linux-x86_64-0.13.0 /opt/zig

**Lines 3-5 - Installing Zig Compiler**:
- ``apk add``: Installs packages using Alpine's package manager
- ``curl``: Tool for downloading files from the internet
- ``tar``: Tool for extracting compressed archives
- ``xz``: Compression format used by Zig releases
- Downloads Zig 0.13.0 directly from official release
- Extracts to ``/opt/zig`` for system-wide availability

This approach ensures we get the exact Zig version we need, regardless of what's available in Alpine's package repository.

.. code-block:: dockerfile

   WORKDIR /app
   COPY . .
   RUN /opt/zig/zig build -Doptimize=ReleaseSafe

**Lines 7-9 - Building the Application**:
- ``WORKDIR /app``: Sets the working directory inside the container
- ``COPY . .``: Copies all source code from the host to the container
- ``zig build``: Zig's build system that reads ``build.zig``
- ``-Doptimize=ReleaseSafe``: Builds optimized binary with safety checks enabled

ReleaseSafe mode provides:
- Optimized performance (similar to release builds)
- Runtime safety checks for debugging
- Panic on undefined behavior instead of silent corruption

.. code-block:: dockerfile

   FROM alpine:latest
   RUN apk add --no-cache ca-certificates
   COPY --from=builder /app/zig-out/bin/webwords /usr/local/bin/webwords

**Lines 11-13 - Runtime Image**:
- Starts a fresh Alpine image for the final container
- ``ca-certificates``: SSL certificates for HTTPS requests
- ``COPY --from=builder``: Takes the compiled binary from the build stage
- ``/usr/local/bin/webwords``: Places binary in standard system path

This multi-stage approach results in a much smaller final image containing only the compiled binary and minimal runtime dependencies.

.. code-block:: dockerfile

   EXPOSE 31337
   CMD ["webwords"]

**Lines 15-16 - Container Configuration**:
- ``EXPOSE 31337``: Documents that the application uses port 31337
- ``CMD ["webwords"]``: Runs our compiled binary when the container starts

Understanding the Code
=======================

What is an HTTP Server?
-----------------------

An HTTP server is a program that waits for requests from web browsers and responds with information. Think of it like a specialized receptionist:

- **Client (Browser)**: Person asking for information
- **HTTP Request**: The question being asked ("Does this webpage contain the word 'potato'?")
- **Server (Our Program)**: Receptionist who processes requests and provides answers
- **HTTP Response**: The answer delivered back to the person

Our HTTP server listens on port 31337 and responds to requests like:
``http://localhost:31337/?keyword=potato&target=https://example.com``

Line-by-Line Code Explanation
-----------------------------

**Build Configuration (build.zig)**:

.. code-block:: zig

   const std = @import("std");

**Line 1 - Standard Library Import**:
- ``@import``: Zig's module import function
- ``std``: Zig's standard library containing core functionality
- Contains memory management, networking, file I/O, and other essential functions

.. code-block:: zig

   const exe = b.addExecutable(.{
       .name = "webwords",
       .root_source_file = b.path("src/main.zig"),
       .target = target,
       .optimize = optimize,
   });

**Lines 7-12 - Executable Configuration**:
- ``addExecutable``: Tells build system to create an executable program
- ``.name = "webwords"``: Name of the output binary
- ``.root_source_file``: Entry point of our program (main.zig)
- ``.target``: CPU architecture and operating system to compile for
- ``.optimize``: Optimization level (Debug, ReleaseSafe, ReleaseFast, ReleaseSmall)

**Main Application (src/main.zig)**:

.. code-block:: zig

   const std = @import("std");
   const http = std.http;
   const net = std.net;
   const print = std.debug.print;

**Lines 1-4 - Module Imports**:
- ``std``: Standard library root
- ``http``: HTTP client functionality for making web requests
- ``net``: Networking functions for TCP/IP communication
- ``print``: Debug printing function for console output

.. code-block:: zig

   const HttpClient = struct {
       allocator: std.mem.Allocator,
       client: http.Client,
       
       fn init(allocator: std.mem.Allocator) HttpClient {
           return HttpClient{
               .allocator = allocator,
               .client = http.Client{ .allocator = allocator },
           };
       }
   };

**Lines 7-16 - HTTP Client Structure**:
- ``struct``: Zig's way to define custom data types (like classes)
- ``allocator``: Memory allocator for dynamic memory management
- ``client``: HTTP client for making web requests
- ``init``: Constructor function that creates a new HttpClient instance
- ``.allocator = allocator``: Stores the allocator for later use

This structure encapsulates all HTTP client functionality in a clean, reusable way.

.. code-block:: zig

   fn fetchUrl(self: *HttpClient, url: []const u8) !?[]u8 {
       const uri = std.Uri.parse(url) catch return null;
       var req = self.client.open(.GET, uri, headers, .{}) catch return null;
       req.send(.{}) catch return null;
       const body = req.reader().readAllAlloc(self.allocator, 1024 * 1024) catch return null;
       return body;
   }

**Lines 22-38 - URL Fetching Function**:
- ``!?[]u8``: Return type meaning "error or optional byte array"
- ``[]const u8``: Zig's string type (array of constant bytes)
- ``std.Uri.parse()``: Converts string URL to structured URI object
- ``catch return null``: Error handling - return null if operation fails
- ``client.open()``: Opens HTTP connection to the URL
- ``req.send()``: Sends the HTTP GET request
- ``readAllAlloc()``: Reads response body, allocating memory as needed
- ``1024 * 1024``: Maximum 1MB response size limit

.. code-block:: zig

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

**Lines 42-54 - Query String Parsing**:
- ``StringHashMap``: Zig's hash table for key-value storage
- ``std.mem.split()``: Splits string by delimiter
- ``while (iter.next()) |pair|``: Iterates through each parameter pair
- ``orelse continue``: If key is missing, skip this pair
- ``orelse ""``: If value is missing, use empty string
- ``try params.put()``: Adds key-value pair to hash map

This function converts "keyword=potato&target=example.com" into a structured map.

.. code-block:: zig

   pub fn main() !void {
       var gpa = std.heap.GeneralPurposeAllocator(.{}){};
       defer _ = gpa.deinit();
       const allocator = gpa.allocator();
   }

**Lines 104-107 - Memory Management Setup**:
- ``GeneralPurposeAllocator``: Zig's standard memory allocator
- ``defer _ = gpa.deinit()``: Ensures cleanup happens when function exits
- ``allocator()``: Gets allocator interface for memory operations

The ``defer`` keyword ensures the allocator is properly cleaned up regardless of how the function exits.

.. code-block:: zig

   const address = net.Address.parseIp("0.0.0.0", 31337) catch unreachable;
   var listener = net.Address.listen(address, .{}) catch unreachable;
   defer listener.deinit();

**Lines 109-111 - Server Setup**:
- ``parseIp("0.0.0.0", 31337)``: Creates network address for all interfaces on port 31337
- ``listen()``: Starts listening for incoming connections
- ``catch unreachable``: These operations should never fail in normal circumstances
- ``defer listener.deinit()``: Ensures server socket is properly closed

.. code-block:: zig

   while (true) {
       const connection = listener.accept() catch continue;
       defer connection.stream.close();
       
       var buffer: [4096]u8 = undefined;
       const bytes_read = connection.stream.readAll(&buffer) catch continue;
   }

**Lines 115-121 - Request Processing Loop**:
- ``while (true)``: Infinite loop to handle requests continuously
- ``listener.accept()``: Waits for new client connection
- ``catch continue``: If accept fails, try again
- ``[4096]u8``: Stack-allocated buffer for request data
- ``readAll()``: Reads entire HTTP request into buffer

Key Programming Concepts
========================

Memory Allocators in Zig
-------------------------

Zig requires explicit memory management through allocators:

.. code-block:: zig

   // Create an allocator
   var gpa = std.heap.GeneralPurposeAllocator(.{}){};
   defer _ = gpa.deinit();
   const allocator = gpa.allocator();
   
   // Allocate memory
   const data = try allocator.alloc(u8, 100);
   defer allocator.free(data);  // Must free manually
   
   // Alternative: ArenaAllocator for batch cleanup
   var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
   defer arena.deinit();  // Frees all allocations at once

Allocator types:
- **GeneralPurposeAllocator**: General use, detects leaks and corruption
- **ArenaAllocator**: Batch allocation/deallocation
- **FixedBufferAllocator**: Pre-allocated buffer, no dynamic allocation
- **page_allocator**: Direct OS memory allocation

Error Handling
--------------

Zig uses explicit error handling without exceptions:

.. code-block:: zig

   // Functions that can fail return error unions
   fn divide(a: f32, b: f32) !f32 {
       if (b == 0) return error.DivisionByZero;
       return a / b;
   }
   
   // Handle errors explicitly
   const result = divide(10, 2) catch |err| switch (err) {
       error.DivisionByZero => {
           print("Cannot divide by zero!\\n");
           return;
       },
   };
   
   // Or propagate errors up
   const result2 = try divide(10, 2);  // Propagates error to caller

Error types:
- **Error unions**: ``!T`` means "error or T"
- **Explicit handling**: ``catch`` for handling, ``try`` for propagating
- **No hidden control flow**: Errors are visible in function signatures

Comptime (Compile-Time Execution)
----------------------------------

Zig can execute code at compile time for meta-programming:

.. code-block:: zig

   // Compile-time string formatting
   const message = comptime std.fmt.comptimePrint("Port: {}", .{31337});
   
   // Compile-time conditionals
   const is_debug = builtin.mode == .Debug;
   
   // Compile-time loops and data generation
   const squares = comptime blk: {
       var result: [10]u32 = undefined;
       for (&result, 0..) |*item, i| {
           item.* = i * i;
       }
       break :blk result;
   };

Benefits:
- **Zero runtime cost**: Computation happens at compile time
- **Type-safe meta-programming**: Errors caught at compile time
- **Code generation**: Generate optimized code based on compile-time information

Optionals and Null Safety
--------------------------

Zig prevents null pointer dereferences at compile time:

.. code-block:: zig

   // Optional types explicitly allow null
   var maybe_value: ?i32 = null;
   
   // Must check for null before use
   if (maybe_value) |value| {
       print("Value is: {}\\n", .{value});
   } else {
       print("Value is null\\n");
   }
   
   // Unwrap with default value
   const safe_value = maybe_value orelse 42;
   
   // Unwrap or return error
   const unwrapped = maybe_value orelse return error.ValueIsNull;

Safety features:
- **No null pointer dereferences**: Compile-time prevention
- **Explicit null handling**: Must handle null cases explicitly
- **Optional types**: ``?T`` for values that might be null

Building and Running (Complete Beginner Guide)
==============================================

Step 1: Open Terminal/Command Prompt
------------------------------------

**Windows**: 
- Press Windows key + R
- Type "cmd" and press Enter
- A black window appears - this is your command prompt

**Mac**:
- Press Cmd + Space
- Type "terminal" and press Enter  
- A terminal window opens

**Linux**:
- Press Ctrl + Alt + T
- Terminal window opens

Step 2: Navigate to the Code
----------------------------

Type the following command and press Enter:

.. code-block:: bash

   cd /home/fox/git/webwords/zig

This changes your current directory to where the Zig code is located. Think of it like navigating to a specific folder.

If you get "No such file or directory", the code might be in a different location. Ask where the webwords project is stored.

Step 3: Build with Docker
-------------------------

Type this command and press Enter:

.. code-block:: bash

   docker build -t webwords-zig .

**What this does**:
- ``docker build``: Tells Docker to create a container image
- ``-t webwords-zig``: Names the image "webwords-zig"  
- ``.``: Use the current directory (which contains our Dockerfile)

**What you'll see**:
- Docker downloads Alpine Linux base image
- Downloads and installs Zig compiler
- Compiles our Zig source code to a native binary
- Creates optimized runtime container

This may take 2-5 minutes the first time due to downloading Zig compiler.

Step 4: Run the Container
------------------------

Type this command:

.. code-block:: bash

   docker run -d -p 31337:31337 --name test-zig webwords-zig

**What this does**:
- ``docker run``: Starts a container from our image
- ``-d``: Run in background (detached mode)
- ``-p 31337:31337``: Connect port 31337 inside container to port 31337 on your computer
- ``--name test-zig``: Give the container a friendly name
- ``webwords-zig``: Use the image we just built

Step 5: Test the Zig HTTP Service
----------------------------------

**Test 1 - Positive Case** (should find "potato"):

.. code-block:: bash

   curl "http://localhost:31337/?keyword=potato&target=https://www.remarkbox.com"

Expected result: ``true``

**Test 2 - Negative Case** (should not find "lemon"):

.. code-block:: bash

   curl "http://localhost:31337/?keyword=lemon&target=https://www.remarkbox.com"

Expected result: ``false``

Step 6: View Server Logs
------------------------

To see any Zig output or error messages:

.. code-block:: bash

   docker logs test-zig

You should see: ``listening on 0.0.0.0:31337``

Step 7: Interactive Container Access (Optional)
-----------------------------------------------

To explore inside the running container:

.. code-block:: bash

   docker exec -it test-zig /bin/sh

This opens a shell inside the container where you can:
- Explore the file system
- Check the compiled binary with ``ls -la /usr/local/bin/``
- Exit with ``exit`` command

Step 8: Clean Up
----------------

When you're done testing:

.. code-block:: bash

   docker stop test-zig
   docker rm test-zig

This stops and removes the test container.

Understanding What the Program Does
===================================

When you visit ``http://localhost:31337/?keyword=potato&target=https://www.remarkbox.com``:

**Step 1**: Your browser sends an HTTP request to our Zig server
**Step 2**: The Zig server accepts the TCP connection
**Step 3**: The server reads the HTTP request data into a buffer
**Step 4**: Request parsing extracts "potato" and "https://www.remarkbox.com"
**Step 5**: The HTTP client makes a GET request to the target URL
**Step 6**: The response body is read into allocated memory
**Step 7**: String search determines if "potato" exists in the content
**Step 8**: The server responds with "true" or "false"
**Step 9**: Memory is properly cleaned up by the allocator

**Zig-Specific Features**:
- Compile-time safety checks prevent common programming errors
- Manual memory management for predictable performance
- Zero-cost abstractions with no hidden overhead
- Cross-platform networking with consistent behavior
- Explicit error handling without exceptions

What Happens When It Runs
=========================

**Systems-Level Execution**:
1. Docker starts our compiled native binary
2. Zig runtime initializes with minimal overhead
3. Memory allocator sets up heap management
4. Network socket binds to port 31337 on all interfaces
5. Server enters accept loop waiting for connections

**Request Processing Flow**:
1. TCP connection established from client
2. Raw HTTP bytes read into stack-allocated buffer
3. HTTP request parsed using manual string processing
4. Query parameters extracted and URL-decoded
5. HTTP client allocates memory for outgoing request
6. Target URL fetched with timeout protection
7. Response body processed using string search algorithms
8. Memory deallocated and TCP connection closed

**Performance Characteristics**:
- Direct memory access without garbage collection overhead
- Predictable latency with no pause times
- Minimal runtime dependencies (just libc)
- Optimized binary code with compile-time optimizations
- Manual resource management for precise control

Common Problems and Solutions
============================

Problem: "docker: command not found"
-----------------------------------

**Cause**: Docker is not installed on your system.

**Solution**: 
1. Visit https://docker.com/get-started
2. Download Docker Desktop for your operating system
3. Follow the installation instructions
4. Restart your computer
5. Try the docker command again

Problem: "Permission denied" when running Docker
-----------------------------------------------

**Cause**: Your user account doesn't have permission to use Docker.

**Linux Solution**:

.. code-block:: bash

   sudo usermod -aG docker $USER
   newgrp docker

**Windows/Mac Solution**: 
Make sure Docker Desktop is running and you're logged in.

Problem: "Port 31337 is already in use"
--------------------------------------

**Cause**: Another application or container is using port 31337.

**Solution 1** - Find and stop the conflicting process:

.. code-block:: bash

   docker ps | grep 31337
   docker stop <container-name>

**Solution 2** - Use a different port:

.. code-block:: bash

   docker run -d -p 32337:31337 --name test-zig webwords-zig
   curl "http://localhost:32337/?keyword=potato&target=https://www.remarkbox.com"

Problem: Zig Build Errors
-------------------------

**Symptom**: Build fails with compilation errors

**Common Issues**:

1. **Zig Version Mismatch**:
   - Ensure Dockerfile uses correct Zig version
   - Check that code is compatible with Zig 0.13.0

2. **Memory Management Errors**:
   - Verify all allocations have corresponding deallocations
   - Check for use-after-free or double-free issues

3. **Import Errors**:
   - Ensure all ``@import`` statements reference valid modules
   - Check that standard library functions exist in this Zig version

**Solution**: Check build logs for specific error messages:

.. code-block:: bash

   docker build -t webwords-zig . 2>&1 | grep -A 5 -B 5 error

Problem: Container starts but doesn't respond
--------------------------------------------

**Cause**: Server might have failed to bind to port or crashed during startup.

**Diagnosis**:

.. code-block:: bash

   docker logs test-zig

**Look for**: 
- "listening on 0.0.0.0:31337" (successful startup)
- Any Zig panic messages or error output
- Network binding errors

**Solution**: Common fixes include:
- Check for port conflicts with other services
- Verify container has necessary network permissions
- Restart container: ``docker restart test-zig``

Problem: Memory Allocation Errors
---------------------------------

**Symptoms**: Server crashes or returns errors under load

**Cause**: Memory allocation failures or leaks

**Diagnosis**:

.. code-block:: bash

   # Run with debug allocator in development
   # Modify Dockerfile to use -Doptimize=Debug for better error messages

**Solutions**:
- Monitor memory usage with ``docker stats test-zig``
- Check for memory leaks in allocator debug output
- Reduce maximum response size limits if needed
- Use ArenaAllocator for request-scoped allocations

Systems Programming Concepts
============================

What Makes Zig Special for Systems Programming?
-----------------------------------------------

**Traditional High-Level Languages** (Python, JavaScript):
- Automatic memory management with garbage collection
- Hidden performance costs and unpredictable pauses
- Large runtime dependencies and overhead
- Limited control over hardware resources

**Traditional Systems Languages** (C, C++):
- Manual memory management with high risk of bugs
- Complex syntax and many foot-guns
- Undefined behavior can cause security vulnerabilities
- Legacy design decisions and compatibility burden

**Zig's Approach**:
- Manual memory management with compile-time safety
- Simple, consistent syntax without hidden costs
- Explicit error handling without exceptions
- Modern language design with lessons learned from C/C++

**Example Comparison**:

C Code (unsafe):
.. code-block:: c

   char* buffer = malloc(100);  // Can return NULL
   strcpy(buffer, source);      // Buffer overflow possible
   // Forget to call free() -> memory leak

Zig Code (safe):
.. code-block:: zig

   const buffer = try allocator.alloc(u8, 100);  // Explicit error handling
   defer allocator.free(buffer);                 // Guaranteed cleanup
   @memcpy(buffer[0..source.len], source);       // Bounds checking

Performance Characteristics
---------------------------

Zig provides predictable performance through:

**Compile-Time Optimization**:
- Dead code elimination removes unused functions
- Constant folding evaluates expressions at compile time
- Inlining eliminates function call overhead
- Loop unrolling and vectorization optimizations

**Runtime Efficiency**:
- No garbage collection pauses or overhead
- Direct system calls without wrapper layers
- Optimal memory layout with manual control
- Zero-cost abstractions that compile to minimal assembly

**Memory Management**:
- Explicit allocator interfaces for memory tracking
- Stack allocation for short-lived data
- Custom allocators for specific use patterns
- Memory pool allocation for frequent allocations

**Benchmarking Example**:

.. code-block:: zig

   const std = @import("std");
   const Timer = std.time.Timer;
   
   // Measure function execution time
   var timer = try Timer.start();
   const result = someFunction();
   const elapsed = timer.read();
   std.debug.print("Function took {} nanoseconds\\n", .{elapsed});

Cross-Platform Development
--------------------------

Zig excels at cross-platform systems programming:

**Compilation Targets**:
- x86_64-linux, x86_64-windows, x86_64-macos
- aarch64-linux, aarch64-macos (Apple Silicon)
- arm-linux (Raspberry Pi and embedded)
- wasm32-wasi (WebAssembly)
- Many embedded targets (AVR, ARM Cortex-M)

**Cross-Compilation Example**:

.. code-block:: bash

   # Build for different targets from any platform
   zig build -Dtarget=x86_64-windows
   zig build -Dtarget=aarch64-macos
   zig build -Dtarget=arm-linux-gnueabihf

**Platform Abstraction**:

.. code-block:: zig

   const builtin = @import("builtin");
   
   // Compile-time platform detection
   const is_windows = builtin.os.tag == .windows;
   const is_linux = builtin.os.tag == .linux;
   
   // Platform-specific code
   const path_separator = if (is_windows) "\\\\" else "/";

Debugging and Profiling
-----------------------

Zig provides excellent debugging capabilities:

**Compile-Time Debugging**:
.. code-block:: zig

   // Print during compilation
   @compileLog("Compiling with target:", @import("builtin").target);
   
   // Compile-time assertions
   comptime {
       if (@sizeOf(usize) != 8) {
           @compileError("This code requires 64-bit platform");
       }
   }

**Runtime Debugging**:
.. code-block:: zig

   const std = @import("std");
   
   // Debug prints
   std.debug.print("Variable value: {}\\n", .{variable});
   
   // Assertions
   std.debug.assert(value > 0);
   
   // Panic with message
   if (error_condition) {
       std.debug.panic("Something went wrong: {}", .{details});
   }

**Memory Debugging**:
.. code-block:: zig

   // Enable memory safety checks in debug builds
   var gpa = std.heap.GeneralPurposeAllocator(.{
       .safety = true,          // Enable safety checks
       .verbose_log = true,     // Log allocations
   }){};

Further Learning
===============

Next Steps with Zig and Systems Programming
-------------------------------------------

1. **Master Zig Fundamentals**:
   - Memory allocators and manual memory management
   - Error handling with error unions and optionals
   - Compile-time programming with comptime
   - Zig's type system and struct-based OOP

2. **Systems Programming Concepts**:
   - Operating system interfaces and system calls
   - Network programming with sockets and protocols
   - File I/O and filesystem operations
   - Concurrent programming with threads and async

3. **Advanced Zig Features**:
   - Custom allocators for specialized use cases
   - Inline assembly for hardware-specific code
   - C interoperability for existing library integration
   - Cross-compilation for embedded systems

4. **Performance Engineering**:
   - Profiling and benchmarking techniques
   - Memory layout optimization
   - Cache-friendly data structures
   - SIMD vectorization for numeric computing

Recommended Resources
--------------------

- **Official Zig Documentation**: https://ziglang.org/documentation/
- **Zig Learn**: Interactive tutorials and examples
- **Zig Standard Library**: Source code reading for best practices
- **ziglings**: Zig learning exercises from beginner to advanced
- **Zig Community**: Discord server and GitHub discussions
- **Andrew Kelley's Talks**: Creator's presentations on Zig design

Systems Programming Applications
-------------------------------

- **Operating Systems**: Kernels, device drivers, system services
- **Game Development**: Engines, real-time graphics, physics simulation
- **Embedded Systems**: Microcontrollers, IoT devices, robotics
- **Network Infrastructure**: Routers, switches, load balancers
- **Database Systems**: Storage engines, query processors, caching layers
- **Cryptocurrency**: Blockchain nodes, consensus algorithms, wallets

This implementation demonstrates how Zig's systems programming capabilities can be applied to web services, showing the bridge between low-level performance optimization and high-level application development. The combination of safety, performance, and simplicity makes Zig an excellent choice for modern systems programming projects.