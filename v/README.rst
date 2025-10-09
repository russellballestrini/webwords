WebWords - V Implementation
=========================

This directory contains the V implementation of the WebWords service using vweb framework with modern systems programming and memory safety.

Docker Overview
===============

Our Dockerfile uses a multi-stage build optimized for V compilation:

.. code-block:: dockerfile

   FROM thevlang/vlang:latest as builder
   
   WORKDIR /app
   COPY v.mod webwords.v ./
   RUN v -prod webwords.v
   
   FROM alpine:latest
   RUN apk add --no-cache ca-certificates
   COPY --from=builder /app/webwords /usr/local/bin/webwords
   
   EXPOSE 31337
   
   CMD ["webwords"]

**Multi-Stage Build Breakdown:**

1. **Builder Stage**: Official V language image with compiler and standard library
2. **Production Compilation**: ``v -prod`` creates optimized executable
3. **Zero Dependencies**: No external dependencies in v.mod file
4. **Runtime Stage**: Minimal Alpine Linux with CA certificates
5. **Single Binary**: Statically-linked executable with no runtime dependencies
6. **Fast Startup**: Compiled binary with minimal overhead

The build leverages V's ability to compile to efficient, self-contained executables with zero dependencies.

Understanding the Code
======================

This V implementation demonstrates modern systems programming with C-like performance, memory safety, and simple syntax.

Module Configuration (v.mod)
----------------------------

.. code-block:: v

   Module {
   	name: 'webwords'
   	description: 'WebWords in V'
   	version: '0.0.1'
   	license: 'MIT'
   	dependencies: []
   }

V module configuration:
- ``name: 'webwords'``: Module identifier
- ``description: 'WebWords in V'``: Human-readable description
- ``version: '0.0.1'``: Semantic version number
- ``license: 'MIT'``: Open source license
- ``dependencies: []``: Empty array - no external dependencies
- V's built-in standard library provides HTTP functionality

Main Application (webwords.v)
-----------------------------

**Imports and Struct Definition:**

.. code-block:: v

   import vweb
   import net.http
   
   struct App {
   	vweb.Context
   }

V imports and structure:
- ``import vweb``: V's built-in web framework
- ``import net.http``: HTTP client functionality
- ``struct App``: Application structure definition
- ``vweb.Context``: Embedded context for web functionality
- V structs support composition through embedding

**Main Function and Server Startup:**

.. code-block:: v

   fn main() {
   	println('listening on 0.0.0.0:31337')
   	vweb.run(&App{}, 31337)
   }

Application entry point:
1. ``fn main()``: Main function entry point
2. ``println('listening on 0.0.0.0:31337')``: Startup notification
3. ``vweb.run(&App{}, 31337)``: Start web server with app instance
4. ``&App{}``: Reference to new App struct instance
5. ``31337``: Port number for WebWords standard

**Route Handler with Attributes:**

.. code-block:: v

   @['/'; get]
   pub fn (mut app App) index() vweb.Result {
   	keyword := app.query['keyword'] or { '' }
   	target := app.query['target'] or { '' }
   	mut found := 'false'

Route definition and parameter extraction:
1. ``@['/'; get]``: V attribute syntax for HTTP GET route on root path
2. ``pub fn (mut app App) index()``: Public method with mutable receiver
3. ``vweb.Result``: Return type for web responses
4. ``app.query['keyword'] or { '' }``: Query parameter with default value
5. ``mut found := 'false'``: Mutable variable declaration

**HTTP Client and Error Handling:**

.. code-block:: v

   if keyword != '' && target != '' {
   	resp := http.get(target) or {
   		println('Error fetching ${target}: ${err}')
   		return app.text(found)
   	}

Request processing with V's error handling:
1. ``if keyword != '' && target != ''``: Validate non-empty parameters
2. ``resp := http.get(target) or { ... }``: HTTP GET with error handling
3. ``or { ... }``: V's error handling syntax (no exceptions)
4. ``println('Error fetching ${target}: ${err}')``: String interpolation with ${}
5. ``return app.text(found)``: Early return on HTTP error

**String Processing and Response:**

.. code-block:: v

   if resp.body.contains(keyword) {
   	found = 'true'
   }
   
   println('found=${found}, keyword=${keyword}, uri=${target}')

String search and logging:
1. ``resp.body.contains(keyword)``: Built-in string containment check
2. ``found = 'true'``: Mutate variable value
3. ``println('found=${found}, ...)'``: String interpolation for logging
4. V's string operations are memory-safe and efficient

**HTTP Response Generation:**

.. code-block:: v

   return app.text(found)

Response creation:
- ``app.text(found)``: Create plain text HTTP response
- Returns "true" or "false" based on keyword search result
- vweb framework handles HTTP status and headers automatically

Building and Running
====================

Step 1: Build the Docker image
------------------------------

.. code-block:: bash

   cd /home/fox/git/webwords/v
   docker build -t webwords-v .

V compiler will create optimized executable during build.

Step 2: Run the container
-------------------------

.. code-block:: bash

   docker run -d -p 31337:31337 --name test-v webwords-v

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

   docker logs test-v

Expected output:
- "listening on 0.0.0.0:31337" on startup
- "found=true, keyword=potato, uri=https://www.remarkbox.com" for requests

Step 5: Clean up
----------------

.. code-block:: bash

   docker stop test-v
   docker rm test-v

Common Issues
=============

V compilation errors
-------------------

If V compilation fails during Docker build:

.. code-block:: bash

   # Check V compiler version and syntax
   docker run -v $(pwd):/app -it thevlang/vlang:latest bash
   cd /app && v webwords.v

Common V compilation issues:
- Syntax errors (V is strict about syntax)
- Type mismatches or incorrect variable declarations
- Missing or incorrect function signatures

vweb framework issues
--------------------

If vweb server fails to start:

.. code-block:: bash

   # Check vweb-specific errors
   docker logs test-v | grep -i "vweb"

vweb troubleshooting:
- Port binding failures on 31337
- Incorrect route attribute syntax
- Missing or malformed App struct

HTTP client timeout issues
-------------------------

If external HTTP requests hang or timeout:

.. code-block:: bash

   # Check HTTP client behavior
   docker logs test-v | grep -i "error"

HTTP client configuration:
- V's http.get() has default timeout behavior
- Network connectivity issues to target URLs
- SSL/TLS certificate verification problems

Memory safety violations
-----------------------

If application crashes with memory errors:

.. code-block:: bash

   # Check for memory-related crashes
   docker logs test-v | grep -E "(panic|segfault)"

Memory safety in V:
- V prevents most memory safety issues at compile time
- Bounds checking for array/string access
- Automatic memory management without garbage collection

V language version compatibility
-------------------------------

If code fails to compile with newer V versions:

.. code-block:: bash

   # Check V version compatibility
   docker run -it thevlang/vlang:latest v version

Version compatibility:
- V language is still evolving rapidly
- Syntax changes between versions may break code
- Use specific V version tags for reproducible builds

Implementation Notes
===================

This V implementation demonstrates:
- **Systems Programming**: C-like performance with memory safety
- **Modern Syntax**: Clean, readable syntax similar to Go and Rust
- **Zero Dependencies**: Built-in web framework and HTTP client
- **Error Handling**: Explicit error handling without exceptions
- **Memory Safety**: Compile-time bounds checking and safety guarantees
- **Fast Compilation**: Near-instantaneous compilation times

The implementation showcases V's goals of combining the performance of C with the safety of Rust and the simplicity of Go. The vweb framework provides a clean, attribute-based routing system while the built-in HTTP client eliminates external dependencies. V's emphasis on simplicity and performance makes it well-suited for system services that require both speed and safety.