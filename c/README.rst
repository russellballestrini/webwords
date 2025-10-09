WebWords - C Implementation
============================

This directory contains the C implementation of the WebWords service using native sockets and libcurl for HTTP requests.

Docker Overview
---------------

Our Dockerfile uses Alpine Linux as the base image for a minimal container size while providing all necessary development tools:

.. code-block:: dockerfile

   FROM alpine:latest
   
   # Install C compiler and libcurl development libraries
   RUN apk --no-cache add \
       gcc \
       musl-dev \
       curl-dev \
       make

We use Alpine's package manager to install:

- **gcc**: The GNU Compiler Collection for compiling C code
- **musl-dev**: Development files for musl libc (Alpine's C library)
- **curl-dev**: Development headers and libraries for libcurl
- **make**: Build automation tool for our Makefile

The build process compiles our C source code into a static binary that can run independently.

Understanding the Code
----------------------

Our C implementation demonstrates low-level system programming concepts:

**HTTP Server Architecture:**

.. code-block:: c

   // Create socket
   server_socket = socket(AF_INET, SOCK_STREAM, 0);
   
   // Bind to port 31337
   bind(server_socket, (struct sockaddr*)&server_addr, sizeof(server_addr));
   
   // Listen for connections
   listen(server_socket, 10);

This creates a TCP socket server that listens on port 31337. The server uses:

- **socket()**: Creates a communication endpoint
- **bind()**: Associates the socket with a specific port
- **listen()**: Marks the socket as passive, ready to accept connections
- **accept()**: Accepts incoming client connections

**HTTP Request Parsing:**

.. code-block:: c

   // Parse query parameters
   parse_query_params(query_start, keyword, target);
   
   // URL decode function handles %20, +, etc.
   void url_decode(char *dst, const char *src);

Our parser extracts the ``keyword`` and ``target`` parameters from the query string and properly URL-decodes them.

**libcurl Integration:**

.. code-block:: c

   curl_handle = curl_easy_init();
   curl_easy_setopt(curl_handle, CURLOPT_URL, url);
   curl_easy_setopt(curl_handle, CURLOPT_WRITEFUNCTION, WriteMemoryCallback);
   res = curl_easy_perform(curl_handle);

libcurl handles the HTTP client functionality:

- **curl_easy_init()**: Initializes a curl session
- **curl_easy_setopt()**: Sets options like URL and callback functions
- **WriteMemoryCallback()**: Custom function to capture response data
- **curl_easy_perform()**: Executes the HTTP request

**Memory Management:**

.. code-block:: c

   struct MemoryStruct {
       char *memory;
       size_t size;
   };

C requires manual memory management. Our implementation uses:

- **malloc()/realloc()**: Allocate and resize memory dynamically
- **free()**: Release allocated memory to prevent leaks
- **strdup()**: Duplicate strings safely

**String Processing:**

.. code-block:: c

   // Case-insensitive search
   if (strncasecmp(content + i, keyword, keyword_len) == 0) {
       return 1;
   }

The keyword search uses ``strncasecmp()`` for case-insensitive comparison, iterating through the content to find matches.

Building and Running
--------------------

**Using Docker (Recommended):**

.. code-block:: bash

   # Build the Docker image
   cd c
   docker build -t webwords-c .
   
   # Run the container
   docker run -d -p 31337:31337 --name webwords-c-server webwords-c
   
   # Test the implementation
   curl "http://localhost:31337/?keyword=potato&target=https://www.remarkbox.com"
   # Expected output: true
   
   curl "http://localhost:31337/?keyword=lemon&target=https://www.remarkbox.com"
   # Expected output: false
   
   # Cleanup
   docker stop webwords-c-server && docker rm webwords-c-server

**Using Makefile (Development):**

.. code-block:: bash

   # Build from the main project directory
   make build-c
   
   # Start the server
   make serve-c
   
   # Test the server
   make functional-test-c
   
   # Clean up
   make clean-c

**Local Development:**

.. code-block:: bash

   # Install dependencies (on Ubuntu/Debian)
   sudo apt-get install build-essential libcurl4-openssl-dev
   
   # Or on Alpine/Arch
   apk add gcc musl-dev curl-dev make
   
   # Compile locally
   cd c
   make
   
   # Run locally
   ./webwords

The local Makefile compiles with appropriate flags:

- **-Wall -Wextra**: Enable comprehensive warnings
- **-std=c99**: Use C99 standard
- **-D_GNU_SOURCE**: Enable GNU extensions
- **-lcurl**: Link against libcurl library

Common Issues
-------------

**Build Issues:**

*Problem*: "curl/curl.h: No such file or directory"

*Solution*: Install curl development headers:

.. code-block:: bash

   # Alpine
   apk add curl-dev
   
   # Ubuntu/Debian
   apt-get install libcurl4-openssl-dev
   
   # CentOS/RHEL
   yum install libcurl-devel

*Problem*: "undefined reference to curl_easy_init"

*Solution*: Ensure you're linking against libcurl:

.. code-block:: bash

   gcc webwords.c -o webwords -lcurl

**Runtime Issues:**

*Problem*: "Address already in use"

*Solution*: Port 31337 is busy. Kill existing processes:

.. code-block:: bash

   # Find process using port 31337
   sudo lsof -i :31337
   
   # Kill the process
   kill <PID>

*Problem*: "Permission denied" on port binding

*Solution*: Either run as root (not recommended) or use a port > 1024:

.. code-block:: c

   #define PORT 8080  // Change from 31337

**Memory Issues:**

*Problem*: Segmentation fault during URL fetching

*Solution*: Check memory allocation in WriteMemoryCallback:

.. code-block:: c

   char *ptr = realloc(mem->memory, mem->size + realsize + 1);
   if (!ptr) {
       printf("Not enough memory (realloc returned NULL)\\n");
       return 0;  // Abort the transfer
   }

**Network Issues:**

*Problem*: "Could not resolve host"

*Solution*: Verify network connectivity and DNS:

.. code-block:: bash

   # Test DNS resolution
   nslookup www.remarkbox.com
   
   # Test direct connection
   curl -v https://www.remarkbox.com

*Problem*: SSL/TLS errors with HTTPS URLs

*Solution*: libcurl should handle SSL automatically. If issues persist, try:

.. code-block:: c

   curl_easy_setopt(curl_handle, CURLOPT_SSL_VERIFYPEER, 0L);  // Disable SSL verification (not recommended for production)

**Debugging Tips:**

Enable verbose curl output:

.. code-block:: c

   curl_easy_setopt(curl_handle, CURLOPT_VERBOSE, 1L);

Add debug prints:

.. code-block:: c

   printf("Received keyword: '%s', target: '%s'\\n", keyword, target);
   printf("Response code: %ld\\n", response_code);

Use valgrind to detect memory leaks:

.. code-block:: bash

   valgrind --leak-check=full ./webwords

C Language Features Demonstrated
---------------------------------

This implementation showcases fundamental C programming concepts:

**System Programming:**
- Socket programming with BSD sockets API
- Process management and signal handling
- Memory management with malloc/free
- File I/O and system calls

**Network Programming:**
- TCP server implementation
- HTTP protocol parsing
- URL encoding/decoding
- HTTP client requests with libcurl

**String Processing:**
- Manual string manipulation
- Buffer management
- Case-insensitive searching
- Memory-safe string operations

**Error Handling:**
- Return code checking
- Resource cleanup
- Graceful error recovery
- Memory leak prevention

The C implementation provides the foundation for understanding how higher-level languages implement similar functionality under the hood.