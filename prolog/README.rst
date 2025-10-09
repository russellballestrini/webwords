WebWords - Prolog Implementation
================================

This directory contains the Prolog implementation of the WebWords service using SWI-Prolog's built-in HTTP server libraries.

Docker Overview
---------------

Our Docker implementation leverages SWI-Prolog's powerful HTTP server capabilities:

.. code-block:: dockerfile

   FROM swipl:latest
   
   WORKDIR /app
   COPY webwords.pl .
   
   # Install curl for HTTP requests
   RUN apt-get update && apt-get install -y curl ca-certificates && rm -rf /var/lib/apt/lists/*
   
   EXPOSE 31337
   
   CMD ["swipl", "-s", "webwords.pl", "-g", "main", "-t", "halt"]

The implementation uses SWI-Prolog's native HTTP capabilities:

1. **Base Image**: Official SWI-Prolog Docker image with full libraries
2. **HTTP Server**: Built-in ``library(http/thread_httpd)`` for concurrent requests
3. **HTTP Dispatch**: ``library(http/http_dispatch)`` for URL routing
4. **Parameter Parsing**: ``library(http/http_parameters)`` for query string handling
5. **HTTP Client**: ``library(http/http_client)`` for external URL fetching

Prolog Language Fundamentals
----------------------------

Prolog (Programming in Logic) is a declarative programming language based on formal logic:

**Key Characteristics:**

- **Paradigm**: Logic programming and declarative programming
- **Age**: Developed in 1972, continuously evolved for AI and knowledge systems
- **Execution**: Pattern matching, unification, and backtracking
- **Data**: Facts, rules, and queries form the knowledge base
- **Reasoning**: Automatic inference and logical deduction
- **Non-deterministic**: Can explore multiple solution paths

**Why Prolog for WebWords:**

Prolog excels at:

- **Pattern Matching**: Excellent for parsing and matching text patterns
- **Rule-Based Logic**: Natural for implementing business rules
- **HTTP Libraries**: SWI-Prolog has comprehensive web server libraries
- **String Processing**: Built-in predicates for text manipulation
- **Concurrent Processing**: Thread-based HTTP server for multiple requests

**Prolog vs Other Languages:**

- **Declarative**: "What" rather than "how" - describe the problem, not the algorithm
- **Facts and Rules**: ``likes(mary, food).`` vs ``if (mary.likes(food))``
- **Queries**: ``?- likes(mary, What).`` finds all things mary likes
- **Backtracking**: Automatically explores alternative solutions
- **Unification**: Pattern matching with variable binding

**Prolog Concepts:**

- **Facts**: ``webwords_port(31337).`` - declares known information
- **Rules**: ``valid_request(R) :- has_keyword(R), has_target(R).`` - conditional logic
- **Queries**: ``?- valid_request(request1).`` - asks questions about the knowledge base
- **Variables**: Start with uppercase (``X``, ``Keyword``, ``Target``)
- **Atoms**: Lowercase constants (``true``, ``false``, ``potato``)

HTTP Server Architecture
------------------------

**SWI-Prolog HTTP Server Stack:**

.. code-block:: text

   ┌─────────────────┐
   │  HTTP Client    │ (curl request)
   └─────────┬───────┘
             │
   ┌─────────▼───────┐
   │ SWI-Prolog HTTP│ (thread_httpd server)
   └─────────┬───────┘
             │
   ┌─────────▼───────┐
   │ HTTP Dispatch   │ (URL routing)
   └─────────┬───────┘
             │
   ┌─────────▼───────┐
   │ Request Handler │ (webwords_handler/1)
   └─────────┬───────┘
             │
   ┌─────────▼───────┐
   │ HTTP Client     │ (fetch external URLs)
   └─────────────────┘

**Component Responsibilities:**

1. **thread_httpd**: Multi-threaded HTTP server listening on port 31337
2. **http_dispatch**: Routes requests to appropriate handlers based on URL paths
3. **http_parameters**: Extracts and validates query string parameters
4. **webwords_handler**: Implements business logic for keyword searching
5. **http_client**: Fetches content from external URLs
6. **Thread Management**: Automatic handling of concurrent requests

**Why Pure Prolog:**

Unlike other implementations that require wrapper scripts, Prolog can handle the entire HTTP stack natively:

- **Native HTTP**: No external servers or proxies needed
- **Concurrent**: Built-in threading for multiple simultaneous requests
- **Robust**: Production-quality HTTP server used in real applications
- **Integrated**: All functionality in a single Prolog program

Prolog Program Structure
------------------------

**Module System and Imports:**

.. code-block:: prolog

   % Prolog WebWords Implementation
   % This uses SWI-Prolog's HTTP server library
   
   :- use_module(library(http/thread_httpd)).
   :- use_module(library(http/http_dispatch)).
   :- use_module(library(http/http_parameters)).
   :- use_module(library(http/http_client)).
   :- use_module(library(http/http_open)).

**HTTP Route Declaration:**

.. code-block:: prolog

   % Define the HTTP route
   :- http_handler('/', webwords_handler, []).

This declares that all requests to the root path ``/`` should be handled by the ``webwords_handler/1`` predicate.

**Main Server Predicate:**

.. code-block:: prolog

   % Main predicate to start the server
   main :-
       write('listening on 0.0.0.0:31337'), nl,
       http_server(http_dispatch, [port(31337), bind_address('0.0.0.0')]),
       % Keep the server running
       thread_get_message(_).

**Key Features:**

- **Directives**: ``:- use_module`` loads required libraries
- **Facts**: ``:- http_handler`` declares URL routing
- **Rules**: ``main :-`` defines server startup logic
- **Built-ins**: ``write/1``, ``nl/0`` for output, ``thread_get_message/1`` for waiting

Request Processing Logic
------------------------

**HTTP Parameter Extraction:**

.. code-block:: prolog

   % HTTP request handler
   webwords_handler(Request) :-
       http_parameters(Request, [
           keyword(Keyword, [optional(true), default('')]),
           target(Target, [optional(true), default('')])
       ]),

**Parameter Processing Features:**

- **Type Safety**: Automatic parameter validation
- **Default Values**: Graceful handling of missing parameters
- **Optional Parameters**: No errors for missing query parameters
- **URL Decoding**: Automatic handling of URL-encoded values

**Business Logic Implementation:**

.. code-block:: prolog

   % Check if both parameters are provided
   (   (Keyword \= '', Target \= '') ->
       % Attempt to fetch the target URL
       catch(
           (
               http_get(Target, Body, []),
               % Check if keyword is in the body
               (   sub_string(Body, _, _, _, Keyword) ->
                   Found = 'true'
               ;   Found = 'false'
               ),
               format(user_error, 'found=~w, keyword=~w, uri=~w~n', [Found, Keyword, Target])
           ),
           Error,
           (
               format(user_error, 'Error fetching ~w: ~w~n', [Target, Error]),
               Found = 'false'
           )
       )
   ;   Found = 'false'
   ),

**Logic Programming Features:**

- **Conditional Logic**: ``(condition -> then_part ; else_part)`` structure
- **Pattern Matching**: ``sub_string/5`` for keyword searching
- **Exception Handling**: ``catch/3`` for robust error handling
- **Variable Unification**: ``Found = 'true'`` binds variables
- **Deterministic Choice**: ``->`` creates if-then-else determinism

**HTTP Response Generation:**

.. code-block:: prolog

   % Send HTTP response
   format('Content-Type: text/plain~n~n'),
   write(Found).

String Processing and Pattern Matching
---------------------------------------

**Prolog String Operations:**

.. code-block:: prolog

   % Check if keyword exists in body text
   sub_string(Body, _, _, _, Keyword)

**sub_string/5 Predicate:**

- **Arguments**: ``sub_string(+String, ?Before, ?Length, ?After, ?SubString)``
- **Mode**: ``+`` = input, ``?`` = input/output, ``-`` = output only
- **Functionality**: Succeeds if SubString appears in String
- **Flexibility**: Can find position, length, or just test existence

**Example Usage:**

.. code-block:: prolog

   ?- sub_string('hello world', Before, Length, After, 'world').
   Before = 6,
   Length = 5,  
   After = 0.
   
   ?- sub_string('hello world', _, _, _, 'world').
   true.
   
   ?- sub_string('hello world', _, _, _, 'xyz').
   false.

**Advanced String Processing:**

.. code-block:: prolog

   % Case-insensitive matching
   downcase_atom(Keyword, LowerKeyword),
   downcase_atom(Body, LowerBody),
   sub_string(LowerBody, _, _, _, LowerKeyword)
   
   % Regular expressions
   re_match('\\d+', String, [])  % Match digits
   
   % Atom/string conversion
   atom_string(AtomKeyword, StringKeyword)

HTTP Client Implementation
--------------------------

**External URL Fetching:**

.. code-block:: prolog

   http_get(Target, Body, [])

**http_get/3 Predicate:**

- **Target**: URL to fetch (atom or string)
- **Body**: Retrieved content (unified with response body)
- **Options**: List of options for request customization

**Advanced HTTP Options:**

.. code-block:: prolog

   % With custom headers and timeout
   http_get(Target, Body, [
       request_header('User-Agent'='Prolog-WebWords/1.0'),
       timeout(10),
       cert_verify_hook(cert_accept_any)
   ])

**Error Handling:**

.. code-block:: prolog

   catch(
       http_get(Target, Body, []),
       Error,
       (
           format(user_error, 'HTTP Error: ~w~n', [Error]),
           Body = ''  % Default to empty on error
       )
   )

**Common HTTP Errors:**

- **Network errors**: Connection timeout, DNS resolution failure
- **HTTP errors**: 404 Not Found, 500 Internal Server Error  
- **SSL errors**: Certificate validation, protocol mismatch
- **Prolog errors**: Invalid URL format, resource exhaustion

Build and Test Process
----------------------

**Building the Application:**

.. code-block:: bash

   # Navigate to Prolog directory
   cd /home/fox/git/webwords/prolog
   
   # Build Docker image
   docker build -t webwords-prolog .
   
   # Run container
   docker run -d -p 31337:31337 --name prolog-server webwords-prolog

**Testing the Service:**

.. code-block:: bash

   # Test positive case (keyword found)
   curl "http://localhost:31337/?keyword=potato&target=https://www.remarkbox.com"
   # Expected output: true
   
   # Test negative case (keyword not found)
   curl "http://localhost:31337/?keyword=lemon&target=https://www.remarkbox.com"
   # Expected output: false

**Interactive Testing:**

.. code-block:: bash

   # Access SWI-Prolog interactive shell
   docker exec -it prolog-server swipl
   
   # Test predicates manually
   ?- use_module(library(http/http_client)).
   ?- http_get('https://www.remarkbox.com', Body, []).
   ?- sub_string(Body, _, _, _, 'potato').

**Debugging Prolog Code:**

.. code-block:: prolog

   % Add debug output
   format(user_error, 'DEBUG: Keyword=~w, Target=~w~n', [Keyword, Target]).
   
   % Trace execution
   ?- trace.
   ?- webwords_handler(request).
   
   % Check variable bindings
   ?- Keyword = 'test', format('Keyword is: ~w~n', [Keyword]).

**Expected Log Output:**
::

   listening on 0.0.0.0:31337
   % Started server at http://localhost:31337/
   found=true, keyword=potato, uri=https://www.remarkbox.com
   found=false, keyword=lemon, uri=https://www.remarkbox.com

Troubleshooting Common Issues
-----------------------------

**Prolog Syntax Errors:**

*Problem*: ``ERROR: Syntax error: Unexpected end of file``

*Solution*: Missing period at end of clauses
::

   % Incorrect (missing period)
   main :- start_server
   
   % Correct
   main :- start_server.

*Problem*: ``ERROR: Unknown procedure: http_server/2``

*Solution*: Missing module import
::

   % Add required modules
   :- use_module(library(http/thread_httpd)).

**Runtime Issues:**

*Problem*: ``ERROR: Socket error: Address already in use``

*Solution*: Port 31337 already occupied
::

   # Check what's using the port
   netstat -tulpn | grep 31337
   
   # Kill existing process or use different port
   docker stop existing-container

*Problem*: ``ERROR: SSL negotiation failed``

*Solution*: HTTPS certificate issues
::

   % Add certificate verification options
   http_get(Target, Body, [cert_verify_hook(cert_accept_any)])

**Logic Programming Issues:**

*Problem*: Predicate succeeds but returns wrong results

*Solution*: Check variable unification and scope
::

   % Debug variable bindings
   format(user_error, 'Variable X = ~w~n', [X]).
   
   % Check if variables are properly unified
   (var(X) -> format('X is unbound~n', []) ; format('X = ~w~n', [X]))

*Problem*: Non-deterministic behavior

*Solution*: Add cuts (!) for deterministic execution
::

   % Without cut - may backtrack
   process_request(Req) :- valid_request(Req), handle_request(Req).
   
   % With cut - deterministic
   process_request(Req) :- valid_request(Req), !, handle_request(Req).

**HTTP Server Issues:**

*Problem*: Server starts but doesn't respond to requests

*Solution*: Check thread management and server loop
::

   % Ensure server keeps running
   main :-
       http_server(http_dispatch, [port(31337)]),
       thread_get_message(_).  % Wait indefinitely

Advanced Prolog Features
------------------------

**Constraint Logic Programming:**

.. code-block:: prolog

   % CLP(FD) for finite domain constraints
   :- use_module(library(clpfd)).
   
   % Example: scheduling constraints
   task_schedule(Tasks, Schedule) :-
       Tasks ins 1..10,  % Domain constraint
       all_different(Tasks),  % Uniqueness constraint
       Schedule = Tasks.

**Definite Clause Grammars (DCG):**

.. code-block:: prolog

   % Parse HTTP request lines
   http_request_line(Method, Path, Version) -->
       method(Method), " ",
       path(Path), " ", 
       version(Version), "\r\n".
   
   method(get) --> "GET".
   method(post) --> "POST".

**Meta-Programming:**

.. code-block:: prolog

   % Dynamic predicate modification
   :- dynamic(cached_response/2).
   
   % Add facts at runtime
   cache_response(URL, Body) :-
       assertz(cached_response(URL, Body)).

**Concurrent Programming:**

.. code-block:: prolog

   % Create background threads
   concurrent_fetch(URLs, Results) :-
       concurrent_maplist(fetch_url, URLs, Results).
   
   fetch_url(URL, Body) :-
       http_get(URL, Body, []).

Performance Considerations
--------------------------

**SWI-Prolog HTTP Server Performance:**

- **Threading**: Each request handled in separate thread
- **Connection Pooling**: Reuses connections for efficiency
- **Memory Management**: Automatic garbage collection
- **Caching**: Can implement response caching with dynamic predicates

**Optimization Strategies:**

.. code-block:: prolog

   % Indexing for fast lookups
   :- dynamic(url_cache/2).
   :- index(url_cache(1, 0)).  % Index on first argument
   
   % Deterministic predicates
   find_keyword(Body, Keyword, true) :-
       sub_string(Body, _, _, _, Keyword), !.
   find_keyword(_, _, false).

**Memory Management:**

.. code-block:: prolog

   % Clean up large data structures
   process_large_response(Body) :-
       process_content(Body),
       garbage_collect.  % Force garbage collection

Real-World Prolog Applications
------------------------------

**Expert Systems:**

- Medical diagnosis systems
- Legal reasoning systems
- Financial rule engines
- Configuration management

**Natural Language Processing:**

- Parse tree generation
- Semantic analysis
- Machine translation
- Question-answering systems

**AI and Machine Learning:**

- Knowledge representation
- Automated reasoning
- Logic-based learning
- Constraint satisfaction

**Web Applications:**

- SWI-Prolog web framework
- Logic-based web services
- Rule-driven content management
- Semantic web applications

Further Learning Resources
--------------------------

**SWI-Prolog Documentation:**

- SWI-Prolog Manual: https://www.swi-prolog.org/pldoc/doc_for?object=manual
- HTTP Libraries: https://www.swi-prolog.org/pldoc/doc_for?object=section(%27packages/http.html%27)
- Web Applications: https://www.swi-prolog.org/howto/http/

**Prolog Language:**

- Learn Prolog Now!: http://www.learnprolognow.org/
- The Art of Prolog: Classic textbook by Sterling and Shapiro
- Programming in Prolog: Clocksin and Mellish

**Logic Programming:**

- Constraint Logic Programming: https://sicstus.sics.se/sicstus/docs/3.7.1/html/sicstus_6.html
- Definite Clause Grammars: https://www.swi-prolog.org/pldoc/man?section=DCG
- Meta-programming: https://www.swi-prolog.org/pldoc/man?section=metapred

**Community and Tools:**

- SWI-Prolog Discourse: https://swi-prolog.discourse.group/
- Stack Overflow Prolog Tag: Active community for Q&A
- GitHub SWI-Prolog: https://github.com/SWI-Prolog/swipl-devel

**Advanced Topics:**

- Constraint Handling Rules (CHR)
- Tabled execution (SLG resolution)
- Coroutining and when/2
- Multi-threading and synchronization

This Prolog implementation demonstrates how declarative logic programming can elegantly handle web service requirements while leveraging the language's strengths in pattern matching, rule-based reasoning, and built-in HTTP server capabilities.