WebWords - Nim Implementation
============================

This directory contains the Nim implementation of the WebWords service using Jester web framework with systems programming efficiency and memory safety.

Docker Overview
===============

Our Dockerfile uses a multi-stage build optimized for Nim compilation:

.. code-block:: dockerfile

   FROM nimlang/nim:2.0.2-alpine as builder
   
   WORKDIR /app
   COPY webwords.nimble .
   RUN nimble install -y --depsOnly
   
   COPY src ./src
   RUN nimble build -y -d:ssl
   
   FROM alpine:latest
   RUN apk add --no-cache ca-certificates
   COPY --from=builder /app/webwords /usr/local/bin/webwords
   
   EXPOSE 31337
   
   CMD ["webwords"]

**Multi-Stage Build Breakdown:**

1. **Builder Stage**: Official Nim 2.0.2 Alpine image with compiler and toolchain
2. **Dependency Installation**: ``nimble install --depsOnly`` downloads and compiles dependencies
3. **SSL Compilation**: ``-d:ssl`` flag enables SSL/HTTPS support
4. **Runtime Stage**: Minimal Alpine Linux with CA certificates
5. **Binary Deployment**: Single statically-linked executable
6. **Production Runtime**: No Nim compiler or build tools in final image

The build leverages Nim's ability to compile to efficient native code, resulting in a small, fast executable.

Understanding the Code
======================

This Nim implementation demonstrates systems programming with modern syntax, compile-time optimizations, and efficient memory management.

Project Configuration (webwords.nimble)
---------------------------------------

.. code-block:: nim

   # Package
   version       = "0.1.0"
   author        = "WebWords"
   description   = "A minimal web app in Nim"
   license       = "MIT"
   srcDir        = "src"
   bin           = @["webwords"]
   
   # Dependencies
   requires "nim >= 1.6.0"
   requires "jester"

Nimble package configuration:
- ``version``, ``author``, ``description``: Package metadata
- ``license = "MIT"``: Open source license
- ``srcDir = "src"``: Source code directory
- ``bin = @["webwords"]``: Executable name (@ denotes array literal)
- ``requires "nim >= 1.6.0"``: Minimum Nim compiler version
- ``requires "jester"``: Web framework dependency

Main Application (src/webwords.nim)
----------------------------------

**Module Imports:**

.. code-block:: nim

   import jester
   import httpclient
   import strutils

Nim module imports:
- ``import jester``: Web framework for HTTP server and routing
- ``import httpclient``: HTTP client library for external requests
- ``import strutils``: String utilities for text processing
- Nim imports are compile-time resolved for zero runtime overhead

**Jester Configuration:**

.. code-block:: nim

   settings:
     port = Port(31337)
     bindAddr = "0.0.0.0"
     numThreads = 1

Jester server settings:
1. ``port = Port(31337)``: WebWords standard port with type conversion
2. ``bindAddr = "0.0.0.0"``: Listen on all interfaces (Docker requirement)
3. ``numThreads = 1``: Single-threaded to avoid segmentation faults
4. Settings block configures Jester framework behavior

**HTTP Client Function:**

.. code-block:: nim

   proc fetchUrl(url: string): string =
     try:
       let client = newHttpClient()
       client.timeout = 10000
       let response = client.getContent(url)
       client.close()
       return response
     except Exception as e:
       echo "HTTP error: " & e.msg
       return ""

Nim procedure definition:
1. ``proc fetchUrl(url: string): string =``: Procedure with typed parameters and return
2. ``try:`` / ``except Exception as e:``: Exception handling
3. ``let client = newHttpClient()``: Immutable variable declaration
4. ``client.timeout = 10000``: 10-second timeout (milliseconds)
5. ``let response = client.getContent(url)``: HTTP GET request
6. ``client.close()``: Explicit resource cleanup
7. ``return response``: Early return on success
8. ``echo "HTTP error: " & e.msg``: String concatenation with & operator

**HTTP Route Definition:**

.. code-block:: nim

   routes:
     get "/":
       let keyword = request.params.getOrDefault("keyword", "")
       let target = request.params.getOrDefault("target", "")
       var found = "false"

Jester routing DSL:
1. ``routes:``: Jester macro for defining HTTP routes
2. ``get "/"``: HTTP GET handler for root path
3. ``let keyword = request.params.getOrDefault(...)``: Extract query parameter
4. ``getOrDefault("keyword", "")``: Get parameter with default value
5. ``var found = "false"``: Mutable variable declaration

**Request Processing Logic:**

.. code-block:: nim

   if keyword.len > 0 and target.len > 0:
     let body = fetchUrl(target)
     if keyword in body:
       found = "true"
     
     echo "found=" & found & ", keyword=" & keyword & ", uri=" & target

Processing logic:
1. ``if keyword.len > 0 and target.len > 0:``: Check parameter lengths
2. ``let body = fetchUrl(target)``: Call HTTP client function
3. ``if keyword in body:``: String containment check (``in`` operator)
4. ``found = "true"``: Mutate variable state
5. ``echo "found=" & ...``: Debug logging with string concatenation

**Response and Application Entry:**

.. code-block:: nim

   resp found

   when isMainModule:
     echo "listening on 0.0.0.0:31337"
     runForever()

Response and startup:
1. ``resp found``: Jester macro to send HTTP response
2. ``when isMainModule:``: Compile-time conditional (only when main module)
3. ``echo "listening on 0.0.0.0:31337"``: Startup notification
4. ``runForever()``: Start Jester event loop indefinitely

Building and Running
====================

Step 1: Build the Docker image
------------------------------

.. code-block:: bash

   cd /home/fox/git/webwords/nim
   docker build -t webwords-nim .

Nimble will download dependencies and compile Nim source during build.

Step 2: Run the container
-------------------------

.. code-block:: bash

   docker run -d -p 31337:31337 --name test-nim webwords-nim

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

   docker logs test-nim

Expected output:
- "listening on 0.0.0.0:31337" on startup
- "found=true, keyword=potato, uri=https://www.remarkbox.com" for requests

Step 5: Clean up
----------------

.. code-block:: bash

   docker stop test-nim
   docker rm test-nim

Common Issues
=============

Nim compilation errors
---------------------

If Nim compilation fails during Docker build:

.. code-block:: bash

   # Check Nim compiler version and syntax
   docker run -v $(pwd):/app -it nimlang/nim:2.0.2-alpine bash
   cd /app && nim c src/webwords.nim

Common Nim compilation issues:
- Indentation errors (Nim is indentation-sensitive like Python)
- Type mismatches between procedure signatures and usage
- Missing SSL support flag (``-d:ssl``) for HTTPS requests

Nimble dependency resolution errors
---------------------------------

If Nimble fails to install dependencies:

.. code-block:: bash

   # Check Nimble package installation
   docker run -v $(pwd):/app -it nimlang/nim:2.0.2-alpine bash
   cd /app && nimble install -y jester

Nimble troubleshooting:
- Network connectivity problems downloading packages
- Version conflicts between package dependencies
- Missing system dependencies for native code compilation

Threading and segmentation faults
--------------------------------

If application crashes with segmentation fault:

.. code-block:: bash

   # Check threading configuration
   docker logs test-nim | grep -i "segmentation"

Threading issues:
- Jester's multi-threading can cause segfaults in some environments
- Solution: Set ``numThreads = 1`` in Jester settings
- Trade-off: Single-threaded but stable execution

SSL/HTTPS support issues
-----------------------

If HTTPS requests fail:

.. code-block:: bash

   # Check SSL compilation flag
   docker run -v $(pwd):/app -it nimlang/nim:2.0.2-alpine bash
   cd /app && nim c -d:ssl src/webwords.nim

SSL support requirements:
- Must compile with ``-d:ssl`` flag
- Requires OpenSSL development libraries
- Alpine image includes necessary SSL support

Memory management issues
-----------------------

If application has memory leaks or crashes:

.. code-block:: bash

   # Check memory usage and cleanup
   docker stats test-nim

Memory management best practices:
- Explicitly close HTTP clients with ``client.close()``
- Use ``let`` for immutable variables when possible
- Nim's garbage collector handles most memory automatically

Implementation Notes
===================

This Nim implementation demonstrates:
- **Systems Programming**: Compiled to efficient native code with minimal runtime
- **Memory Safety**: Garbage collection with manual resource management options
- **Modern Syntax**: Python-like syntax with static typing and compile-time checks
- **Zero-Cost Abstractions**: High-level constructs compile to efficient machine code
- **Metaprogramming**: Jester's routing DSL uses Nim's powerful macro system
- **Performance**: Native compilation produces fast, lightweight executables

The implementation showcases Nim's unique position as a systems programming language with high-level features. The Jester framework provides elegant web development capabilities while maintaining the performance characteristics of compiled code. Nim's emphasis on efficiency and safety makes it well-suited for services that require both developer productivity and runtime performance.