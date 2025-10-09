WebWords - Scala Implementation
==============================

This directory contains the Scala implementation of the WebWords service using Akka HTTP framework with functional programming patterns and reactive streams.

Docker Overview
===============

Our Dockerfile uses a multi-stage build optimized for Scala/SBT applications:

.. code-block:: dockerfile

   FROM openjdk:11-jdk-slim as builder
   
   # Install SBT
   RUN apt-get update && apt-get install -y curl gnupg2 && \
       curl -L "https://github.com/sbt/sbt/releases/download/v1.7.1/sbt-1.7.1.tgz" | tar -xz -C /opt && \
       ln -s /opt/sbt/bin/sbt /usr/local/bin/sbt
   
   WORKDIR /app
   COPY build.sbt .
   COPY project ./project
   COPY src ./src
   RUN sbt clean compile stage
   
   FROM openjdk:11-jre-slim
   
   WORKDIR /app
   COPY --from=builder /app/target/universal/stage .
   
   EXPOSE 31337
   
   CMD ["bin/webwords"]

**Multi-Stage Build Breakdown:**

1. **Builder Stage**: Full JDK with SBT for compilation and dependency resolution
2. **SBT Installation**: Downloads and installs SBT build tool from GitHub
3. **Dependency Caching**: COPY order optimizes Docker layer caching for dependencies
4. **Stage Command**: ``sbt stage`` creates deployable application with all dependencies
5. **Runtime Stage**: Minimal JRE for production deployment
6. **Universal Package**: Native packager plugin creates launcher scripts

The build leverages SBT's native packager plugin to create a self-contained application with startup scripts, eliminating the need to run ``sbt`` in production.

Understanding the Code
======================

This Scala implementation demonstrates functional programming with Akka HTTP, showcasing immutability, pattern matching, futures, and reactive streams.

Build Configuration (build.sbt)
-------------------------------

.. code-block:: scala

   ThisBuild / scalaVersion := "2.13.10"
   ThisBuild / version := "0.1.0"
   
   lazy val root = (project in file("."))
     .enablePlugins(JavaAppPackaging)
     .settings(
       name := "webwords",
       mainClass := Some("WebWords"),
       libraryDependencies ++= Seq(
         "com.typesafe.akka" %% "akka-http" % "10.5.0",
         "com.typesafe.akka" %% "akka-stream" % "2.8.0",
         "com.typesafe.akka" %% "akka-actor-typed" % "2.8.0",
         "com.typesafe.akka" %% "akka-http-spray-json" % "10.5.0"
       )
     )

SBT configuration:
- ``ThisBuild / scalaVersion := "2.13.10"``: Scala version for all modules
- ``enablePlugins(JavaAppPackaging)``: Enables native packager for deployable apps
- ``mainClass := Some("WebWords")``: Entry point for application
- ``%% "akka-http"``: Cross-built Scala dependency notation
- Akka HTTP stack for reactive web services

Plugin Configuration (project/plugins.sbt)
------------------------------------------

.. code-block:: scala

   addSbtPlugin("com.github.sbt" % "sbt-native-packager" % "1.9.11")

- ``sbt-native-packager``: Creates platform-specific packages and launcher scripts
- Version 1.9.11: Fixed version for reproducible builds
- Enables ``sbt stage`` command for deployment packaging

Main Application (WebWords.scala)
---------------------------------

**Imports and Actor System Setup:**

.. code-block:: scala

   import akka.actor.typed.ActorSystem
   import akka.actor.typed.scaladsl.Behaviors
   import akka.http.scaladsl.Http
   import akka.http.scaladsl.model._
   import akka.http.scaladsl.server.Directives._
   import akka.http.scaladsl.server.Route
   import scala.concurrent.Future
   import scala.util.{Failure, Success}

Akka HTTP imports:
- ``ActorSystem``: Core Akka concurrency primitive
- ``Http``: HTTP client and server functionality
- ``Directives._``: DSL for HTTP routing
- ``Future``: Asynchronous computation container
- ``Success/Failure``: Pattern matching for Try/Future results

**Actor System Initialization:**

.. code-block:: scala

   object WebWords extends App {
     implicit val system = ActorSystem(Behaviors.empty, "webwords-system")
     implicit val executionContext = system.executionContext

Object and implicits:
1. ``object WebWords extends App``: Singleton object with main method
2. ``implicit val system``: Actor system for Akka infrastructure
3. ``Behaviors.empty``: Minimal actor behavior (not used for HTTP)
4. ``implicit val executionContext``: Thread pool for Future operations

**HTTP Route Definition:**

.. code-block:: scala

   val route: Route =
     path("") {
       get {
         parameters("keyword".?, "target".?) { (keyword, target) =>
           complete {
             (keyword, target) match {
               case (Some(k), Some(t)) if k.nonEmpty && t.nonEmpty =>
                 fetchAndCheck(k, t)
               case _ =>
                 Future.successful("false")
             }
           }
         }
       }
     }

Akka HTTP routing DSL:
1. ``path("")``: Matches root path "/"
2. ``get``: HTTP GET method directive
3. ``parameters("keyword".?, "target".?)``: Optional query parameters
4. Pattern matching with guards: ``case (Some(k), Some(t)) if k.nonEmpty``
5. ``complete``: Directive to complete HTTP response
6. ``Future.successful("false")``: Immediate future for invalid parameters

**HTTP Client and Processing:**

.. code-block:: scala

   def fetchAndCheck(keyword: String, target: String): Future[String] = {
     Http().singleRequest(HttpRequest(uri = target))
       .flatMap(_.entity.toStrict(scala.concurrent.duration.Duration(10, "seconds")))
       .map { entity =>
         val body = entity.data.utf8String
         val found = if (body.contains(keyword)) "true" else "false"
         println(s"found=$found, keyword=$keyword, uri=$target")
         found
       }
       .recover {
         case ex =>
           println(s"Error: ${ex.getMessage}")
           "false"
       }
   }

Functional HTTP processing:
1. ``Http().singleRequest(HttpRequest(uri = target))``: Async HTTP client call
2. ``flatMap(_.entity.toStrict(...))``: Stream entity to strict (in-memory) entity
3. ``Duration(10, "seconds")``: Timeout for entity materialization
4. ``map { entity => ... }``: Transform response entity
5. ``entity.data.utf8String``: Extract UTF-8 string from ByteString
6. ``recover { case ex => ... }``: Error handling with partial function

**Server Binding and Startup:**

.. code-block:: scala

   val bindingFuture = Http().newServerAt("0.0.0.0", 31337).bind(route)
   
   bindingFuture.onComplete {
     case Success(binding) =>
       println(s"listening on 0.0.0.0:31337")
     case Failure(exception) =>
       println(s"Server binding failed with ${exception.getMessage}")
       system.terminate()
   }

Server lifecycle:
1. ``Http().newServerAt("0.0.0.0", 31337)``: HTTP server builder
2. ``.bind(route)``: Bind route to server, returns Future[ServerBinding]
3. ``onComplete``: Callback for Future completion
4. Pattern matching on ``Success/Failure``
5. ``system.terminate()``: Graceful shutdown on binding failure

Building and Running
====================

Step 1: Build the Docker image
------------------------------

.. code-block:: bash

   cd /home/fox/git/webwords/scala
   docker build -t webwords-scala .

SBT will download dependencies and compile Scala source during build.

Step 2: Run the container
-------------------------

.. code-block:: bash

   docker run -d -p 31337:31337 --name test-scala webwords-scala

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

   docker logs test-scala

Expected output:
- "listening on 0.0.0.0:31337" on startup
- "found=true, keyword=potato, uri=https://www.remarkbox.com" for requests

Step 5: Clean up
----------------

.. code-block:: bash

   docker stop test-scala
   docker rm test-scala

Common Issues
=============

SBT dependency resolution errors
------------------------------

If SBT fails to resolve dependencies during Docker build:

.. code-block:: bash

   # Check SBT version and dependency resolution
   docker run -v $(pwd):/app -it openjdk:11-jdk-slim bash
   cd /app && sbt clean compile

Common SBT issues:
- Network connectivity problems downloading dependencies
- Version conflicts between Akka modules
- Scala binary version mismatches (%%% vs %%)

Akka HTTP binding errors
-----------------------

If server fails to bind to port 31337:

.. code-block:: bash

   # Check if port is already in use
   docker logs test-scala | grep "binding failed"
   netstat -ln | grep 31337

Binding issues:
- Port already in use by another process
- Insufficient permissions for port binding
- Network interface configuration problems

Memory issues during build
-------------------------

If SBT runs out of memory during compilation:

.. code-block:: dockerfile

   # Add JVM memory options to Dockerfile
   ENV SBT_OPTS="-Xmx2g -XX:+UseConcMarkSweepGC"
   RUN sbt clean compile stage

Large Scala/Akka applications may require more heap space.

Pattern matching compilation errors
---------------------------------

If Scala compilation fails with pattern matching errors:

.. code-block:: bash

   # Check for exhaustive pattern matching
   sbt "set scalacOptions += \"-Wconf:msg=match may not be exhaustive:e\"" compile

Scala requires exhaustive pattern matching or explicit catch-all cases.

Actor system termination issues
------------------------------

If application doesn't shut down gracefully:

.. code-block:: scala

   // Add proper shutdown hook
   Runtime.getRuntime.addShutdownHook(new Thread(() => {
     system.terminate()
   }))

Akka actor systems need explicit termination for clean shutdown.

Implementation Notes
===================

This Scala implementation demonstrates:
- **Functional Programming**: Immutable data structures and higher-order functions
- **Reactive Streams**: Akka HTTP's stream-based request/response processing
- **Pattern Matching**: Scala's powerful pattern matching for control flow
- **Future Composition**: Asynchronous programming with flatMap/map/recover
- **Type Safety**: Strong static typing with type inference
- **DSL Design**: Akka HTTP's internal DSL for routing

The implementation showcases Scala's strengths in building concurrent, reactive applications with functional programming paradigms. The Akka HTTP framework provides a high-level, type-safe abstraction over HTTP while maintaining the performance characteristics needed for web services. The code demonstrates idiomatic Scala patterns including pattern matching, future composition, and implicit parameter resolution.