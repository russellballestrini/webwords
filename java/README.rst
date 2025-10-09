WebWords - Java Implementation
==============================

This directory contains the Java implementation of the WebWords service using Java's built-in HttpServer and HttpURLConnection classes from the standard library.

Docker Overview
===============

Our Dockerfile uses OpenJDK 17 with a simple compilation and execution setup:

.. code-block:: dockerfile

   FROM openjdk:17-jdk-slim
   
   WORKDIR /app
   
   COPY WebWords.java .
   
   RUN javac WebWords.java
   
   EXPOSE 31337
   
   CMD ["java", "WebWords"]

**Dockerfile Breakdown:**
- ``FROM openjdk:17-jdk-slim``: Use OpenJDK 17 with slim Debian base (~400MB)
- ``WORKDIR /app``: Set working directory for compilation and execution
- ``COPY WebWords.java .``: Copy the single Java source file
- ``RUN javac WebWords.java``: Compile Java source to bytecode (.class file)
- ``CMD ["java", "WebWords"]``: Run the compiled class using Java Virtual Machine

Understanding the Code
======================

This Java implementation uses only JDK standard library components, demonstrating Java's built-in HTTP server capabilities and URL handling without external dependencies.

Main Class Structure
-------------------

**Package Declaration and Imports:**

.. code-block:: java

   import com.sun.net.httpserver.HttpExchange;
   import com.sun.net.httpserver.HttpHandler;
   import com.sun.net.httpserver.HttpServer;
   import java.io.*;
   import java.net.*;
   import java.util.Map;
   import java.util.HashMap;

- ``com.sun.net.httpserver.*``: Built-in HTTP server classes (part of JDK)
- ``java.io.*``: Input/output streams for reading HTTP responses
- ``java.net.*``: Networking classes for URL connections
- ``java.util.*``: Collections framework for HashMap

**Main Method and Server Setup:**

.. code-block:: java

   public static void main(String[] args) throws Exception {
       HttpServer server = HttpServer.create(new InetSocketAddress(31337), 0);
       server.createContext("/", new MyHandler());
       server.setExecutor(null);
       System.out.println("listening on 0.0.0.0:31337");
       server.start();
   }

Server initialization:
1. ``HttpServer.create(new InetSocketAddress(31337), 0)``: Create HTTP server on port 31337
2. ``server.createContext("/", new MyHandler())``: Map root path to handler class
3. ``server.setExecutor(null)``: Use default executor (creates thread pool automatically)
4. ``server.start()``: Start accepting requests

Request Handler Implementation
-----------------------------

**Handler Class Declaration:**

.. code-block:: java

   static class MyHandler implements HttpHandler {
       @Override
       public void handle(HttpExchange t) throws IOException {

- ``static class MyHandler``: Inner class for handling HTTP requests
- ``implements HttpHandler``: Standard interface for HTTP request processing
- ``HttpExchange t``: Object containing request and response information

**Query Parameter Extraction:**

.. code-block:: java

   String query = t.getRequestURI().getQuery();
   Map<String, String> params = parseQuery(query);
   
   String keyword = params.get("keyword");
   String target = params.get("target");

Parameter processing:
1. ``t.getRequestURI().getQuery()``: Extract query string from request URI
2. ``parseQuery(query)``: Custom method to parse query string into Map
3. ``params.get("keyword")``: Extract individual parameters by name

**HTTP Client Request:**

.. code-block:: java

   URL url = new URL(target);
   HttpURLConnection conn = (HttpURLConnection) url.openConnection();
   conn.setRequestMethod("GET");
   conn.setConnectTimeout(10000);
   conn.setReadTimeout(10000);

HTTP connection setup:
1. ``new URL(target)``: Create URL object from target string
2. ``url.openConnection()``: Open connection to the URL
3. ``setConnectTimeout(10000)``: 10-second connection timeout
4. ``setReadTimeout(10000)``: 10-second read timeout

**Response Reading:**

.. code-block:: java

   BufferedReader reader = new BufferedReader(new InputStreamReader(conn.getInputStream()));
   StringBuilder response = new StringBuilder();
   String line;
   
   while ((line = reader.readLine()) != null) {
       response.append(line);
   }
   reader.close();

Response processing:
1. ``BufferedReader``: Efficient line-by-line reading
2. ``InputStreamReader(conn.getInputStream())``: Convert byte stream to character stream
3. ``StringBuilder``: Efficient string concatenation
4. Read entire response into memory for keyword search

**Keyword Search and Response:**

.. code-block:: java

   if (response.toString().contains(keyword)) {
       found = "true";
   }
   
   System.out.printf("found=%s, keyword=%s, uri=%s%n", found, keyword, target);
   
   t.sendResponseHeaders(200, found.length());
   OutputStream os = t.getResponseBody();
   os.write(found.getBytes());
   os.close();

Response handling:
1. ``response.toString().contains(keyword)``: Simple substring search
2. ``System.out.printf(...)``: Log request details to stdout
3. ``t.sendResponseHeaders(200, found.length())``: Send HTTP 200 status with content length
4. ``os.write(found.getBytes())``: Write response body as bytes

**Query String Parser:**

.. code-block:: java

   private Map<String, String> parseQuery(String query) {
       Map<String, String> result = new HashMap<>();
       if (query != null) {
           for (String param : query.split("&")) {
               String[] entry = param.split("=");
               if (entry.length > 1) {
                   result.put(URLDecoder.decode(entry[0], "UTF-8"), 
                             URLDecoder.decode(entry[1], "UTF-8"));

Custom query parser:
1. Split query string by "&" to get individual parameters
2. Split each parameter by "=" to get key-value pairs
3. ``URLDecoder.decode(..., "UTF-8")``: Properly decode URL-encoded values
4. Return HashMap for easy parameter lookup

Building and Running
====================

Step 1: Build the Docker image
------------------------------

.. code-block:: bash

   cd /home/fox/git/webwords/java
   docker build -t webwords-java .

Step 2: Run the container
-------------------------

.. code-block:: bash

   docker run -d -p 31337:31337 --name test-java webwords-java

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

   docker logs test-java

Expected output:
- "listening on 0.0.0.0:31337" on startup
- "found=true, keyword=potato, uri=https://www.remarkbox.com" for requests

Step 5: Clean up
----------------

.. code-block:: bash

   docker stop test-java
   docker rm test-java

Common Issues
=============

Java compilation errors
-----------------------

If compilation fails during Docker build:

.. code-block:: bash

   # Check Java version
   docker run -it openjdk:17-jdk-slim bash
   java -version
   javac -version

Common Java issues:
- Missing import statements
- Incorrect class name (must match filename)
- Syntax errors in Java code

SSL/HTTPS connection issues
--------------------------

If HTTPS requests fail with SSL errors:
- Java includes SSL support by default
- No additional SSL configuration needed
- Connection timeouts are set to 10 seconds

Memory and performance issues
----------------------------

If you see OutOfMemoryError:
- Java loads entire HTTP response into memory
- Large responses can cause memory issues
- Consider using streaming for production implementations

HTTP server binding issues
-------------------------

If the server fails to start:
- Check port 31337 is not in use
- Java's HttpServer binds to all interfaces by default
- Server creates thread pool automatically for concurrent requests

ClassNotFoundException
----------------------

If you see "Could not find or load main class WebWords":
- Ensure compilation succeeded: check for WebWords.class file
- Verify class name matches filename exactly
- Check WORKDIR and file paths in Dockerfile

Implementation Notes
===================

This Java implementation demonstrates:
- **JDK Standard Library**: Complete HTTP server/client using only built-in classes
- **Object-Oriented Design**: Clean separation of concerns with handler class
- **Thread Safety**: HttpServer automatically handles concurrent requests with thread pools
- **Resource Management**: Proper cleanup of streams and connections
- **Type Safety**: Strong typing prevents many runtime errors
- **Platform Independence**: Java bytecode runs on any JVM

The code showcases Java's "write once, run anywhere" philosophy and the comprehensive standard library that enables complete web services without external dependencies.