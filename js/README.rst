WebWords - JavaScript Implementation
====================================

This directory contains the JavaScript implementation of the WebWords service using Express.js web framework and the request HTTP client library.

Docker Overview
===============

Our Dockerfile uses Alpine Linux with Node.js and npm for package management:

.. code-block:: dockerfile

   FROM alpine:latest
   
   EXPOSE 31337
   
   COPY package.json /app/
   COPY app.js /app/
   
   WORKDIR /app/
   
   RUN apk --no-cache add nodejs npm ca-certificates \
       && npm install \
       && rm -rf /var/cache/apk/*
   
   CMD ["node", "app.js"]

**Dockerfile Breakdown:**
- ``FROM alpine:latest``: Use lightweight Alpine Linux as base image
- ``COPY package.json /app/``: Copy dependency manifest first for layer caching
- ``COPY app.js /app/``: Copy the main application file
- ``apk --no-cache add nodejs npm ca-certificates``: Install Node.js runtime, npm package manager, and SSL certificates
- ``npm install``: Install dependencies (express, request) from package.json
- ``CMD ["node", "app.js"]``: Run the application with Node.js interpreter

Understanding the Code
======================

This JavaScript implementation uses Express.js for HTTP server functionality and the request library for fetching URLs. The code demonstrates Node.js event-driven, non-blocking I/O.

Dependencies (package.json)
---------------------------

.. code-block:: json

   {
     "dependencies": {
       "express": "^4.18.0",
       "request": "^2.88.0"
     }
   }

- ``express``: Minimal web application framework for Node.js
- ``request``: Simplified HTTP client for making requests (now deprecated but still functional)

Main Application (app.js)
-------------------------

**Setting up Express:**

.. code-block:: javascript

   var express = require('express');
   var request = require('request');
   var app = express();

This code:
1. Imports the Express framework
2. Imports the request HTTP client library
3. Creates an Express application instance

**Route Handler:**

.. code-block:: javascript

   app.get('/', function (req, res) {
     var keyword = req.query.keyword;
     var target = req.query.target;

The route handler:
1. Defines a GET route for the root path ('/')
2. Extracts query parameters from the request URL
3. ``req.query`` automatically parses URL query string into an object

**HTTP Request and Response Logic:**

.. code-block:: javascript

   request(target, function (error, response, body) {
     if (body.includes(keyword)) {
       res.send('true');
     }
     else {
       res.send('false');
     }
   });

This section:
1. Makes HTTP request to the target URL using the request library
2. Uses callback function to handle asynchronous response
3. Searches for keyword in response body using JavaScript's ``includes()`` method
4. Sends "true" or "false" back to client using Express ``res.send()``

**Server Startup:**

.. code-block:: javascript

   app.listen(31337, function () {
     console.log('listening on 0.0.0.0:31337');
   });

The server startup:
1. Binds Express app to port 31337
2. Listens on all network interfaces (0.0.0.0)
3. Executes callback to log server startup message

Building and Running
====================

Step 1: Build the Docker image
------------------------------

.. code-block:: bash

   cd /home/fox/git/webwords/js
   docker build -t webwords-js .

Step 2: Run the container
-------------------------

.. code-block:: bash

   docker run -d -p 31337:31337 --name test-js webwords-js

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

   docker logs test-js

Expected output:
- "listening on 0.0.0.0:31337" on startup
- No per-request logging (unlike other implementations)

Step 5: Clean up
----------------

.. code-block:: bash

   docker stop test-js
   docker rm test-js

Common Issues
=============

npm install fails
-----------------

If package installation fails during Docker build:

.. code-block:: bash

   # Check Node.js and npm versions
   docker run -it alpine:latest sh
   apk add nodejs npm
   node --version
   npm --version

Dependencies might be outdated. The request library is deprecated and could be replaced with modern alternatives like axios or node-fetch.

Port binding issues
------------------

If the server fails to start on port 31337:
- Check no other containers are using port 31337
- Express automatically binds to IPv4 and IPv6
- The app.listen() call binds to all interfaces (0.0.0.0)

Request library deprecation warnings
-----------------------------------

You may see warnings about the request library being deprecated:

.. code-block:: bash

   npm WARN deprecated request@2.88.0: request has been deprecated

This is expected. The request library still works but is no longer maintained. Modern alternatives include:
- ``axios``: Promise-based HTTP client
- ``node-fetch``: Node.js implementation of browser fetch API
- ``got``: HTTP request library with built-in retry and timeout

SSL/HTTPS issues
---------------

If target URLs fail with SSL errors:
- Ensure ca-certificates are installed in the Dockerfile
- The request library uses Node.js built-in HTTPS support
- No additional SSL configuration needed for basic HTTPS requests

Implementation Notes
===================

This JavaScript implementation demonstrates:
- **Event-Driven Programming**: Asynchronous request handling with callbacks
- **Express.js Framework**: Minimal web framework with automatic query parameter parsing
- **NPM Ecosystem**: Package management and dependency resolution
- **Non-Blocking I/O**: Concurrent request processing without blocking the event loop
- **Interpreted Runtime**: No compilation step, direct execution by Node.js
- **JSON Configuration**: Package.json for project metadata and dependencies

The code is concise and leverages JavaScript's built-in string methods and Express's automatic request parsing, making it one of the shortest WebWords implementations while maintaining full functionality.