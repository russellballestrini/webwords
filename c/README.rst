WebWords - C Implementations
=============================

This directory contains three different C implementations of the WebWords service, each showcasing different HTTP client libraries and approaches:

Implementation Variants
========================

**curl/** - libcurl Implementation
   Traditional HTTP client using the ubiquitous libcurl library.
   
   - **Best for**: Learning standard HTTP client programming
   - **Performance**: Good, well-optimized
   - **Dependencies**: libcurl (widely available)
   - **HTTP Versions**: HTTP/1.1, HTTP/2 (if libcurl supports it)
   - **Community**: Largest, most Stack Overflow answers

**libh2o/** - H2O HTTP Client Implementation
   High-performance HTTP/2 client from the H2O web server project.
   
   - **Best for**: Maximum HTTP/2 performance
   - **Performance**: Blazing fast HTTP/2 multiplexing
   - **Dependencies**: libh2o
   - **HTTP Versions**: HTTP/2 optimized
   - **Community**: Medium, performance-focused

**nghttp2/** - nghttp2 Implementation
   Reference HTTP/2 implementation used by browsers and curl internally.
   
   - **Best for**: Standards-compliant HTTP/2
   - **Performance**: Excellent, battle-tested
   - **Dependencies**: nghttp2 + TLS library
   - **HTTP Versions**: HTTP/2 focus
   - **Community**: Large enterprise adoption

Performance Comparison
=====================

For single requests:
``curl`` ≈ ``nghttp2`` > ``libh2o``

For concurrent requests:
``libh2o`` > ``nghttp2`` > ``curl``

For HTTP/2 multiplexing:
``libh2o`` ≈ ``nghttp2`` >> ``curl``

Building All Variants
=====================

Each subdirectory contains its own Dockerfile and can be built independently:

.. code-block:: bash

   # Build libcurl version
   cd curl
   docker build -t webwords-c-curl .
   
   # Build libh2o version  
   cd libh2o
   docker build -t webwords-c-h2o .
   
   # Build nghttp2 version
   cd nghttp2
   docker build -t webwords-c-nghttp2 .

Testing All Variants
====================

Each implementation exposes the same WebWords API on port 31337:

.. code-block:: bash

   # Test any variant
   docker run -d -p 31337:31337 --name test webwords-c-[variant]
   
   # Positive test
   curl "http://localhost:31337/?keyword=potato&target=https://www.remarkbox.com"
   # Expected: true
   
   # Negative test  
   curl "http://localhost:31337/?keyword=lemon&target=https://www.remarkbox.com"
   # Expected: false
   
   # Cleanup
   docker stop test && docker rm test

Educational Value
=================

This collection demonstrates:

- **Different HTTP client architectures** in C
- **Performance trade-offs** between libraries
- **API design patterns** from simple (curl) to advanced (HTTP/2)
- **Dependency management** strategies
- **Modern vs traditional** C networking approaches

Choose the implementation that best fits your learning goals or performance requirements!