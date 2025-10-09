WebWords - Erlang Implementation
===============================

This directory contains the Erlang implementation of the WebWords service using Cowboy HTTP server with OTP application structure and supervision trees.

Docker Overview
===============

Our Dockerfile uses a multi-stage build optimized for Erlang/OTP releases:

.. code-block:: dockerfile

   FROM erlang:25-alpine as builder
   
   WORKDIR /app
   COPY rebar.config .
   RUN rebar3 deps
   
   COPY src ./src
   RUN rebar3 release
   
   FROM erlang:25-alpine
   RUN apk add --no-cache ca-certificates
   COPY --from=builder /app/_build/default/rel/webwords /opt/webwords
   
   EXPOSE 31337
   
   CMD ["/opt/webwords/bin/webwords", "foreground"]

**Multi-Stage Build Breakdown:**

1. **Builder Stage**: Full Erlang environment with rebar3 build tool
2. **Dependency Resolution**: ``rebar3 deps`` downloads and compiles dependencies
3. **Release Creation**: ``rebar3 release`` creates self-contained OTP release
4. **Runtime Stage**: Minimal Erlang runtime with CA certificates
5. **Release Deployment**: Copies complete release with ERTS runtime
6. **Foreground Mode**: Runs application in foreground for Docker container

The build leverages rebar3's release functionality to create a production-ready OTP application with embedded Erlang runtime (ERTS).

Understanding the Code
======================

This Erlang implementation demonstrates OTP principles with supervision trees, pattern matching, and concurrent message-passing architecture.

Build Configuration (rebar.config)
----------------------------------

.. code-block:: erlang

   {deps, [
       {cowboy, "2.10.0"},
       {jsx, "3.1.0"},
       {hackney, "1.20.1"}
   ]}.
   
   {erl_opts, [debug_info]}.
   {relx, [{release, {webwords, "0.1.0"}, [webwords]},
           {dev_mode, false},
           {include_erts, true},
           {extended_start_script, true}]}.

Rebar3 configuration:
- ``{deps, [...]}``: Dependency list with specific versions
- ``{cowboy, "2.10.0"}``: HTTP server framework
- ``{hackney, "1.20.1"}``: HTTP client library
- ``{jsx, "3.1.0"}``: JSON parsing (not used in current implementation)
- ``{erl_opts, [debug_info]}``: Include debug information in compiled modules
- ``{relx, [...]}``: Release configuration for deployment
- ``{include_erts, true}``: Embed Erlang runtime in release
- ``{extended_start_script, true}``: Enhanced startup script functionality

Application Callback (src/webwords_app.erl)
-------------------------------------------

.. code-block:: erlang

   -module(webwords_app).
   -behaviour(application).
   
   -export([start/2, stop/1]).

Module and behavior declaration:
1. ``-module(webwords_app).``: Module name matching filename
2. ``-behaviour(application).``: Implements OTP application behavior
3. ``-export([start/2, stop/1]).``: Exports required callback functions

**Application Startup:**

.. code-block:: erlang

   start(_StartType, _StartArgs) ->
       Dispatch = cowboy_router:compile([
           {'_', [
               {"/", webwords_handler, []}
           ]}
       ]),

Cowboy router setup:
1. ``cowboy_router:compile/1``: Compiles routing rules for efficiency
2. ``{'_', [...]}`` : Matches any hostname (wildcard host)
3. ``{"/", webwords_handler, []}``: Route root path to handler module
4. Compiled dispatch rules stored for request matching

**HTTP Server Initialization:**

.. code-block:: erlang

   {ok, _} = cowboy:start_clear(http_listener,
       [{port, 31337}, {ip, {0, 0, 0, 0}}],
       #{env => #{dispatch => Dispatch}}
   ),

Cowboy server startup:
1. ``cowboy:start_clear/3``: Starts HTTP (non-TLS) listener
2. ``http_listener``: Listener name for management
3. ``{port, 31337}``: Listen on WebWords standard port
4. ``{ip, {0, 0, 0, 0}}``: Listen on all interfaces (Docker requirement)
5. ``#{env => #{dispatch => Dispatch}}``: Environment with routing rules

**Supervisor Integration:**

.. code-block:: erlang

   io:format("listening on 0.0.0.0:31337~n"),
   webwords_sup:start_link().

Application lifecycle:
1. ``io:format/2``: Prints startup message to console
2. ``webwords_sup:start_link/0``: Starts application supervisor
3. Returns ``{ok, Pid}`` for successful application start

HTTP Request Handler (src/webwords_handler.erl)
----------------------------------------------

.. code-block:: erlang

   -module(webwords_handler).
   
   -export([init/2]).

Cowboy handler module:
- ``-export([init/2]).``: Exports required cowboy handler callback

**Request Processing:**

.. code-block:: erlang

   init(Req, Opts) ->
       #{keyword := Keyword, target := Target} = cowboy_req:match_qs([{keyword, [], <<"">>}, {target, [], <<"">>}], Req),

Query parameter extraction:
1. ``cowboy_req:match_qs/2``: Matches query string parameters
2. ``[{keyword, [], <<"">>}, {target, [], <<"">>}]``: Parameter specifications with defaults
3. ``#{keyword := Keyword, target := Target}``: Pattern match extracts parameters
4. ``<<"">>`` : Empty binary as default value

**Pattern Matching Logic:**

.. code-block:: erlang

   Found = case {Keyword, Target} of
       {<<>>, _} -> <<"false">>;
       {_, <<>>} -> <<"false">>;
       {K, T} ->
           Result = case fetch_url(T) of
               {ok, Body} ->
                   case binary:match(Body, K) of
                       nomatch -> <<"false">>;
                       _ -> <<"true">>
                   end;
               {error, _} -> <<"false">>
           end,
           io:format("found=~s, keyword=~s, uri=~s~n", [Result, K, T]),
           Result
   end,

Erlang pattern matching:
1. ``case {Keyword, Target} of`` : Pattern match on parameter tuple
2. ``{<<>>, _} -> <<"false">>;`` : Empty keyword returns false
3. ``{_, <<>>} -> <<"false">>;`` : Empty target returns false
4. ``{K, T} ->`` : Both parameters present, proceed with processing
5. ``case fetch_url(T) of`` : Nested pattern matching on HTTP result
6. ``{ok, Body} ->`` : Success pattern with body extraction
7. ``binary:match(Body, K)`` : Binary string search
8. ``nomatch -> <<"false">>`` : No match found
9. ``{error, _} -> <<"false">>`` : HTTP error handling

**HTTP Client Function:**

.. code-block:: erlang

   fetch_url(Url) ->
       case hackney:get(Url, [], <<>>, [{timeout, 10000}]) of
           {ok, 200, _Headers, ClientRef} ->
               {ok, Body} = hackney:body(ClientRef),
               {ok, Body};
           _ ->
               {error, failed}
       end.

HTTP client implementation:
1. ``hackney:get/4``: HTTP GET request with timeout
2. ``[{timeout, 10000}]``: 10-second timeout option
3. ``{ok, 200, _Headers, ClientRef}`` : Success pattern with reference
4. ``hackney:body(ClientRef)`` : Read response body
5. ``{ok, Body}`` : Return success tuple with body
6. ``_ -> {error, failed}`` : Catch-all error pattern

**Response Generation:**

.. code-block:: erlang

   Req2 = cowboy_req:reply(200, #{<<"content-type">> => <<"text/plain">>}, Found, Req),
   {ok, Req2, Opts}.

HTTP response:
1. ``cowboy_req:reply/4``: Send HTTP response
2. ``200`` : HTTP success status code
3. ``#{<<"content-type">> => <<"text/plain">>}`` : Headers map
4. ``Found`` : Response body ("true" or "false")
5. ``{ok, Req2, Opts}`` : Handler return value

Supervisor (src/webwords_sup.erl)
---------------------------------

.. code-block:: erlang

   -module(webwords_sup).
   -behaviour(supervisor).
   
   -export([start_link/0]).
   -export([init/1]).

OTP supervisor module:
- ``-behaviour(supervisor).`` : Implements supervisor behavior
- Exports required callback functions

**Supervisor Initialization:**

.. code-block:: erlang

   start_link() ->
       supervisor:start_link({local, ?SERVER}, ?MODULE, []).

Supervisor startup:
1. ``supervisor:start_link/3`` : Start supervisor process
2. ``{local, ?SERVER}`` : Register locally with module name
3. ``?MODULE`` : Callback module (this module)
4. ``[]`` : Initial arguments

**Supervision Strategy:**

.. code-block:: erlang

   init([]) ->
       SupFlags = #{strategy => one_for_one,
                    intensity => 1,
                    period => 5},
       ChildSpecs = [],
       {ok, {SupFlags, ChildSpecs}}.

Supervisor configuration:
1. ``strategy => one_for_one`` : Restart strategy (individual children)
2. ``intensity => 1`` : Maximum restarts allowed
3. ``period => 5`` : Time window for restart counting (5 seconds)
4. ``ChildSpecs = []`` : No child processes (HTTP server managed externally)
5. Returns supervisor specification

Building and Running
====================

Step 1: Build the Docker image
------------------------------

.. code-block:: bash

   cd /home/fox/git/webwords/erlang
   docker build -t webwords-erlang .

Rebar3 will download dependencies and create OTP release during build.

Step 2: Run the container
-------------------------

.. code-block:: bash

   docker run -d -p 31337:31337 --name test-erlang webwords-erlang

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

   docker logs test-erlang

Expected output:
- "listening on 0.0.0.0:31337" on startup
- "found=true, keyword=potato, uri=https://www.remarkbox.com" for requests

Step 5: Clean up
----------------

.. code-block:: bash

   docker stop test-erlang
   docker rm test-erlang

Common Issues
=============

Rebar3 dependency compilation errors
----------------------------------

If rebar3 fails to compile dependencies during build:

.. code-block:: bash

   # Check rebar3 version and dependency resolution
   docker run -v $(pwd):/app -it erlang:25-alpine bash
   cd /app && rebar3 deps compile

Common rebar3 issues:
- Network connectivity problems downloading dependencies
- Compiler version mismatches between dependencies
- Missing system dependencies for native code compilation

OTP release creation errors
--------------------------

If ``rebar3 release`` fails:

.. code-block:: bash

   # Check release configuration
   docker run -v $(pwd):/app -it erlang:25-alpine bash
   cd /app && rebar3 as prod release

Release issues:
- Missing application dependencies in app.src
- Invalid release configuration in rebar.config
- ERTS inclusion problems

Application startup errors
-------------------------

If OTP application fails to start:

.. code-block:: bash

   # Check application logs
   docker logs test-erlang | grep -i error
   
   # Verify supervisor tree
   docker logs test-erlang | grep supervisor

Startup issues:
- Port 31337 binding failures
- Cowboy listener configuration errors
- Missing application dependencies

Pattern matching compilation warnings
-----------------------------------

If Erlang compiler emits pattern matching warnings:

.. code-block:: bash

   # Check for unused variables or incomplete patterns
   docker run -v $(pwd):/app -it erlang:25-alpine bash
   cd /app && erlc +warn_unused_vars +warn_export_all src/*.erl

Erlang pattern matching best practices:
- Use ``_`` for unused variables
- Ensure all case expressions have catch-all clauses
- Handle all possible return values from function calls

Binary handling issues
---------------------

If binary string operations fail:

.. code-block:: bash

   # Check binary string encoding
   docker logs test-erlang | grep "badarg"

Binary string handling:
- Ensure consistent UTF-8 encoding
- Use binary module functions for string operations
- Handle empty binaries (``<<>>``) appropriately

Implementation Notes
===================

This Erlang implementation demonstrates:
- **OTP Principles**: Application, supervisor, and behavior patterns
- **Fault Tolerance**: Supervision trees with restart strategies
- **Pattern Matching**: Comprehensive pattern matching for control flow
- **Binary Handling**: Efficient binary string processing
- **Concurrency**: Actor model with lightweight process communication
- **Hot Code Loading**: OTP releases support code updates without downtime

The implementation showcases Erlang's strengths in building robust, concurrent systems. The OTP framework provides battle-tested patterns for fault tolerance, while pattern matching enables elegant error handling. The release mechanism creates self-contained deployments that can run independently, demonstrating Erlang's suitability for distributed, long-running services that require high availability.