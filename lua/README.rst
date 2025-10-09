WebWords - Lua Implementation
=============================

This directory contains the Lua implementation of the WebWords service using LuaSocket with manual HTTP server implementation and lightweight scripting patterns.

Docker Overview
===============

Our Dockerfile uses Alpine Linux with Lua 5.3 and LuaRocks package manager:

.. code-block:: dockerfile

   FROM alpine:latest
   
   RUN apk add --no-cache lua5.3 lua5.3-socket lua5.3-dev luarocks5.3 build-base openssl-dev ca-certificates
   RUN luarocks-5.3 install luasocket
   RUN luarocks-5.3 install luasec
   
   WORKDIR /app
   COPY app.lua .
   
   EXPOSE 31337
   
   CMD ["lua5.3", "app.lua"]

**Single-Stage Build Features:**

1. **Alpine Base**: Minimal Linux distribution for small container size
2. **Lua 5.3**: Modern Lua interpreter with standard library
3. **LuaSocket**: Network programming library for HTTP functionality
4. **LuaSec**: SSL/TLS support for HTTPS requests
5. **Build Dependencies**: Compiler and OpenSSL for native module compilation
6. **Script Execution**: Direct interpretation of Lua source code

The build leverages LuaRocks package manager to install network libraries for HTTP server and client functionality.

Understanding the Code
======================

This Lua implementation demonstrates lightweight scripting with manual HTTP protocol handling and table-based data structures.

Main Application (app.lua)
--------------------------

**Module Imports:**

.. code-block:: lua

   local socket = require("socket")
   local http = require("socket.http")
   local https = require("ssl.https")
   local url = require("socket.url")

Lua module loading:
- ``local socket = require("socket")``: LuaSocket core networking
- ``local http = require("socket.http")``: HTTP client functionality
- ``local https = require("ssl.https")``: HTTPS client with SSL support
- ``local url = require("socket.url")``: URL parsing and escaping utilities
- ``local`` keyword creates function-local variables

**Query Parameter Parsing:**

.. code-block:: lua

   function parse_query(query)
       local params = {}
       if query then
           for pair in string.gmatch(query, "([^&]+)") do
               local key, value = string.match(pair, "([^=]+)=([^=]*)")
               if key then
                   params[url.unescape(key)] = url.unescape(value or "")
               end
           end
       end
       return params
   end

Manual query parsing:
1. ``function parse_query(query)``: Function definition
2. ``local params = {}``: Empty table (Lua's universal data structure)
3. ``string.gmatch(query, "([^&]+)")``: Pattern matching iterator for parameter pairs
4. ``string.match(pair, "([^=]+)=([^=]*)")``: Extract key-value pairs
5. ``url.unescape(key)``: URL decode parameters
6. ``params[url.unescape(key)] = ...``: Store in table with decoded key

**HTTP Request Processing:**

.. code-block:: lua

   function handle_request(request_line)
       local method, path_query = string.match(request_line, "([A-Z]+) ([^ ]+)")
       if not method or method ~= "GET" then
           return "HTTP/1.1 405 Method Not Allowed\r\n\r\n"
       end

Request line parsing:
1. ``string.match(request_line, "([A-Z]+) ([^ ]+)")``: Extract HTTP method and path
2. ``if not method or method ~= "GET"``: Validate GET method only
3. Raw HTTP response string with status code 405
4. Manual HTTP protocol implementation

**URL Path and Query Extraction:**

.. code-block:: lua

   local path, query = string.match(path_query, "([^?]*)%??(.*)")
   if path ~= "/" then
       return "HTTP/1.1 404 Not Found\r\n\r\n"
   end
   
   local params = parse_query(query)
   local keyword = params["keyword"] or ""
   local target = params["target"] or ""

URL processing:
1. ``string.match(path_query, "([^?]*)%??(.*)")``: Split path and query string
2. ``if path ~= "/" then``: Validate root path only
3. ``local params = parse_query(query)``: Parse query parameters
4. ``params["keyword"] or ""``: Table lookup with default value
5. Lua's ``or`` operator provides default values for nil

**HTTPS/HTTP Client Selection:**

.. code-block:: lua

   local found = "false"
   
   if keyword ~= "" and target ~= "" then
       local body
       if string.sub(target, 1, 8) == "https://" then
           body = https.request(target)
       else
           body = http.request(target)
       end

Protocol selection and HTTP client:
1. ``if keyword ~= "" and target ~= ""``: Validate non-empty parameters
2. ``string.sub(target, 1, 8) == "https://"``: Check URL protocol
3. ``https.request(target)``: HTTPS client for secure requests
4. ``http.request(target)``: HTTP client for plain requests
5. Conditional protocol handling based on URL scheme

**String Search and Response Generation:**

.. code-block:: lua

   if body and string.find(body, keyword, 1, true) then
       found = "true"
   end
   print(string.format("found=%s, keyword=%s, uri=%s", found, keyword, target))

String processing:
1. ``if body and string.find(...)``: Check body exists and contains keyword
2. ``string.find(body, keyword, 1, true)``: Plain text search (no patterns)
3. ``1, true`` parameters: start position and literal search flag
4. ``string.format("found=%s, ...")``: Printf-style string formatting

**HTTP Response Construction:**

.. code-block:: lua

   local response = string.format(
       "HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\nContent-Length: %d\r\n\r\n%s",
       #found, found
   )
   return response

Manual HTTP response:
1. ``string.format(...)``: Build complete HTTP response
2. ``#found``: Lua length operator for string length
3. Raw HTTP headers with Content-Type and Content-Length
4. Manual HTTP protocol implementation

**TCP Server Loop:**

.. code-block:: lua

   local server = socket.bind("0.0.0.0", 31337)
   print("listening on 0.0.0.0:31337")
   
   while true do
       local client = server:accept()
       client:settimeout(10)
       
       local request_line = client:receive()
       if request_line then
           local response = handle_request(request_line)
           client:send(response)
       end
       
       client:close()
   end

Server event loop:
1. ``socket.bind("0.0.0.0", 31337)``: Create TCP server socket
2. ``while true do``: Infinite server loop
3. ``server:accept()``: Block waiting for client connections
4. ``client:settimeout(10)``: Set 10-second timeout for client operations
5. ``client:receive()``: Read HTTP request line
6. ``client:send(response)``: Send HTTP response
7. ``client:close()``: Close connection after each request

Building and Running
====================

Step 1: Build the Docker image
------------------------------

.. code-block:: bash

   cd /home/fox/git/webwords/lua
   docker build -t webwords-lua .

LuaRocks will install LuaSocket and LuaSec during build.

Step 2: Run the container
-------------------------

.. code-block:: bash

   docker run -d -p 31337:31337 --name test-lua webwords-lua

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

   docker logs test-lua

Expected output:
- "listening on 0.0.0.0:31337" on startup
- "found=true, keyword=potato, uri=https://www.remarkbox.com" for requests

Step 5: Clean up
----------------

.. code-block:: bash

   docker stop test-lua
   docker rm test-lua

Common Issues
=============

LuaRocks package installation errors
-----------------------------------

If LuaRocks fails to install packages during build:

.. code-block:: bash

   # Check LuaRocks installation manually
   docker run -v $(pwd):/app -it alpine:latest sh
   apk add lua5.3 luarocks5.3 build-base openssl-dev
   luarocks-5.3 install luasocket

Common LuaRocks issues:
- Missing build dependencies (build-base, openssl-dev)
- Network connectivity problems downloading packages
- C compiler errors during native module compilation

Lua syntax and runtime errors
-----------------------------

If Lua script fails to execute:

.. code-block:: bash

   # Check Lua syntax
   docker run -v $(pwd):/app -it alpine:latest sh
   apk add lua5.3
   cd /app && lua5.3 -l app.lua

Common Lua syntax issues:
- Missing ``end`` keywords for functions or control structures
- Incorrect string escaping or quoting
- Nil reference errors in table lookups

Socket binding and networking issues
-----------------------------------

If TCP server fails to bind or accept connections:

.. code-block:: bash

   # Check socket binding errors
   docker logs test-lua | grep -E "(bind|accept|socket)"

Socket troubleshooting:
- Port 31337 already in use by another process
- Permission issues binding to network interface
- LuaSocket library not properly installed

HTTP protocol parsing errors
---------------------------

If HTTP request parsing fails:

.. code-block:: bash

   # Check HTTP request handling
   docker logs test-lua | grep -E "(method|path|query)"

HTTP parsing issues:
- Malformed HTTP requests from clients
- Incorrect pattern matching in string.match()
- Missing or incorrect HTTP response headers

SSL/TLS certificate issues
-------------------------

If HTTPS requests fail:

.. code-block:: bash

   # Check HTTPS request errors
   docker logs test-lua | grep -i "ssl"

HTTPS troubleshooting:
- Missing CA certificates in container
- LuaSec not properly configured
- SSL/TLS version compatibility issues

Implementation Notes
===================

This Lua implementation demonstrates:
- **Lightweight Scripting**: Minimal memory footprint and fast startup
- **Manual HTTP Implementation**: Direct TCP socket handling with HTTP protocol
- **Table-Based Data**: Lua tables as universal data structure for parameters
- **Pattern Matching**: Lua's powerful string pattern matching for parsing
- **Embedded Language**: Design principles for embedding in applications
- **Coroutine Potential**: Although not used here, Lua's coroutines enable async patterns

The implementation showcases Lua's strengths in lightweight, embeddable scripting with low-level network programming. The manual HTTP protocol implementation demonstrates Lua's ability to handle system-level programming tasks while maintaining simplicity. LuaSocket provides mature networking capabilities, making Lua suitable for network services despite being primarily designed as an embedded language. The table-based approach to data handling reflects Lua's elegant simplicity in using a single, powerful data structure for all programming needs.

   local key, value = string.match(pair, "([^=]+)=([^=]*)")
   if key then
       params[url.unescape(key)] = url.unescape(value or "")

This extracts key-value pairs from each parameter:
- ``string.match()`` extracts parts of a string using patterns
- Multiple assignment: both key and value are assigned at once
- ``or ""`` provides a default value if value is nil
- ``url.unescape()`` decodes URL-encoded characters

.. code-block:: lua

   function handle_request(request_line)
       local method, path_query = string.match(request_line, "([A-Z]+) ([^ ]+)")

This function processes HTTP requests:
- Extracts the HTTP method (GET, POST, etc.) and path from the request line
- HTTP requests start with lines like "GET /path?query HTTP/1.1"

.. code-block:: lua

   if not method or method ~= "GET" then
       return "HTTP/1.1 405 Method Not Allowed\r\n\r\n"
   end

This validates the HTTP method:
- ``not`` is Lua's negation operator
- ``~=`` is Lua's "not equal" operator (different from ``!=`` in other languages)
- Returns a proper HTTP error response if method is not GET

.. code-block:: lua

   local path, query = string.match(path_query, "([^?]*)%??(.*)")

This separates the path from the query string:
- ``%?`` escapes the ``?`` character (since ``?`` has special meaning in patterns)
- ``(.*)`` captures everything after the question mark

.. code-block:: lua

   local params = parse_query(query)
   local keyword = params["keyword"] or ""
   local target = params["target"] or ""
   local found = "false"

This extracts our specific parameters:
- Calls our custom ``parse_query`` function
- Uses table syntax ``params["key"]`` to access values
- Provides empty string defaults with ``or ""``

.. code-block:: lua

   if keyword ~= "" and target ~= "" then
       local body = http.request(target)

This makes the HTTP request if both parameters exist:
- ``http.request()`` is a simple way to fetch web pages
- Returns the page content as a string

.. code-block:: lua

   if body and string.find(body, keyword, 1, true) then
       found = "true"
   end

This searches for the keyword in the response:
- ``string.find()`` searches for a substring
- The ``1`` parameter means start searching from position 1
- The ``true`` parameter means literal search (not pattern matching)

.. code-block:: lua

   print(string.format("found=%s, keyword=%s, uri=%s", found, keyword, target))

This logs the result:
- ``string.format()`` works like printf in C
- ``%s`` is a placeholder for string values

.. code-block:: lua

   local response = string.format(
       "HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\nContent-Length: %d\r\n\r\n%s",
       #found, found
   )

This builds the HTTP response:
- Multi-line strings are concatenated
- ``#found`` gets the length of the string (``#`` is the length operator)
- ``%d`` is a placeholder for numbers

.. code-block:: lua

   local server = socket.bind("0.0.0.0", 31337)
   print("listening on 0.0.0.0:31337")

This creates and starts the server:
- ``socket.bind()`` creates a server socket
- ``"0.0.0.0"`` means listen on all network interfaces
- ``31337`` is the port number

.. code-block:: lua

   while true do
       local client = server:accept()
       client:settimeout(10)

This is the main server loop:
- ``while true`` creates an infinite loop
- ``server:accept()`` waits for incoming connections
- ``:settimeout(10)`` sets a 10-second timeout for operations

.. code-block:: lua

   local request_line = client:receive()
   if request_line then
       local response = handle_request(request_line)
       client:send(response)
   end

This processes each request:
- ``client:receive()`` reads data from the client
- Only processes if we actually received data
- Sends back our generated response

.. code-block:: lua

   client:close()

This closes the connection after handling the request.

Understanding the Dockerfile
-----------------------------

The Dockerfile tells Docker how to build a container for our Lua application:

.. code-block:: dockerfile

   FROM alpine:latest

This starts with **Alpine Linux**, a lightweight Linux distribution popular for containers.

.. code-block:: dockerfile

   RUN apk add --no-cache lua5.3 lua5.3-socket luarocks5.3

This installs Lua and its dependencies:
- ``apk`` is Alpine's package manager
- ``--no-cache`` doesn't keep package cache (saves space)
- ``lua5.3`` is the Lua interpreter
- ``lua5.3-socket`` provides socket functionality
- ``luarocks5.3`` is Lua's package manager

.. code-block:: dockerfile

   RUN luarocks-5.3 install luasocket

This installs the LuaSocket library:
- ``luarocks`` is like npm for Node.js or pip for Python
- ``luasocket`` provides network programming capabilities

.. code-block:: dockerfile

   WORKDIR /app
   COPY app.lua .

This sets up the application:
- ``WORKDIR`` sets the working directory inside the container
- ``COPY`` copies our Lua source code into the container

.. code-block:: dockerfile

   EXPOSE 31337

This tells Docker that our application listens on port 31337.

.. code-block:: dockerfile

   CMD ["lua5.3", "app.lua"]

This specifies what command to run when the container starts.

Building and Running
--------------------

To build the Docker image:

.. code-block:: bash

   cd lua
   docker build -t webwords-lua .

To run the container:

.. code-block:: bash

   docker run -d -p 31337:31337 webwords-lua

To test it:

.. code-block:: bash

   curl "http://localhost:31337/?keyword=potato&target=https://www.remarkbox.com"

Common Lua Patterns Used
-------------------------

1. **Tables**: Used for everything - arrays, objects, dictionaries
2. **Pattern matching**: Like regex but simpler, used in ``string.match()``
3. **Multiple assignment**: ``local a, b = func()`` gets multiple return values
4. **Nil checking**: Using ``or`` for default values
5. **Colon syntax**: ``object:method()`` is sugar for ``object.method(object)``
6. **Local variables**: Always use ``local`` to avoid global pollution

Lua-Specific Features
---------------------

1. **1-based indexing**: Arrays start at index 1, not 0
2. **Length operator**: ``#table`` gets the length
3. **No increment/decrement**: No ``++`` or ``--`` operators
4. **Tables as everything**: Arrays, objects, modules all use tables
5. **Metamethods**: Tables can have custom behavior for operations
6. **Closures**: Functions can capture variables from outer scopes

Learning More
-------------

To learn Lua:
1. Start with the official Lua tutorial: https://www.lua.org/pil/
2. Try "Programming in Lua" book (free first edition online)
3. Practice with simple scripts and games
4. Explore Lua's use in game engines like World of Warcraft addons
5. Learn about embedding Lua in C applications

Next Steps
----------

Try modifying this code to:
1. Add proper HTTP header parsing
2. Implement POST request handling
3. Add error handling for network failures
4. Use coroutines for handling multiple connections
5. Add logging with timestamps
6. Implement basic authentication
7. Add support for HTTPS requests
8. Create a simple HTML interface