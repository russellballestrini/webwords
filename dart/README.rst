WebWords - Dart Implementation
=============================

This directory contains the Dart implementation of the WebWords service using the Shelf web framework and HTTP client package.

Docker Overview
===============

Our Dockerfile uses a multi-stage build with Dart SDK and scratch runtime:

.. code-block:: dockerfile

   FROM dart:stable AS build
   
   WORKDIR /app
   COPY pubspec.* .
   RUN dart pub get
   
   COPY . .
   RUN dart pub get --offline
   RUN dart compile exe bin/server.dart -o bin/server
   
   FROM scratch
   COPY --from=build /runtime/ /
   COPY --from=build /app/bin/server /app/bin/
   
   EXPOSE 31337
   
   ENTRYPOINT ["/app/bin/server"]

**Multi-Stage Build Breakdown:**

**Stage 1 (Build Environment):**
- ``FROM dart:stable AS build``: Use official Dart SDK for compilation
- ``COPY pubspec.* .``: Copy dependency manifest files for layer caching
- ``RUN dart pub get``: Download and resolve package dependencies
- ``RUN dart compile exe bin/server.dart -o bin/server``: Compile to native executable

**Stage 2 (Minimal Runtime):**
- ``FROM scratch``: Minimal container with no OS layer
- ``COPY --from=build /runtime/ /``: Copy Dart runtime libraries
- ``COPY --from=build /app/bin/server /app/bin/``: Copy compiled executable
- Final image contains only runtime essentials and the native binary

Understanding the Code
======================

This Dart implementation uses the Shelf web framework with async/await patterns, demonstrating modern Dart server-side development.

Dependencies (pubspec.yaml)
---------------------------

.. code-block:: yaml

   dependencies:
     shelf: ^1.4.0
     shelf_router: ^1.1.0
     http: ^0.13.5

- ``shelf``: Minimalist web framework for Dart HTTP servers
- ``shelf_router``: Router middleware for handling URL routing
- ``http``: HTTP client library for making requests

Main Application (bin/server.dart)
----------------------------------

**Imports and Setup:**

.. code-block:: dart

   import 'dart:io';
   import 'package:shelf/shelf.dart';
   import 'package:shelf/shelf_io.dart';
   import 'package:shelf_router/shelf_router.dart';
   import 'package:http/http.dart' as http;

Standard Dart imports:
- ``dart:io``: Core I/O operations and networking
- ``shelf`` packages: Web framework components
- ``http`` with alias: HTTP client functionality

**Request Handler Function:**

.. code-block:: dart

   Future<Response> _handleRoot(Request request) async {
     final keyword = request.url.queryParameters['keyword'] ?? '';
     final target = request.url.queryParameters['target'] ?? '';
     var found = 'false';

Handler implementation:
1. ``Future<Response>``: Returns a future that resolves to an HTTP response
2. ``request.url.queryParameters['keyword']``: Extract query parameters
3. ``?? ''``: Null-aware operator provides empty string default
4. ``var found = 'false'``: Initialize result variable

**Input Validation and HTTP Request:**

.. code-block:: dart

   if (keyword.isNotEmpty && target.isNotEmpty) {
     try {
       final response = await http.get(Uri.parse(target)).timeout(
         const Duration(seconds: 10)
       );

Request processing:
1. ``keyword.isNotEmpty && target.isNotEmpty``: Validate required parameters
2. ``http.get(Uri.parse(target))``: Make HTTP GET request to target URL
3. ``.timeout(const Duration(seconds: 10))``: Set 10-second timeout
4. ``await``: Asynchronously wait for response

**Response Processing:**

.. code-block:: dart

   if (response.body.contains(keyword)) {
     found = 'true';
   }
   
   print('found=$found, keyword=$keyword, uri=$target');
   } catch (e) {
     print('Error: $e');
   }

Result handling:
1. ``response.body.contains(keyword)``: Search for keyword in response body
2. ``print(...)``: Log request details to stdout
3. ``catch (e)``: Handle any HTTP or network errors gracefully
4. Errors are logged but don't crash the server

**Server Configuration:**

.. code-block:: dart

   void main(List<String> args) async {
     final app = Router();
     app.get('/', _handleRoot);
     
     final handler = Pipeline()
         .addMiddleware(logRequests())
         .addHandler(app);

Server setup:
1. ``Router()``: Create router for URL path handling
2. ``app.get('/', _handleRoot)``: Map root path to handler function
3. ``Pipeline()``: Create middleware pipeline
4. ``addMiddleware(logRequests())``: Add request logging middleware

**Server Startup:**

.. code-block:: dart

   final server = await serve(handler, InternetAddress.anyIPv4, 31337);
   print('listening on 0.0.0.0:${server.port}');

Start HTTP server:
1. ``serve(handler, InternetAddress.anyIPv4, 31337)``: Bind to all IPv4 interfaces on port 31337
2. ``await``: Asynchronously start the server
3. ``print(...)``: Log server startup message

Building and Running
====================

Step 1: Build the Docker image
------------------------------

.. code-block:: bash

   cd /home/fox/git/webwords/dart
   docker build -t webwords-dart .

Step 2: Run the container
-------------------------

.. code-block:: bash

   docker run -d -p 31337:31337 --name test-dart webwords-dart

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

   docker logs test-dart

Expected output:
- "listening on 0.0.0.0:31337" on startup
- "found=true, keyword=potato, uri=https://www.remarkbox.com" for requests

Step 5: Clean up
----------------

.. code-block:: bash

   docker stop test-dart
   docker rm test-dart

Common Issues
=============

Dart compilation errors
----------------------

If compilation fails during Docker build:

.. code-block:: bash

   # Check Dart version
   docker run -it dart:stable bash
   dart --version

Common Dart build issues:
- Package dependency version conflicts in pubspec.yaml
- Missing or invalid Dart syntax
- Network connectivity during pub get

Package resolution failures
---------------------------

If pub get fails:
- Check pubspec.yaml syntax and indentation
- Verify package versions are compatible
- Network connectivity required for package downloads

HTTP client timeout issues
--------------------------

If HTTP requests timeout:
- Built-in 10-second timeout in the implementation
- Dart HTTP client handles SSL/HTTPS automatically
- No additional SSL configuration needed

Container startup failures
--------------------------

If the container fails to start:
- Check that the compiled executable is present: ``/app/bin/server``
- Verify scratch base image has necessary runtime libraries
- Ensure Dart runtime was copied correctly

Port binding issues
------------------

If the server fails to bind to port 31337:
- Check no other containers are using port 31337
- Dart server binds to all IPv4 interfaces automatically
- Shelf framework handles concurrent requests efficiently

Memory and performance
---------------------

If you experience performance issues:
- Dart compiles to native code for excellent performance
- Async/await enables efficient concurrent request handling
- Scratch base image minimizes memory footprint

Implementation Notes
===================

This Dart implementation demonstrates:
- **Modern Language Features**: Async/await, null safety, and strong typing
- **Shelf Web Framework**: Composable middleware and routing system
- **Native Compilation**: AOT compilation to standalone executable
- **Minimal Container**: Scratch base image with only essential runtime
- **Null Safety**: Built-in null-aware operators and type safety
- **Functional Programming**: Pipeline composition and immutable patterns

The code showcases Dart's evolution from a client-side language to a capable server-side platform with excellent performance characteristics and modern language features, while maintaining Google's focus on developer productivity.