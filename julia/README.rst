WebWords - Julia Implementation
=============================

This directory contains the Julia implementation of the WebWords service using HTTP.jl with scientific computing performance and dynamic multiple dispatch.

Docker Overview
===============

Our Dockerfile uses the official Julia image with package precompilation:

.. code-block:: dockerfile

   FROM julia:1.9
   
   WORKDIR /app
   COPY Project.toml .
   RUN julia -e 'using Pkg; Pkg.activate("."); Pkg.instantiate(); Pkg.precompile()'
   
   COPY src ./src
   
   EXPOSE 31337
   
   CMD ["julia", "--project=.", "src/webwords.jl"]

**Single-Stage Build Features:**

1. **Official Julia Image**: Julia 1.9 with full language runtime and package manager
2. **Package Management**: Project.toml defines dependencies with UUIDs
3. **Precompilation**: ``Pkg.precompile()`` optimizes package loading time
4. **Project Activation**: ``--project=.`` ensures correct package environment
5. **Just-in-Time Compilation**: Julia compiles functions to native code at runtime

The build leverages Julia's package manager (Pkg) to handle dependencies and precompilation for optimal startup performance.

Understanding the Code
======================

This Julia implementation demonstrates scientific computing patterns with multiple dispatch, metaprogramming, and high-performance HTTP processing.

Project Configuration (Project.toml)
------------------------------------

.. code-block:: toml

   [deps]
   HTTP = "cd3eb016-35fb-5094-929b-558a96fad6f3"
   Sockets = "6462fe0b-24de-5631-8697-dd941f90decc"
   
   [compat]
   julia = "1.9"

Julia package configuration:
- ``[deps]``: Dependencies section with package UUIDs
- ``HTTP = "cd3eb016-..."``: HTTP.jl package for web server and client
- ``Sockets = "6462fe0b-..."``: Socket utilities for network programming
- ``[compat]``: Compatibility constraints
- ``julia = "1.9"``: Minimum Julia version requirement
- UUIDs ensure exact package identification in Julia's registry

Main Application (src/webwords.jl)
----------------------------------

**Module Imports:**

.. code-block:: julia

   using HTTP
   using Sockets

Julia using statements:
- ``using HTTP``: Imports HTTP.jl package for web functionality
- ``using Sockets``: Imports socket utilities for IP address handling
- Julia imports bring all exported names into current namespace

**Request Handler Function:**

.. code-block:: julia

   function handle_request(req::HTTP.Request)
       uri = HTTP.URI(req.target)
       query = HTTP.URIs.queryparams(uri)

Function definition with type annotation:
1. ``function handle_request(req::HTTP.Request)``: Function with typed parameter
2. ``uri = HTTP.URI(req.target)``: Parse request target as URI object
3. ``query = HTTP.URIs.queryparams(uri)``: Extract query parameters as dictionary
4. Julia's type system enables multiple dispatch on argument types

**Parameter Extraction:**

.. code-block:: julia

   keyword = get(query, "keyword", "")
   target = get(query, "target", "")
   found = "false"

Variable assignment and default values:
1. ``keyword = get(query, "keyword", "")``: Dictionary lookup with default
2. ``target = get(query, "target", "")``: Extract target parameter
3. ``found = "false"``: Initialize response variable
4. Julia variables are dynamically typed but can be constrained

**HTTP Client and String Processing:**

.. code-block:: julia

   if !isempty(keyword) && !isempty(target)
       try
           response = HTTP.get(target, readtimeout=10)
           body = String(response.body)
           
           if occursin(keyword, body)
               found = "true"
           end

Conditional processing:
1. ``if !isempty(keyword) && !isempty(target)``: Check non-empty parameters
2. ``try ... catch``: Exception handling block
3. ``HTTP.get(target, readtimeout=10)``: HTTP GET with 10-second timeout
4. ``body = String(response.body)``: Convert response body to string
5. ``occursin(keyword, body)``: Julia string containment function
6. String processing optimized for performance in Julia

**Error Handling and Logging:**

.. code-block:: julia

   println("found=$found, keyword=$keyword, uri=$target")
   catch e
       println("Error: $e")
   end

Logging and error handling:
1. ``println("found=$found, ...")``: String interpolation with $ syntax
2. ``catch e``: Catch any exception type
3. ``println("Error: $e")``: Print exception details
4. Julia's println writes to STDOUT for container logging

**HTTP Response Generation:**

.. code-block:: julia

   return HTTP.Response(200, found)

Response creation:
- ``HTTP.Response(200, found)``: Create HTTP response with status and body
- Status 200 indicates success, body contains "true" or "false"
- Return statement provides response to HTTP.jl framework

**Main Function and Server Startup:**

.. code-block:: julia

   function main()
       port = parse(Int, get(ENV, "PORT", "31337"))
       println("listening on 0.0.0.0:$port")
       HTTP.serve(handle_request, Sockets.ip"0.0.0.0", port)
   end

Server initialization:
1. ``port = parse(Int, get(ENV, "PORT", "31337"))``: Parse port from environment
2. ``get(ENV, "PORT", "31337")``: Environment variable lookup with default
3. ``parse(Int, ...)``: Convert string to integer
4. ``Sockets.ip"0.0.0.0"``: IP address literal syntax
5. ``HTTP.serve(handle_request, ...)``: Start HTTP server with handler function

**Application Entry Point:**

.. code-block:: julia

   main()

Direct function call:
- ``main()``: Execute main function to start server
- Julia scripts execute top-level code immediately
- No special main entry point required

Building and Running
====================

Step 1: Build the Docker image
------------------------------

.. code-block:: bash

   cd /home/fox/git/webwords/julia
   docker build -t webwords-julia .

Julia package manager will download dependencies and precompile during build.

Step 2: Run the container
-------------------------

.. code-block:: bash

   docker run -d -p 31337:31337 --name test-julia webwords-julia

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

   docker logs test-julia

Expected output:
- "listening on 0.0.0.0:31337" on startup
- "found=true, keyword=potato, uri=https://www.remarkbox.com" for requests

Step 5: Clean up
----------------

.. code-block:: bash

   docker stop test-julia
   docker rm test-julia

Common Issues
=============

Julia package resolution errors
------------------------------

If Julia package installation fails during build:

.. code-block:: bash

   # Check Julia package manager status
   docker run -v $(pwd):/app -it julia:1.9 bash
   cd /app && julia -e 'using Pkg; Pkg.status()'

Package management issues:
- Network connectivity problems downloading from Julia registries
- Package version compatibility conflicts
- Missing system dependencies for binary packages

Project activation errors
-------------------------

If Julia fails to activate the project environment:

.. code-block:: bash

   # Check project activation
   docker run -v $(pwd):/app -it julia:1.9 bash
   cd /app && julia --project=. -e 'using Pkg; Pkg.status()'

Project environment issues:
- Missing or corrupted Project.toml file
- Incorrect package UUIDs in dependencies
- Julia version compatibility problems

HTTP.jl server binding errors
----------------------------

If HTTP server fails to start or bind to port:

.. code-block:: bash

   # Check server startup and binding
   docker logs test-julia | grep -E "(listening|bind|error)"

Server binding issues:
- Port 31337 already in use by another process
- Permission issues binding to network interface
- Incorrect IP address format or syntax

Type inference and performance warnings
--------------------------------------

If Julia emits performance warnings during execution:

.. code-block:: bash

   # Check for type stability warnings
   julia --project=. -e '@time include("src/webwords.jl")'

Performance optimization:
- Use type annotations for function parameters when possible
- Avoid global variables that can't be type-inferred
- Use ``@code_warntype`` to check type inference

Memory allocation issues
-----------------------

If application uses excessive memory:

.. code-block:: bash

   # Monitor memory usage
   docker stats test-julia

Memory optimization:
- Julia's garbage collector handles most memory automatically
- Avoid creating unnecessary temporary strings
- Use in-place operations when possible for large data

Implementation Notes
===================

This Julia implementation demonstrates:
- **Scientific Computing**: High-performance numerical computing runtime
- **Multiple Dispatch**: Function behavior determined by all argument types
- **JIT Compilation**: Just-in-time compilation to optimized native code
- **Package Ecosystem**: Mature HTTP.jl for web development
- **String Interpolation**: Elegant syntax for string templating
- **Performance**: Near C-level performance for computational code

The implementation showcases Julia's strengths in combining ease of use with performance. HTTP.jl provides a clean, functional interface for web services while Julia's just-in-time compilation ensures optimal runtime performance. The language's design for scientific computing translates well to web service development, offering both developer productivity and execution efficiency for data-intensive applications.