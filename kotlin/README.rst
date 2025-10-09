Kotlin WebWords Implementation
==============================

What is Kotlin?
----------------
Kotlin is a modern, statically-typed programming language developed by JetBrains and first released in 2011. It's fully interoperable with Java and runs on the Java Virtual Machine (JVM), but also compiles to JavaScript and native binaries. Google adopted Kotlin as a first-class language for Android development, and it's increasingly used for server-side development.

Key Kotlin concepts for beginners:
- **JVM compatible**: Runs on the Java Virtual Machine alongside Java code
- **Null safety**: Built-in protection against null pointer exceptions
- **Concise**: Less boilerplate code compared to Java
- **Functional programming**: First-class functions and lambda expressions
- **Coroutines**: Built-in support for asynchronous programming
- **Type inference**: Compiler can often deduce types automatically

Understanding the Code
----------------------

Let's break down the Kotlin implementation line by line:

.. code-block:: kotlin

   import io.ktor.client.*
   import io.ktor.client.engine.cio.*
   import io.ktor.client.request.*
   import io.ktor.client.statement.*
   import io.ktor.server.application.*
   import io.ktor.server.engine.*
   import io.ktor.server.netty.*
   import io.ktor.server.response.*
   import io.ktor.server.routing.*

These are **import statements** for the Ktor framework:
- ``io.ktor.client.*``: HTTP client functionality
- ``io.ktor.server.*``: HTTP server functionality
- Ktor is a Kotlin-native framework for building connected applications

.. code-block:: kotlin

   fun main() {

This is the **main function** - Kotlin's entry point:
- ``fun`` declares a function
- No class wrapper needed (unlike Java)
- Can be at the top level of a file

.. code-block:: kotlin

   val client = HttpClient(CIO) {
       engine {
           requestTimeout = 10000
       }
   }

This creates an **HTTP client**:
- ``val`` declares an immutable variable (like ``final`` in Java)
- ``HttpClient(CIO)`` creates a client with the CIO engine
- Curly braces contain a **configuration lambda**
- ``requestTimeout`` sets a 10-second timeout

.. code-block:: kotlin

   embeddedServer(Netty, port = 31337, host = "0.0.0.0") {

This starts an **embedded server**:
- ``embeddedServer()`` is a Ktor function
- ``Netty`` specifies the server engine
- **Named parameters** make the API clear
- Curly braces contain the server configuration

.. code-block:: kotlin

   routing {
       get("/") {

This sets up **routing**:
- ``routing`` is a DSL (Domain-Specific Language) block
- ``get("/")`` handles GET requests to the root path
- The lambda parameter will be the request handler

.. code-block:: kotlin

   val keyword = call.request.queryParameters["keyword"] ?: ""
   val target = call.request.queryParameters["target"] ?: ""

This extracts query parameters:
- ``call`` represents the current HTTP call
- ``queryParameters`` is a map of URL parameters
- ``?:`` is the **Elvis operator** - returns right side if left is null
- Equivalent to Java's null coalescing

.. code-block:: kotlin

   var found = "false"

This declares a **mutable variable**:
- ``var`` means the variable can be reassigned
- ``val`` would make it immutable
- Type is inferred as String

.. code-block:: kotlin

   if (keyword.isNotEmpty() && target.isNotEmpty()) {

This checks if parameters have values:
- ``isNotEmpty()`` is a Kotlin extension function on strings
- ``&&`` is the logical AND operator
- More expressive than checking for null and empty separately

.. code-block:: kotlin

   try {
       val response: HttpResponse = client.get(target)
       val body = response.bodyAsText()

This makes an HTTP request:
- ``try`` starts exception handling block
- ``client.get(target)`` makes an HTTP GET request
- ``: HttpResponse`` is an explicit type annotation (usually not needed)
- ``bodyAsText()`` is a **suspend function** that converts response to text

.. code-block:: kotlin

   if (body.contains(keyword)) {
       found = "true"
   }

This searches for the keyword:
- ``contains()`` is a standard library function
- More readable than Java's ``indexOf() != -1``

.. code-block:: kotlin

   println("found=$found, keyword=$keyword, uri=$target")

This logs the result:
- **String templates** with ``$variable`` syntax
- More convenient than string concatenation or formatting

.. code-block:: kotlin

   } catch (e: Exception) {
       println("Error: ${e.message}")
   }

This handles exceptions:
- ``catch`` with type annotation
- ``${e.message}`` is a **string template expression**
- Braces needed for property access

.. code-block:: kotlin

   call.respondText(found)

This sends the HTTP response:
- ``call.respondText()`` is a Ktor suspend function
- Automatically sets content type to text/plain

.. code-block:: kotlin

   }.start(wait = true)

This starts the server:
- ``.start()`` begins listening for requests
- ``wait = true`` keeps the main thread alive

Understanding Kotlin Syntax
----------------------------

**Variables:**
.. code-block:: kotlin

   val immutable = "cannot change"    // Like final in Java
   var mutable = "can change"         // Regular variable
   
   val inferred = 42                  // Type inferred as Int
   val explicit: String = "hello"     // Explicit type

**Null Safety:**
.. code-block:: kotlin

   var nullable: String? = null       // Can be null
   var notNull: String = "hello"      // Cannot be null
   
   val length = nullable?.length      // Safe call operator
   val default = nullable ?: "empty"  // Elvis operator

**Functions:**
.. code-block:: kotlin

   fun greet(name: String): String {
       return "Hello, $name!"
   }
   
   // Single expression function
   fun add(a: Int, b: Int) = a + b
   
   // Function with default parameter
   fun connect(host: String = "localhost", port: Int = 8080) { }

**Extension Functions:**
.. code-block:: kotlin

   fun String.isValidUrl(): Boolean {
       return this.startsWith("http")
   }
   
   // Usage:
   val valid = "http://example.com".isValidUrl()

Understanding build.gradle.kts
------------------------------

The build file uses **Kotlin DSL**:

.. code-block:: kotlin

   plugins {
       kotlin("jvm") version "1.8.0"
       application
   }
   
   repositories {
       mavenCentral()
   }
   
   dependencies {
       implementation("io.ktor:ktor-server-core:2.3.0")
       implementation("io.ktor:ktor-server-netty:2.3.0")
       implementation("io.ktor:ktor-client-core:2.3.0")
       implementation("io.ktor:ktor-client-cio:2.3.0")
   }

Key elements:
- **Plugins**: Add functionality to the build
- **Repositories**: Where to find dependencies
- **Dependencies**: External libraries needed

Understanding the Dockerfile
-----------------------------

The Dockerfile uses Gradle to build:

.. code-block:: dockerfile

   FROM openjdk:11-jdk-slim as builder

This creates a **builder stage** with JDK:
- Includes Kotlin compiler and Gradle

.. code-block:: dockerfile

   WORKDIR /app
   COPY . .
   RUN ./gradlew build --no-daemon

This builds the application:
- ``./gradlew`` uses the Gradle wrapper
- ``--no-daemon`` avoids leaving processes running

.. code-block:: dockerfile

   FROM openjdk:11-jre-slim

This creates the **runtime stage** with JRE only:
- Smaller final image

.. code-block:: dockerfile

   COPY --from=builder /app/build/libs/*.jar app.jar

This copies the built JAR:
- Multi-stage build keeps final image small

Building and Running
--------------------

To build the Docker image:

.. code-block:: bash

   cd kotlin
   docker build -t webwords-kotlin .

To run the container:

.. code-block:: bash

   docker run -d -p 31337:31337 webwords-kotlin

To test it:

.. code-block:: bash

   curl "http://localhost:31337/?keyword=Example&target=http://example.com"

Running Without Docker
-----------------------

You can also run this locally with Gradle:

.. code-block:: bash

   cd kotlin
   ./gradlew run           # Build and run
   ./gradlew build         # Just build

Common Kotlin Patterns Used
----------------------------

1. **Immutability by Default**: Prefer ``val`` over ``var``
2. **Null Safety**: Explicit nullable types with ``?``
3. **Extension Functions**: Add methods to existing classes
4. **Data Classes**: Automatic equals, hashCode, toString
5. **When Expressions**: Powerful pattern matching
6. **Coroutines**: Structured concurrency
7. **DSLs**: Domain-specific languages like Ktor routing

Kotlin vs Java Comparison
--------------------------

**Kotlin Advantages:**
.. code-block:: kotlin

   // Kotlin - concise and expressive
   data class User(val name: String, val email: String)
   
   fun findUsers(active: Boolean = true): List<User> {
       return users.filter { it.active == active }
   }
   
   val names = users.map { it.name }.joinToString()

**Java Equivalent:**
.. code-block:: java

   // Java - more verbose
   public class User {
       private final String name;
       private final String email;
       
       public User(String name, String email) {
           this.name = name;
           this.email = email;
       }
       
       // getters, equals, hashCode, toString...
   }
   
   public List<User> findUsers(boolean active) {
       return users.stream()
           .filter(user -> user.isActive() == active)
           .collect(Collectors.toList());
   }

Coroutines and Async Programming
--------------------------------

Kotlin coroutines make async code look synchronous:

.. code-block:: kotlin

   // Without coroutines (callback hell)
   httpClient.get(url) { response ->
       parseResponse(response) { data ->
           saveToDatabase(data) { result ->
               // Nested callbacks
           }
       }
   }
   
   // With coroutines (sequential style)
   suspend fun processData(url: String) {
       val response = httpClient.get(url)        // Suspending
       val data = parseResponse(response)        // Suspending
       val result = saveToDatabase(data)         // Suspending
       return result
   }

Advanced Kotlin Features
-------------------------

**Sealed Classes** (for type-safe state):
.. code-block:: kotlin

   sealed class Result<T> {
       data class Success<T>(val data: T) : Result<T>()
       data class Error<T>(val exception: Exception) : Result<T>()
   }

**Inline Functions** (zero-cost abstractions):
.. code-block:: kotlin

   inline fun <T> measureTime(action: () -> T): T {
       val start = System.currentTimeMillis()
       val result = action()
       println("Time: ${System.currentTimeMillis() - start}ms")
       return result
   }

**Delegation** (composition over inheritance):
.. code-block:: kotlin

   class LoggingHttpClient(
       private val client: HttpClient
   ) : HttpClient by client {
       override suspend fun get(url: String): HttpResponse {
           println("Making request to $url")
           return client.get(url)
       }
   }

Learning More
-------------

To learn Kotlin:
1. Start with Kotlin Koans: https://kotlinlang.org/docs/koans.html
2. Official Kotlin documentation: https://kotlinlang.org/docs/
3. Learn Ktor framework: https://ktor.io/docs/
4. Practice Android development with Kotlin
5. Explore coroutines for async programming

Next Steps
----------

Try modifying this code to:
1. Add comprehensive error handling with sealed classes
2. Add structured logging with a logging framework
3. Add input validation and sanitization
4. Add configuration via environment variables
5. Add health check and metrics endpoints
6. Add database integration with Exposed or Room
7. Add authentication with Ktor Auth
8. Add unit tests with JUnit 5 and MockK
9. Add OpenAPI documentation
10. Deploy to cloud platforms like Google Cloud or AWS