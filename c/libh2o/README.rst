WebWords - C Implementation with libh2o
========================================

This implementation uses libh2o, a high-performance HTTP server library with client capabilities.

Features
========

- **Blazing fast**: Optimized for maximum HTTP/2 performance
- **Modern architecture**: Event-driven, non-blocking I/O
- **HTTP/2 native**: Built from the ground up for HTTP/2
- **Memory efficient**: Minimal allocation overhead

Implementation Details
=====================

This version demonstrates:

- H2O's server framework for handling HTTP requests
- Event-driven request processing
- Integrated HTTP client capabilities (simplified for demo)
- Modern C programming patterns

Note: This implementation uses H2O primarily as a server framework. For the HTTP client portion, it uses a simplified approach for demonstration. A production implementation would leverage H2O's full client API.

Building and Testing
===================

.. code-block:: bash

   # Build Docker image (includes compiling H2O from source)
   docker build -t webwords-c-h2o .
   
   # Run container
   docker run -d -p 31337:31337 --name test webwords-c-h2o
   
   # Test
   curl "http://localhost:31337/?keyword=potato&target=https://www.remarkbox.com"
   # Expected: true
   
   # Cleanup
   docker stop test && docker rm test

Dependencies
============

- **libh2o**: High-performance HTTP server/client library
- **OpenSSL**: TLS/SSL support
- **zlib**: Compression support
- **cmake**: Build system for H2O

This implementation showcases modern, high-performance HTTP server architecture in C.