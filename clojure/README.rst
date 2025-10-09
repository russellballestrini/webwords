WebWords - Clojure Implementation
=================================

This directory contains the Clojure implementation of the WebWords service using Ring/Jetty with functional programming and JVM interoperability.

Docker Overview
===============

Our Dockerfile uses a multi-stage build optimized for Clojure/Leiningen applications:

.. code-block:: dockerfile

   FROM clojure:openjdk-11-lein as builder
   
   WORKDIR /app
   COPY project.clj .
   RUN lein deps
   
   COPY src ./src
   RUN lein uberjar
   
   FROM openjdk:11-jre-slim
   
   WORKDIR /app
   COPY --from=builder /app/target/uberjar/webwords-*-standalone.jar webwords.jar
   
   EXPOSE 31337
   
   CMD ["java", "-jar", "webwords.jar"]

**Multi-Stage Build Breakdown:**

1. **Builder Stage**: Full Clojure environment with Leiningen build tool
2. **Dependency Resolution**: ``lein deps`` downloads and caches dependencies
3. **Uberjar Creation**: ``lein uberjar`` creates self-contained JAR with all dependencies
4. **Runtime Stage**: Minimal JRE for production deployment
5. **JAR Deployment**: Single executable JAR with embedded dependencies
6. **Java Execution**: Runs compiled Clojure as standard Java application

The build leverages Leiningen's uberjar functionality to create a standalone JAR that includes all dependencies and the Clojure runtime.

Understanding the Code
======================

This Clojure implementation demonstrates functional programming with immutable data structures, JVM interoperability, and Lisp syntax.

Project Configuration (project.clj)
-----------------------------------

.. code-block:: clojure

   (defproject webwords "0.1.0"
     :description "WebWords in Clojure"
     :dependencies [[org.clojure/clojure "1.11.1"]
                    [ring/ring-core "1.9.6"]
                    [ring/ring-jetty-adapter "1.9.6"]
                    [clj-http "3.12.3"]]
     :main ^:skip-aot webwords.core
     :target-path "target/%s"
     :profiles {:uberjar {:aot :all}})

Leiningen project configuration:
- ``defproject webwords "0.1.0"``: Project name and version
- ``:dependencies [...]``: Dependency vector with coordinates
- ``[org.clojure/clojure "1.11.1"]``: Core Clojure runtime
- ``[ring/ring-core "1.9.6"]``: HTTP abstraction library
- ``[ring/ring-jetty-adapter "1.9.6"]``: Jetty web server adapter
- ``[clj-http "3.12.3"]``: HTTP client library
- ``:main ^:skip-aot webwords.core``: Entry point, skip AOT compilation
- ``:profiles {:uberjar {:aot :all}}``: Compile everything for uberjar

Main Application (src/webwords/core.clj)
---------------------------------------

**Namespace Declaration:**

.. code-block:: clojure

   (ns webwords.core
     (:require [ring.adapter.jetty :as jetty]
               [ring.util.response :as response]
               [ring.middleware.params :as params]
               [clj-http.client :as http])
     (:gen-class))

Namespace and imports:
1. ``ns webwords.core``: Declares namespace matching file path
2. ``:require [... :as ...]``: Import namespaces with aliases
3. ``ring.adapter.jetty``: Jetty server adapter
4. ``ring.util.response``: HTTP response utilities
5. ``ring.middleware.params``: Query parameter parsing middleware
6. ``clj-http.client``: HTTP client functionality
7. ``:gen-class``: Enable AOT compilation to Java classes

**HTTP Client Function:**

.. code-block:: clojure

   (defn fetch-url [url]
     (try
       (:body (http/get url {:socket-timeout 10000 :conn-timeout 10000}))
       (catch Exception e nil)))

Functional HTTP client:
1. ``defn fetch-url [url]``: Function definition with parameter vector
2. ``try ... catch``: Exception handling (similar to Java)
3. ``http/get url {...}``: HTTP GET request with timeout options
4. ``:socket-timeout 10000``: 10-second socket timeout
5. ``:conn-timeout 10000``: 10-second connection timeout
6. ``:body``: Keyword access to extract body from response map
7. ``(catch Exception e nil)``: Return nil on any exception

**Request Handler Function:**

.. code-block:: clojure

   (defn handle-request [request]
     (let [params (:query-params request)
           keyword (get params "keyword" "")
           target (get params "target" "")]

Request processing:
1. ``defn handle-request [request]``: Ring request handler function
2. ``let [...]``: Local binding form for immutable variables
3. ``(:query-params request)``: Keyword access to query parameters
4. ``get params "keyword" ""``: Extract parameter with default value
5. Immutable local bindings within let scope

**Functional Logic Processing:**

.. code-block:: clojure

   found (if (and (not-empty keyword) (not-empty target))
           (let [body (fetch-url target)]
             (if (and body (.contains body keyword))
               "true"
               "false"))
           "false")]

Nested functional logic:
1. ``if (and (not-empty keyword) (not-empty target))``: Condition with logical and
2. ``(not-empty keyword)``: Check for non-empty string
3. ``let [body (fetch-url target)]``: Nested binding for HTTP response
4. ``(.contains body keyword)``: Java interop method call
5. ``"true"`` / ``"false"``: String literals for response
6. Nested if expressions for conditional logic

**Logging and Response:**

.. code-block:: clojure

   (when (and (not-empty keyword) (not-empty target))
     (println (str "found=" found ", keyword=" keyword ", uri=" target)))
   (response/response found)))

Side effects and response:
1. ``when (and ...)``: Conditional execution without else clause
2. ``println (str ...)``: Print with string concatenation
3. ``str "found=" found``: String concatenation with values
4. ``response/response found``: Create Ring response map

**Main Function and Server Startup:**

.. code-block:: clojure

   (defn -main [& args]
     (let [port (Integer/parseInt (or (System/getenv "PORT") "31337"))]
       (println (str "listening on 0.0.0.0:" port))
       (jetty/run-jetty (params/wrap-params handle-request) {:port port :host "0.0.0.0"})))

Application entry point:
1. ``defn -main [& args]``: Main function with variadic arguments
2. ``let [port ...]``: Local binding for port configuration
3. ``Integer/parseInt``: Java interop for string to integer conversion
4. ``(or (System/getenv "PORT") "31337")``: Environment variable with default
5. ``params/wrap-params handle-request``: Middleware wrapping for parameter parsing
6. ``jetty/run-jetty ... {:port port :host "0.0.0.0"}``: Start Jetty server

Building and Running
====================

Step 1: Build the Docker image
------------------------------

.. code-block:: bash

   cd /home/fox/git/webwords/clojure
   docker build -t webwords-clojure .

Leiningen will download dependencies and create uberjar during build.

Step 2: Run the container
-------------------------

.. code-block:: bash

   docker run -d -p 31337:31337 --name test-clojure webwords-clojure

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

   docker logs test-clojure

Expected output:
- "listening on 0.0.0.0:31337" on startup
- "found=true, keyword=potato, uri=https://www.remarkbox.com" for requests

Step 5: Clean up
----------------

.. code-block:: bash

   docker stop test-clojure
   docker rm test-clojure

Common Issues
=============

Leiningen dependency resolution errors
------------------------------------

If Leiningen fails to download dependencies during build:

.. code-block:: bash

   # Check Leiningen version and dependency resolution
   docker run -v $(pwd):/app -it clojure:openjdk-11-lein bash
   cd /app && lein deps

Common dependency issues:
- Network connectivity problems downloading from Maven repositories
- Version conflicts between transitive dependencies
- Repository authentication or access problems

Clojure compilation errors
-------------------------

If Clojure compilation fails during uberjar creation:

.. code-block:: bash

   # Check compilation warnings and errors
   docker run -v $(pwd):/app -it clojure:openjdk-11-lein bash
   cd /app && lein compile

Compilation issues:
- Namespace declaration doesn't match file path
- Missing or incorrect import statements
- Syntax errors in Lisp expressions (mismatched parentheses)

JAR execution errors
-------------------

If the compiled JAR fails to run:

.. code-block:: bash

   # Check JAR contents and main class
   docker run -v $(pwd):/app -it openjdk:11-jre-slim bash
   cd /app && java -jar webwords.jar

JAR execution issues:
- Missing main class in manifest
- ClassNotFoundException for dependencies
- Port binding failures in containerized environment

Ring middleware issues
---------------------

If parameter parsing fails:

.. code-block:: bash

   # Check middleware configuration
   docker logs test-clojure | grep "keyword"

Middleware troubleshooting:
- Ensure ``params/wrap-params`` is properly applied
- Verify query parameter names match exactly
- Check middleware ordering in Ring stack

JVM interop issues
-----------------

If Java method calls fail:

.. code-block:: bash

   # Check Java interop syntax
   docker logs test-clojure | grep -i "exception"

Java interop troubleshooting:
- Use correct method call syntax: ``(.methodName object args)``
- Ensure Java classes are available on classpath
- Handle type conversions between Clojure and Java

Implementation Notes
===================

This Clojure implementation demonstrates:
- **Functional Programming**: Immutable data structures and pure functions
- **Lisp Syntax**: S-expressions and prefix notation for all operations
- **JVM Interoperability**: Seamless integration with Java ecosystem
- **Ring Abstractions**: HTTP requests and responses as simple maps
- **Middleware Composition**: Functional composition of request processing
- **REPL-Driven Development**: Interactive development and testing workflow

The implementation showcases Clojure's strengths in building web services with functional programming principles. The Ring library provides elegant abstractions over HTTP while maintaining the simplicity of working with plain data structures. The JVM integration enables access to the entire Java ecosystem while the functional approach ensures code clarity and maintainability through immutability and compositional design.
- ``{:socket-timeout 10000 :conn-timeout 10000}`` is a map of options
- ``:body`` extracts the body field from the response map
- ``nil`` is returned if any exception occurs

.. code-block:: clojure

   (defn handle-request [request]

This defines the main request handler function:
- Takes a Ring request map as parameter
- Ring is Clojure's standard web application interface

.. code-block:: clojure

   (let [params (:query-params request)
         keyword (get params "keyword" "")
         target (get params "target" "")]

This extracts query parameters using ``let`` binding:
- ``let`` creates local variable bindings
- ``:query-params`` is a keyword that extracts query parameters from the request
- ``get`` safely retrieves values from maps with defaults
- Empty strings are used as default values

.. code-block:: clojure

   found (if (and (not-empty keyword) (not-empty target))
           (let [body (fetch-url target)]
             (if (and body (.contains body keyword))
               "true"
               "false"))
           "false")]

This determines if the keyword was found:
- ``if`` is Clojure's conditional expression
- ``and`` evaluates to true only if all conditions are true
- ``not-empty`` returns the value if it's not empty, otherwise nil
- ``.contains`` calls the Java String.contains method
- Nested ``let`` creates another local binding for the fetched body
- Returns "true" or "false" as strings

.. code-block:: clojure

   (when (and (not-empty keyword) (not-empty target))
     (println (str "found=" found ", keyword=" keyword ", uri=" target)))

This conditionally logs the result:
- ``when`` executes code only if the condition is true
- ``str`` concatenates strings (like + in other languages)
- ``println`` prints to standard output

.. code-block:: clojure

   (response/response found)))

This creates and returns an HTTP response:
- ``response/response`` creates a Ring response map
- The found value becomes the response body

.. code-block:: clojure

   (defn -main [& args]

This defines the main entry point:
- ``-main`` is the conventional name for the main function
- ``[& args]`` captures command-line arguments in a list
- The ``&`` means "rest arguments" (variable number of arguments)

.. code-block:: clojure

   (println "listening on 0.0.0.0:31337")
   (jetty/run-jetty handle-request {:port 31337 :host "0.0.0.0"}))

This starts the web server:
- ``jetty/run-jetty`` starts a Jetty web server
- ``handle-request`` is passed as the request handler function
- ``{:port 31337 :host "0.0.0.0"}`` is a map of server options

Understanding the Dockerfile
-----------------------------

The Dockerfile uses a multi-stage build for efficiency:

.. code-block:: dockerfile

   FROM clojure:openjdk-11-lein as builder

This starts the **build stage**:
- ``clojure:openjdk-11-lein`` provides Clojure and Leiningen (build tool)
- ``as builder`` names this stage for later reference

.. code-block:: dockerfile

   WORKDIR /app
   COPY project.clj .
   RUN lein deps

This sets up dependencies:
- ``WORKDIR`` sets the working directory
- ``project.clj`` defines the project and its dependencies
- ``lein deps`` downloads all dependencies

.. code-block:: dockerfile

   COPY src ./src
   RUN lein uberjar

This builds the application:
- Copies source code into the container
- ``lein uberjar`` creates a standalone JAR file with all dependencies

.. code-block:: dockerfile

   FROM openjdk:11-jre-slim

This starts the **runtime stage**:
- Uses a smaller image with just the Java Runtime Environment
- ``slim`` variant has fewer packages for smaller size

.. code-block:: dockerfile

   WORKDIR /app
   COPY --from=builder /app/target/uberjar/webwords-*-standalone.jar webwords.jar

This copies the built JAR:
- ``--from=builder`` copies from the previous build stage
- Renames the JAR to a simple name

.. code-block:: dockerfile

   EXPOSE 31337

This tells Docker that our application listens on port 31337.

.. code-block:: dockerfile

   CMD ["java", "-jar", "webwords.jar"]

This specifies how to run the application.

Understanding project.clj
-------------------------

The ``project.clj`` file is Clojure's project configuration:

.. code-block:: clojure

   (defproject webwords "0.1.0"
     :description "WebWords in Clojure"

This defines project metadata:
- ``defproject`` is a Leiningen macro for project definition
- ``webwords`` is the project name
- ``"0.1.0"`` is the version

.. code-block:: clojure

   :dependencies [[org.clojure/clojure "1.11.1"]
                  [ring/ring-core "1.9.6"]
                  [ring/ring-jetty-adapter "1.9.6"]
                  [clj-http "3.12.3"]]

This lists project dependencies:
- Dependencies are vectors with group/artifact and version
- ``org.clojure/clojure`` is the core Clojure library
- ``ring/*`` provides web application infrastructure
- ``clj-http`` provides HTTP client functionality

.. code-block:: clojure

   :main ^:skip-aot webwords.core

This specifies the main namespace:
- ``:main`` tells Leiningen which namespace contains ``-main``
- ``^:skip-aot`` is metadata that skips ahead-of-time compilation

.. code-block:: clojure

   :profiles {:uberjar {:aot :all}})

This defines build profiles:
- ``:uberjar`` profile is used when building standalone JARs
- ``:aot :all`` enables ahead-of-time compilation for all namespaces

Building and Running
--------------------

To build the Docker image:

.. code-block:: bash

   cd clojure
   docker build -t webwords-clojure .

To run the container:

.. code-block:: bash

   docker run -d -p 31337:31337 webwords-clojure

To test it:

.. code-block:: bash

   curl "http://localhost:31337/?keyword=potato&target=https://www.remarkbox.com"

Common Clojure Patterns Used
----------------------------

1. **Immutable data**: All data structures are immutable by default
2. **Pure functions**: Functions without side effects that always return the same output for the same input
3. **Let bindings**: Creating local variable bindings with ``let``
4. **Maps and keywords**: Using maps for structured data and keywords for keys
5. **Thread-first/thread-last**: Using ``->`` and ``->>`` macros for data transformation
6. **Destructuring**: Extracting values from collections in function parameters

Clojure-Specific Features
-------------------------

1. **Persistent data structures**: Efficient immutable collections
2. **Sequences**: Uniform abstraction over all collections
3. **Macros**: Code that writes code, enabling domain-specific languages
4. **Multimethods**: Polymorphism based on arbitrary dispatch functions
5. **Atoms and refs**: Safe concurrency primitives for managing state
6. **Java interop**: Seamless integration with Java libraries and objects

Learning More
-------------

To learn Clojure:
1. Start with "Clojure for the Brave and True" (free online): https://www.braveclojure.com/
2. Try the official Clojure guides: https://clojure.org/guides/getting_started
3. Practice with Clojure Koans: http://clojurekoans.com/
4. Read "Programming Clojure" by Stuart Halloway
5. Explore the REPL (Read-Eval-Print Loop) for interactive development

Next Steps
----------

Try modifying this code to:
1. Add proper error handling and logging
2. Implement request caching using atoms or refs
3. Add middleware for common tasks (authentication, CORS)
4. Use core.async for asynchronous request processing
5. Add data validation using spec
6. Implement connection pooling for HTTP requests
7. Add metrics and monitoring
8. Create a ClojureScript frontend for the web interface