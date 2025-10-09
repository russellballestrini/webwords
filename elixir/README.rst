WebWords - Elixir Implementation
===============================

This directory contains the Elixir implementation of the WebWords service using Plug/Cowboy with functional programming and fault-tolerant patterns.

Docker Overview
===============

Our Dockerfile uses Elixir's Mix build tool with dependency caching:

.. code-block:: dockerfile

   FROM elixir:1.14-alpine
   
   RUN mix local.hex --force && mix local.rebar --force
   
   WORKDIR /app
   COPY mix.exs ./
   RUN mix deps.get
   RUN mix deps.compile
   
   COPY lib ./lib
   RUN mix compile
   
   EXPOSE 31337
   
   CMD ["mix", "run", "--no-halt"]

**Single-Stage Build Features:**

1. **Official Elixir Image**: Alpine-based for minimal footprint
2. **Mix Tools**: Installs Hex package manager and Rebar build tool
3. **Dependency Caching**: COPY order optimizes Docker layer caching
4. **Compilation Stages**: Separate dependency compilation from source compilation
5. **Development Mode**: ``mix run --no-halt`` keeps application running

The build leverages Mix's dependency management to download and compile Plug/Cowboy dependencies before compiling the application source.

Understanding the Code
======================

This Elixir implementation demonstrates functional programming with the actor model, pattern matching, and fault-tolerant supervision.

Project Configuration (mix.exs)
-------------------------------

.. code-block:: elixir

   defmodule WebWords.MixProject do
     use Mix.Project
   
     def project do
       [
         app: :webwords,
         version: "0.1.0",
         elixir: "~> 1.14",
         start_permanent: Mix.env() == :prod,
         deps: deps()
       ]
     end

Mix project configuration:
- ``defmodule WebWords.MixProject``: Module defining build configuration
- ``app: :webwords``: Application name for OTP (Open Telecom Platform)
- ``elixir: "~> 1.14"``: Elixir version requirement
- ``start_permanent: Mix.env() == :prod``: Production startup mode
- ``deps: deps()``: Dependency list function

**Application Configuration:**

.. code-block:: elixir

   def application do
     [
       extra_applications: [:logger],
       mod: {WebWords.Application, []}
     ]
   end

OTP application structure:
1. ``extra_applications: [:logger]``: Uses built-in logging application
2. ``mod: {WebWords.Application, []}``: Application callback module
3. OTP applications provide supervision and lifecycle management

**Dependencies:**

.. code-block:: elixir

   defp deps do
     [
       {:plug_cowboy, "~> 2.0"},
       {:httpoison, "~> 1.8"}
     ]
   end

Dependency definitions:
- ``{:plug_cowboy, "~> 2.0"}``: HTTP server framework (Plug + Cowboy)
- ``{:httpoison, "~> 1.8"}``: HTTP client library
- ``~>`` operator allows compatible version updates

Application Supervisor (lib/webwords/application.ex)
---------------------------------------------------

.. code-block:: elixir

   defmodule WebWords.Application do
     use Application
   
     def start(_type, _args) do
       children = [
         {Plug.Cowboy, scheme: :http, plug: WebWords, options: [port: 31337, ip: {0, 0, 0, 0}]}
       ]

OTP application callback:
1. ``use Application``: Brings in OTP application behavior
2. ``start/2`` callback: Required function for OTP applications
3. ``children = [...]``: List of child processes to supervise
4. ``{Plug.Cowboy, ...}``: HTTP server child specification
5. ``ip: {0, 0, 0, 0}``: Listen on all interfaces (Docker requirement)

**Supervision Tree:**

.. code-block:: elixir

   IO.puts("listening on 0.0.0.0:31337")
   
   opts = [strategy: :one_for_one, name: WebWords.Supervisor]
   Supervisor.start_link(children, opts)

Fault-tolerant supervision:
1. ``strategy: :one_for_one``: Restart individual failed children
2. ``Supervisor.start_link/2``: Starts supervisor with child processes
3. Supervisor automatically restarts crashed HTTP server
4. Fault tolerance without bringing down entire application

Main HTTP Handler (lib/webwords.ex)
----------------------------------

**Plug Router Setup:**

.. code-block:: elixir

   defmodule WebWords do
     use Plug.Router
   
     plug Plug.Logger
     plug Plug.Parsers, parsers: [:urlencoded, :multipart]
     plug :match
     plug :dispatch

Plug pipeline:
1. ``use Plug.Router``: Imports routing DSL and functionality
2. ``plug Plug.Logger``: Logs all HTTP requests
3. ``plug Plug.Parsers``: Parses request parameters
4. ``plug :match``: Matches incoming requests to routes
5. ``plug :dispatch``: Calls matched route handler

**Route Handler:**

.. code-block:: elixir

   get "/" do
     keyword = conn.params["keyword"] || ""
     target = conn.params["target"] || ""

Route handling:
1. ``get "/"`` macro: Defines GET route for root path
2. ``conn.params["keyword"]``: Extracts query parameter
3. ``|| ""``: Provides default empty string if parameter missing
4. ``conn`` variable: Connection struct passed to route handler

**HTTP Client and Pattern Matching:**

.. code-block:: elixir

   found = if keyword != "" and target != "" do
     case HTTPoison.get(target, [], recv_timeout: 10_000) do
       {:ok, %HTTPoison.Response{body: body}} ->
         if String.contains?(body, keyword) do
           "true"
         else
           "false"
         end
       {:error, _} ->
         "false"
     end
   else
     "false"
   end

Pattern matching and error handling:
1. ``if keyword != "" and target != ""``: Validates parameters exist
2. ``case HTTPoison.get(...)``: Pattern match on HTTP response
3. ``{:ok, %HTTPoison.Response{body: body}}``: Success pattern with struct destructuring
4. ``recv_timeout: 10_000``: 10-second timeout for HTTP requests
5. ``{:error, _}``: Catch-all error pattern
6. ``String.contains?(body, keyword)``: String search operation

**Response Generation:**

.. code-block:: elixir

   IO.puts("found=#{found}, keyword=#{keyword}, uri=#{target}")
   
   conn
   |> put_resp_content_type("text/plain")
   |> send_resp(200, found)

Pipeline response building:
1. ``IO.puts(...)``: Logging with string interpolation
2. ``conn |> ...``: Pipe operator for function chaining
3. ``put_resp_content_type("text/plain")``: Sets Content-Type header
4. ``send_resp(200, found)``: Sends HTTP 200 response with body
5. Functional pipeline transforms connection struct

**Catch-All Route:**

.. code-block:: elixir

   match _ do
     send_resp(conn, 404, "Not found")
   end

Default route handler:
- ``match _``: Wildcard pattern matches any unhandled route
- Returns HTTP 404 for undefined endpoints

Building and Running
====================

Step 1: Build the Docker image
------------------------------

.. code-block:: bash

   cd /home/fox/git/webwords/elixir
   docker build -t webwords-elixir .

Mix will download dependencies and compile Elixir source during build.

Step 2: Run the container
-------------------------

.. code-block:: bash

   docker run -d -p 31337:31337 --name test-elixir webwords-elixir

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

   docker logs test-elixir

Expected output:
- "listening on 0.0.0.0:31337" on startup
- "found=true, keyword=potato, uri=https://www.remarkbox.com" for requests

Step 5: Clean up
----------------

.. code-block:: bash

   docker stop test-elixir
   docker rm test-elixir

Common Issues
=============

Mix dependency resolution errors
------------------------------

If Mix fails to download dependencies during build:

.. code-block:: bash

   # Check Mix and Hex installation
   docker run -it elixir:1.14-alpine mix --version
   docker run -it elixir:1.14-alpine mix hex.info

Common dependency issues:
- Network connectivity problems downloading packages
- Version conflicts between dependencies
- Missing Hex package manager installation

Application startup errors
-------------------------

If OTP application fails to start:

.. code-block:: bash

   # Check application configuration
   docker logs test-elixir | grep "Application start"
   
   # Verify supervisor tree
   docker logs test-elixir | grep "Supervisor"

Startup issues:
- Port 31337 already in use by another process
- Invalid supervisor child specifications
- Missing application dependencies

Pattern matching errors
---------------------

If pattern matching fails during compilation:

.. code-block:: bash

   # Check for pattern matching warnings
   docker run -v $(pwd):/app -it elixir:1.14-alpine mix compile

Elixir pattern matching is strict:
- All patterns must be exhaustive or have catch-all clauses
- Struct patterns must match exact field names
- Variables can only be bound once per pattern

HTTP client timeout issues
-------------------------

If HTTPoison requests timeout:

.. code-block:: bash

   # Check timeout configuration in logs
   docker logs test-elixir | grep "timeout"

Timeout configuration:
- ``recv_timeout: 10_000`` sets 10-second timeout
- Adjust timeout for slower target websites
- Consider connection pooling for production

Process supervision issues
-------------------------

If processes crash and don't restart:

.. code-block:: bash

   # Check supervisor logs
   docker logs test-elixir | grep -E "(crashed|restarted)"

Supervision tree troubleshooting:
- Verify ``:one_for_one`` strategy is appropriate
- Check child process specifications
- Monitor process restart frequency

Implementation Notes
===================

This Elixir implementation demonstrates:
- **Actor Model**: Lightweight processes communicate via message passing
- **Fault Tolerance**: Supervisor trees automatically restart crashed processes
- **Pattern Matching**: Powerful data destructuring and control flow
- **Immutability**: All data structures are immutable by default
- **Functional Pipelines**: Pipe operator creates readable data transformations
- **OTP Principles**: Open Telecom Platform conventions for robust applications

The implementation showcases Elixir's strengths in building concurrent, fault-tolerant web services. The actor model enables massive concurrency while pattern matching provides elegant error handling. The supervision tree ensures service reliability even when individual HTTP requests fail, demonstrating the "let it crash" philosophy that makes Elixir applications incredibly robust in production environments.
   target = conn.params["target"] || ""

This extracts parameters from the request:
- ``conn`` is the connection struct containing request information
- ``conn.params`` is a map of query parameters
- ``||`` is the "or" operator, providing a default value
- Maps in Elixir use square bracket syntax for access

.. code-block:: elixir

   found = if keyword != "" and target != "" do

This starts a conditional expression:
- ``if`` in Elixir is an expression that returns a value
- ``!=`` is the "not equal" operator
- ``and`` is a boolean operator (also available: ``&&`` for short-circuiting)

.. code-block:: elixir

   case HTTPoison.get(target, [], recv_timeout: 10_000) do

This makes an HTTP request using pattern matching:
- ``HTTPoison.get`` makes a GET request to the target URL
- ``[]`` represents empty headers
- ``recv_timeout: 10_000`` sets a 10-second timeout
- ``case`` allows pattern matching on the result

.. code-block:: elixir

   {:ok, %HTTPoison.Response{body: body}} ->
     if String.contains?(body, keyword) do
       "true"
     else
       "false"
     end

This handles a successful HTTP response:
- ``{:ok, %HTTPoison.Response{body: body}}`` is a pattern that matches success
- ``%HTTPoison.Response{body: body}`` extracts the body field from the struct
- ``String.contains?`` checks if the keyword exists in the response body
- Functions ending with ``?`` typically return true/false

.. code-block:: elixir

   {:error, _} ->
     "false"

This handles HTTP errors:
- ``{:error, _}`` matches any error tuple
- ``_`` is a wildcard that ignores the specific error details
- Returns "false" for any network or HTTP error

.. code-block:: elixir

   else
     "false"
   end

This handles the case where keyword or target is empty:
- ``else`` clause of the ``if`` expression
- ``end`` closes the ``if`` block

.. code-block:: elixir

   IO.puts("found=#{found}, keyword=#{keyword}, uri=#{target}")

This logs the result:
- ``IO.puts`` prints to standard output
- ``#{}`` is string interpolation syntax
- Variables are automatically converted to strings inside interpolation

.. code-block:: elixir

   conn
   |> put_resp_content_type("text/plain")
   |> send_resp(200, found)

This builds and sends the HTTP response:
- ``|>`` is the **pipe operator** - passes the result to the next function
- ``put_resp_content_type`` sets the Content-Type header
- ``send_resp`` sends the response with status code 200 and our result
- Pipe operator makes data transformations readable

.. code-block:: elixir

   match _ do
     send_resp(conn, 404, "Not found")
   end

This is a catch-all route:
- ``match _`` handles any request that doesn't match other routes
- ``_`` is a wildcard pattern
- Returns a 404 Not Found response

Now let's look at the Application module:

.. code-block:: elixir

   defmodule WebWords.Application do
     use Application

This defines the application module:
- ``WebWords.Application`` is a namespaced module
- ``use Application`` provides OTP (Open Telecom Platform) application behavior

.. code-block:: elixir

   def start(_type, _args) do

This is the application startup function:
- Called when the application starts
- ``_type`` and ``_args`` are unused parameters (prefixed with ``_``)

.. code-block:: elixir

   children = [
     {Plug.Cowboy, scheme: :http, plug: WebWords, options: [port: 31337, ip: {0, 0, 0, 0}]}
   ]

This defines child processes:
- ``children`` is a list of processes to start
- ``Plug.Cowboy`` is the web server
- ``:http`` specifies the protocol
- ``{0, 0, 0, 0}`` represents the IP address 0.0.0.0 (listen on all interfaces)

.. code-block:: elixir

   opts = [strategy: :one_for_one, name: WebWords.Supervisor]
   Supervisor.start_link(children, opts)

This starts a supervisor:
- Supervisors monitor and restart child processes if they crash
- ``:one_for_one`` means if one child crashes, only restart that child
- ``start_link`` creates a linked supervisor process

Understanding the Dockerfile
-----------------------------

The Dockerfile tells Docker how to build a container for our Elixir application:

.. code-block:: dockerfile

   FROM elixir:1.14-alpine

This starts with an **Elixir base image**:
- ``elixir:1.14`` provides Elixir version 1.14
- ``alpine`` uses Alpine Linux for a smaller image size

.. code-block:: dockerfile

   RUN mix local.hex --force && mix local.rebar --force

This installs Elixir build tools:
- ``mix`` is Elixir's build tool (like npm or pip)
- ``hex`` is Elixir's package manager
- ``rebar`` is an Erlang build tool needed for some dependencies
- ``--force`` installs without prompting

.. code-block:: dockerfile

   WORKDIR /app
   COPY mix.exs mix.lock ./

This sets up the workspace:
- ``WORKDIR`` sets the working directory
- ``mix.exs`` defines the project configuration
- ``mix.lock`` locks dependency versions (like package-lock.json)

.. code-block:: dockerfile

   RUN mix deps.get
   RUN mix deps.compile

This installs and compiles dependencies:
- ``mix deps.get`` downloads all dependencies
- ``mix deps.compile`` compiles them to bytecode
- Done separately from app code for better Docker layer caching

.. code-block:: dockerfile

   COPY lib ./lib
   RUN mix compile

This copies and compiles the application code:
- ``lib`` directory contains our Elixir source files
- ``mix compile`` compiles our application to BEAM bytecode

.. code-block:: dockerfile

   EXPOSE 31337

This tells Docker that our application listens on port 31337.

.. code-block:: dockerfile

   CMD ["mix", "run", "--no-halt"]

This specifies the startup command:
- ``mix run`` starts the application
- ``--no-halt`` keeps the process running (doesn't exit after startup)

Understanding mix.exs
---------------------

The ``mix.exs`` file is Elixir's project configuration:

.. code-block:: elixir

   def project do
     [
       app: :webwords,
       version: "0.1.0",
       elixir: "~> 1.14",
       start_permanent: Mix.env() == :prod,
       deps: deps()
     ]
   end

This defines project metadata:
- ``:webwords`` is the application name (atom syntax)
- ``~> 1.14`` means compatible with Elixir 1.14.x
- ``start_permanent`` determines if the app should restart on crashes

.. code-block:: elixir

   def application do
     [
       extra_applications: [:logger],
       mod: {WebWords.Application, []}
     ]
   end

This configures the OTP application:
- ``:logger`` is an additional Erlang application to start
- ``mod`` specifies the main application module

.. code-block:: elixir

   defp deps do
     [
       {:plug_cowboy, "~> 2.0"},
       {:httpoison, "~> 1.8"}
     ]
   end

This lists project dependencies:
- ``defp`` defines a private function
- ``{:plug_cowboy, "~> 2.0"}`` is a tuple specifying package and version
- Cowboy is a web server, HTTPoison is an HTTP client

Building and Running
--------------------

To build the Docker image:

.. code-block:: bash

   cd elixir
   docker build -t webwords-elixir .

To run the container:

.. code-block:: bash

   docker run -d -p 31337:31337 webwords-elixir

To test it:

.. code-block:: bash

   curl "http://localhost:31337/?keyword=potato&target=https://www.remarkbox.com"

Common Elixir Patterns Used
---------------------------

1. **Pattern matching**: Destructuring data in function parameters and case statements
2. **Pipe operator**: Chaining function calls for readable data transformation
3. **Atoms**: Immutable constants like ``:ok``, ``:error``, ``:http``
4. **Tuples**: Fixed-size collections like ``{:ok, result}``
5. **Maps**: Key-value collections with ``%{}`` syntax
6. **Supervisor trees**: Fault-tolerant process hierarchies
7. **GenServers**: Stateful processes that handle messages

Elixir-Specific Features
------------------------

1. **Immutability**: All data is immutable by default
2. **Processes**: Lightweight (not OS threads) - can spawn millions
3. **Message passing**: Processes communicate via messages, not shared memory
4. **OTP behaviors**: Proven patterns for building reliable systems
5. **Hot code swapping**: Update running systems without downtime
6. **Distributed**: Can run across multiple machines transparently

Learning More
-------------

To learn Elixir:
1. Start with the official Elixir guide: https://elixir-lang.org/getting-started/introduction.html
2. Read "Programming Elixir" by Dave Thomas
3. Try "Elixir School" tutorials: https://elixirschool.com/
4. Practice with Phoenix framework for web development
5. Learn about OTP and distributed systems concepts

Next Steps
----------

Try modifying this code to:
1. Add proper error handling and logging
2. Implement request caching with ETS tables
3. Add authentication using Plug.BasicAuth
4. Use GenServer to maintain application state
5. Add distributed processing across multiple nodes
6. Implement rate limiting for requests
7. Add WebSocket support for real-time updates
8. Create a Phoenix web interface