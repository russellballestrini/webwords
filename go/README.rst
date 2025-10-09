WebWords - Go Implementation
=============================

This directory contains the Go implementation of the WebWords service using Go's standard library net/http package for both server and client functionality.

Docker Overview
===============

Our Dockerfile uses a multi-stage build with Go compiler and Alpine runtime:

.. code-block:: dockerfile

   FROM golang:1.19-alpine AS builder
   
   WORKDIR /app
   COPY go.mod .
   COPY main.go .
   
   RUN go build -o webwords main.go
   
   FROM alpine:latest
   
   RUN apk add --no-cache ca-certificates
   
   COPY --from=builder /app/webwords /usr/local/bin/webwords
   
   EXPOSE 31337
   CMD ["webwords"]

**Multi-Stage Build Breakdown:**

**Stage 1 (Builder):**
- ``FROM golang:1.19-alpine AS builder``: Use Go 1.19 compiler on Alpine Linux
- ``COPY go.mod .``: Copy Go module file (defines module name and Go version)
- ``COPY main.go .``: Copy source code
- ``RUN go build -o webwords main.go``: Compile to static binary

**Stage 2 (Runtime):**
- ``FROM alpine:latest``: Start with minimal Alpine image (~5MB)
- ``RUN apk add --no-cache ca-certificates``: Add SSL certificates for HTTPS
- ``COPY --from=builder /app/webwords /usr/local/bin/webwords``: Copy compiled binary
- Final image contains only the executable and minimal runtime

Understanding the Code
======================

This Go implementation uses only the standard library, demonstrating Go's "batteries included" philosophy with net/http for both HTTP server and client operations.

Go Module (go.mod)
------------------

.. code-block:: go

   module webwords
   
   go 1.19

- Defines the module name as "webwords"
- Specifies Go version 1.19 as minimum requirement
- No external dependencies - uses only standard library

Main Application (main.go)
--------------------------

**Package Declaration and Imports:**

.. code-block:: go

   package main
   
   import (
       "log"
       "net/http"
       "time"
       "io/ioutil"
       "io"
       "strings"
       "fmt"
   )

- ``package main``: Defines this as an executable program
- Standard library imports for HTTP, I/O, string manipulation, and logging

**HTTP Client Configuration:**

.. code-block:: go

   var http_client = &http.Client{
     Timeout: time.Second * 10,
   }

Creates an HTTP client with 10-second timeout:
- ``&http.Client{}``: Creates pointer to HTTP client struct
- ``Timeout``: Prevents hanging on slow or unresponsive servers
- Reused for all outgoing HTTP requests

**HTTP Server Handler:**

.. code-block:: go

   http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
       target_sarray, _ := r.URL.Query()["target"]
       keyword_sarray, _ := r.URL.Query()["keyword"]
       target := strings.Join(target_sarray, "")
       keyword := strings.Join(keyword_sarray, "")

The handler function:
1. ``http.HandleFunc("/", ...)``: Registers function for root path
2. ``r.URL.Query()["target"]``: Extracts query parameters (returns string slice)
3. ``strings.Join(target_sarray, "")``: Converts slice to single string
4. ``_`` discards error return values (simplified error handling)

**HTTP Request Processing:**

.. code-block:: go

   resp, _ := http_client.Get(target)
   defer resp.Body.Close()
   
   body_bytes, _ := ioutil.ReadAll(resp.Body)
   body := string(body_bytes)

HTTP request flow:
1. ``http_client.Get(target)``: Makes GET request to target URL
2. ``defer resp.Body.Close()``: Ensures response body is closed when function exits
3. ``ioutil.ReadAll(resp.Body)``: Reads entire response into memory
4. ``string(body_bytes)``: Converts byte slice to string

**Keyword Search and Response:**

.. code-block:: go

   var keyword_found = strings.Contains(body, keyword)
   var found = "false"
   if keyword_found {
       found = "true"
   }
   
   fmt.Printf("found=%q, keywork=%q, uri=%q\n", found, keyword, target)
   io.WriteString(w, found)

Search and response logic:
1. ``strings.Contains(body, keyword)``: Built-in substring search
2. Convert boolean result to "true"/"false" string
3. ``fmt.Printf(...)``: Log request details to stdout
4. ``io.WriteString(w, found)``: Send response back to client

**Server Startup:**

.. code-block:: go

   fmt.Println("listening on 0.0.0.0:31337")
   log.Fatal(http.ListenAndServe(":31337", nil))

Server initialization:
1. Print startup message to console
2. ``http.ListenAndServe(":31337", nil)``: Start HTTP server on port 31337
3. ``nil`` router uses default ServeMux with registered handlers
4. ``log.Fatal()``: Exit program if server startup fails

Building and Running
====================

Step 1: Build the Docker image
------------------------------

.. code-block:: bash

   cd /home/fox/git/webwords/go
   docker build -t webwords-go .

Step 2: Run the container
-------------------------

.. code-block:: bash

   docker run -d -p 31337:31337 --name test-go webwords-go

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

   docker logs test-go

Expected output:
- "listening on 0.0.0.0:31337" on startup
- "found=\"true\", keywork=\"potato\", uri=\"https://www.remarkbox.com\"" for requests

Step 5: Clean up
----------------

.. code-block:: bash

   docker stop test-go
   docker rm test-go

Common Issues
=============

Go module not found errors
--------------------------

If you see "go.mod file not found" during build:

.. code-block:: bash

   # Verify go.mod exists
   ls -la /home/fox/git/webwords/go/
   cat /home/fox/git/webwords/go/go.mod

The go.mod file is required for Go 1.19+ module-based builds.

SSL certificate errors
----------------------

If HTTPS requests fail with certificate errors:
- Ensure ca-certificates are installed: ``RUN apk add --no-cache ca-certificates``
- Go's HTTP client uses system certificate store
- Network timeouts are set to 10 seconds

Binary not found in runtime image
---------------------------------

If the container fails to start with "webwords: not found":
- Check multi-stage build copied binary correctly
- Verify binary path: ``COPY --from=builder /app/webwords /usr/local/bin/webwords``
- Binary must be executable (Go builds create executable binaries by default)

Port binding issues
------------------

If the server fails to bind to port 31337:
- Check no other containers are using the port
- Go's ``http.ListenAndServe(":31337", nil)`` binds to all interfaces
- Use ``docker ps | grep 31337`` to check for conflicts

Memory issues with large responses
---------------------------------

If requests fail with large target URLs:
- ``ioutil.ReadAll()`` loads entire response into memory
- 10-second timeout prevents indefinite hangs
- Consider streaming for very large responses in production

Implementation Notes
===================

This Go implementation demonstrates:
- **Standard Library Power**: Complete HTTP server/client using only built-in packages
- **Multi-Stage Docker Build**: Separate build and runtime environments for efficiency
- **Static Binary Compilation**: Single executable with no external dependencies
- **Concurrent Request Handling**: Go's HTTP server automatically handles multiple requests
- **Explicit Error Handling**: Go's error-as-value pattern (simplified with ``_`` in this example)
- **Resource Management**: ``defer`` ensures proper cleanup of HTTP response bodies

The implementation prioritizes simplicity and demonstrates Go's philosophy of clear, readable code with good performance characteristics out of the box.