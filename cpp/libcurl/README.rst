WebWords - C++ Implementation
==============================

This directory contains the C++ implementation of the WebWords service, demonstrating systems programming with manual memory management, native HTTP libraries, and compiled performance.

What is Programming?
====================

Programming is the process of creating instructions for computers to follow. Think of it like writing a detailed recipe - you provide step-by-step instructions that the computer follows exactly. Just as a recipe tells you how to cook a meal, a computer program tells the computer how to solve problems or perform tasks.

Programming languages are different ways of writing these instructions. Some languages are good for web applications, others for mobile apps, and some (like C++) are specially designed for high-performance systems programming where you need maximum control over the computer's resources.

What is C++?
============

C++ is a powerful programming language designed for systems programming, game development, and high-performance applications. Unlike higher-level languages that hide complexity, C++ gives you direct control over memory and hardware resources.

Key characteristics of C++:

- **Compiled Language**: C++ code is translated to machine code for maximum performance
- **Manual Memory Management**: You explicitly allocate and free memory (no garbage collector)
- **Object-Oriented Programming**: Supports classes, inheritance, and polymorphism
- **Systems Programming**: Can interact directly with operating system and hardware
- **Performance Focus**: Optimized for speed and efficiency
- **Industry Standard**: Used for operating systems, games, databases, and embedded systems

Real-world C++ applications:
- Operating systems (Windows, Linux, macOS kernels)
- Game engines (Unreal Engine, Unity core)
- Web browsers (Chrome, Firefox core engines)
- Databases (MySQL, PostgreSQL)
- Financial trading systems requiring microsecond response times
- Embedded systems in cars, medical devices, and IoT devices

What is Systems Programming?
============================

Systems programming involves writing software that manages computer resources and provides services to other programs. This includes:

- **Memory Management**: Explicitly allocating and freeing RAM
- **Network Programming**: Creating servers and handling network connections
- **File System Operations**: Reading and writing files efficiently
- **Hardware Interaction**: Communicating with devices and peripherals
- **Performance Optimization**: Writing code that runs as fast as possible

C++ excels at systems programming because it provides:
- Direct memory access without garbage collection overhead
- Native compilation to machine code for maximum speed
- Low-level control over system resources
- Extensive standard library for common operations
- Mature ecosystem of system-level libraries

What are Native HTTP Libraries?
===============================

Native HTTP libraries are software components written in C/C++ that handle web communication at a low level. Think of them like specialized tools in a workshop:

- **Just as a workshop has**: Specific tools for each job (hammer, saw, drill)
- **C++ HTTP programming has**: Specialized libraries for each function (libcurl, libmicrohttpd)

Our HTTP Library Components:
- **libcurl**: Handles outgoing HTTP requests (fetching web pages)
- **libmicrohttpd**: Handles incoming HTTP requests (creating web servers)
- **Manual Memory Management**: Direct control over RAM usage and performance
- **Callback Functions**: Custom code that runs when HTTP events occur
- **Native Performance**: No interpreter overhead, runs directly on CPU

Our Docker Implementation Approach:
Since C++ compiles to native machine code, our implementation:
- **Direct Compilation**: Compiles source code to executable binary
- **Static Linking**: Includes library code directly in the executable
- **No Runtime Environment**: Runs directly on operating system
- **Maximum Performance**: No interpreter or virtual machine overhead

Docker Overview
===============

Docker is a tool that packages applications into containers - think of containers as lightweight, portable virtual machines that include everything needed to run an application.

Why use Docker for C++?
- **Dependency Management**: Includes all required C++ libraries and headers
- **Compilation Environment**: Provides consistent build tools across systems
- **Runtime Dependencies**: Ensures all needed shared libraries are available
- **Cross-Platform Deployment**: Runs the same way on different operating systems
- **Isolation**: Prevents conflicts with other software on the host system

Our Dockerfile Breakdown
========================

Let's examine each line of our Dockerfile and understand what it does:

.. code-block:: dockerfile

   FROM ubuntu:22.04

**Line 1 - Base Image Selection**:
This tells Docker to start with Ubuntu Linux version 22.04 as our foundation. Ubuntu is chosen because:
- Excellent package management for installing C++ development tools
- Comprehensive library ecosystem for C++ libraries
- Stable Long Term Support (LTS) platform for reliability
- APT package manager makes dependency installation straightforward

.. code-block:: dockerfile

   RUN apt-get update && apt-get install -y \
       g++ \
       libcurl4-openssl-dev \
       libmicrohttpd-dev \
       && rm -rf /var/lib/apt/lists/*

**Lines 3-7 - Installing C++ Development Environment**:
- ``apt-get update``: Downloads the latest package list from Ubuntu repositories
- ``g++``: GNU C++ compiler (part of GCC - GNU Compiler Collection)
- ``libcurl4-openssl-dev``: Development headers for libcurl with SSL/HTTPS support
- ``libmicrohttpd-dev``: Development headers for GNU libmicrohttpd web server library
- ``&& rm -rf /var/lib/apt/lists/*``: Cleans up package cache to keep container small

These packages provide everything needed to compile C++ programs with HTTP functionality.

.. code-block:: dockerfile

   WORKDIR /app
   COPY main.cpp .

**Lines 9-10 - Setting up Source Code**:
- ``WORKDIR /app``: Creates and switches to the /app directory (like cd /app)
- ``COPY main.cpp .``: Copy our C++ source file into the container
- The ``.`` means "copy to current directory" (which is /app)

.. code-block:: dockerfile

   RUN g++ -o webwords main.cpp -lcurl -lmicrohttpd

**Line 12 - Compilation Process**:
- ``g++``: Invoke the GNU C++ compiler
- ``-o webwords``: Output executable file named "webwords"
- ``main.cpp``: Input source code file to compile
- ``-lcurl``: Link against libcurl library (for HTTP client functionality)
- ``-lmicrohttpd``: Link against libmicrohttpd library (for HTTP server functionality)

This creates a single native executable with all dependencies linked in.

.. code-block:: dockerfile

   EXPOSE 31337
   CMD ["./webwords"]

**Lines 14-15 - Runtime Configuration**:
- ``EXPOSE 31337``: Tells Docker our application listens on port 31337
- ``CMD ["./webwords"]``: Run our compiled executable when container starts

Understanding the Code
======================

What is an HTTP Server?
-----------------------

An HTTP server is a program that waits for requests from web browsers and responds with information. Think of it like a specialized workshop:

- **Client (Browser)**: Customer who brings a specific job
- **HTTP Request**: The work order ("Does this website contain potato references?")
- **Server (Our Program)**: Workshop that performs the analysis and provides results
- **HTTP Response**: The completed work delivered to the customer

Our HTTP server listens on port 31337 and responds to requests like:
``http://localhost:31337/?keyword=potato&target=https://example.com``

Line-by-Line Code Explanation
-----------------------------

This C++ implementation demonstrates systems programming with manual memory management, native HTTP libraries, and maximum performance optimization.

**Header Includes and Setup (main.cpp lines 1-10)**:

.. code-block:: cpp

   #include <iostream>
   #include <string>
   #include <map>
   #include <sstream>
   #include <thread>
   #include <chrono>
   #include <regex>
   #include <curl/curl.h>
   #include <microhttpd.h>

**Header File Analysis**:
- ``#include <iostream>``: Input/output operations (std::cout for logging)
- ``#include <string>``: C++ string class for text manipulation
- ``#include <map>``: Associative container for key-value pairs
- ``#include <thread>``: Multi-threading support for concurrent processing
- ``#include <chrono>``: Time utilities for delays and timeouts
- ``#include <curl/curl.h>``: libcurl library for HTTP client functionality
- ``#include <microhttpd.h>``: libmicrohttpd library for HTTP server functionality

**Memory Management Structure (lines 11-14)**:

.. code-block:: cpp

   struct MemoryStruct {
       char *memory;
       size_t size;
   };

**Structure Purpose**:
- ``char *memory``: Pointer to dynamically allocated memory buffer
- ``size_t size``: Current size of allocated memory
- This structure tracks manually managed memory for HTTP response data
- No garbage collector - we must explicitly manage memory allocation and deallocation

**HTTP Response Callback Function (lines 16-30)**:

.. code-block:: cpp

   static size_t WriteMemoryCallback(void *contents, size_t size, size_t nmemb, struct MemoryStruct *userp) {
       size_t realsize = size * nmemb;
       char *ptr = (char*)realloc(userp->memory, userp->size + realsize + 1);
       if (!ptr) {
           printf("not enough memory (realloc returned NULL)\n");
           return 0;
       }

**Callback Function Analysis**:
- ``static``: Internal linkage - function only visible within this file
- ``size_t``: Unsigned integer type for memory sizes
- ``void *contents``: Raw memory pointer containing HTTP response data
- ``realloc()``: Reallocates memory buffer to accommodate new data
- ``realsize = size * nmemb``: Calculate total bytes received
- Error handling for memory allocation failure

.. code-block:: cpp

   userp->memory = ptr;
   memcpy(&(userp->memory[userp->size]), contents, realsize);
   userp->size += realsize;
   userp->memory[userp->size] = 0;
   return realsize;

**Memory Operations**:
- ``userp->memory = ptr``: Update memory pointer to new allocation
- ``memcpy()``: Copy received data to buffer (append operation)
- ``userp->size += realsize``: Update total buffer size
- ``userp->memory[userp->size] = 0``: Null-terminate string
- Return bytes processed (tells libcurl the operation succeeded)

**URL Fetching Function (lines 47-74)**:

.. code-block:: cpp

   std::string fetchUrl(const std::string& url) {
       CURL *curl;
       CURLcode res;
       struct MemoryStruct chunk;
       
       chunk.memory = (char*)malloc(1);
       chunk.size = 0;

**Function Initialization**:
- ``std::string``: C++ string class return type
- ``const std::string& url``: Reference parameter (avoids copying)
- ``CURL *curl``: libcurl handle for HTTP operations
- ``malloc(1)``: Allocate initial 1 byte of memory
- Manual memory management start point

.. code-block:: cpp

   curl = curl_easy_init();
   if (curl) {
       curl_easy_setopt(curl, CURLOPT_URL, url.c_str());
       curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, WriteMemoryCallback);
       curl_easy_setopt(curl, CURLOPT_WRITEDATA, (void *)&chunk);
       curl_easy_setopt(curl, CURLOPT_TIMEOUT, 10L);

**libcurl Configuration**:
- ``curl_easy_init()``: Initialize curl session
- ``CURLOPT_URL``: Set target URL for request
- ``CURLOPT_WRITEFUNCTION``: Set callback function for response data
- ``CURLOPT_WRITEDATA``: Pass our memory structure to callback
- ``CURLOPT_TIMEOUT, 10L``: Set 10-second timeout

.. code-block:: cpp

   res = curl_easy_perform(curl);
   curl_easy_cleanup(curl);
   
   if (res != CURLE_OK) {
       free(chunk.memory);
       return "";
   }

**HTTP Request Execution**:
- ``curl_easy_perform()``: Execute the HTTP request
- ``curl_easy_cleanup()``: Clean up curl session resources
- ``CURLE_OK``: Check if request succeeded
- ``free(chunk.memory)``: Release allocated memory on error
- Return empty string on failure

.. code-block:: cpp

   std::string result(chunk.memory);
   free(chunk.memory);
   return result;

**Memory Cleanup and Return**:
- ``std::string result(chunk.memory)``: Create C++ string from C string
- ``free(chunk.memory)``: Release manually allocated memory
- Return the fetched content as C++ string

**HTTP Server Request Handler (lines 76-102)**:

.. code-block:: cpp

   static enum MHD_Result answer_to_connection(void *cls, struct MHD_Connection *connection,
                                             const char *url, const char *method,
                                             const char *version, const char *upload_data,
                                             size_t *upload_data_size, void **con_cls) {

**Handler Function Signature**:
- ``enum MHD_Result``: libmicrohttpd return type
- ``struct MHD_Connection *connection``: HTTP connection context
- Multiple parameters for HTTP request details
- This function is called for every HTTP request

.. code-block:: cpp

   const char *keyword = MHD_lookup_connection_value(connection, MHD_GET_ARGUMENT_KIND, "keyword");
   const char *target = MHD_lookup_connection_value(connection, MHD_GET_ARGUMENT_KIND, "target");

**Query Parameter Extraction**:
- ``MHD_lookup_connection_value()``: libmicrohttpd function to extract parameters
- ``MHD_GET_ARGUMENT_KIND``: Specify we want GET query parameters
- ``"keyword"`` and ``"target"``: Parameter names to extract
- Returns C-style strings (char*) or NULL if parameter not found

.. code-block:: cpp

   std::string found = "false";
   
   if (keyword && target) {
       std::string body = fetchUrl(target);
       if (body.find(keyword) != std::string::npos) {
           found = "true";
       }
       
       std::cout << "found=" << found << ", keyword=" << keyword << ", uri=" << target << std::endl;
   }

**Core Logic Implementation**:
- ``std::string found = "false"``: Initialize result variable
- ``if (keyword && target)``: Check both parameters are present
- ``fetchUrl(target)``: Call our URL fetching function
- ``body.find(keyword)``: Search for keyword in fetched content
- ``std::string::npos``: Special value meaning "not found"
- ``std::cout``: Log the result to console

.. code-block:: cpp

   struct MHD_Response *response;
   enum MHD_Result ret;
   
   response = MHD_create_response_from_buffer(found.length(), (void*)found.c_str(), MHD_RESPMEM_MUST_COPY);
   ret = MHD_queue_response(connection, MHD_HTTP_OK, response);
   MHD_destroy_response(response);
   
   return ret;

**HTTP Response Creation**:
- ``MHD_create_response_from_buffer()``: Create HTTP response object
- ``found.length()``: Length of response content
- ``found.c_str()``: Convert C++ string to C string
- ``MHD_RESPMEM_MUST_COPY``: Tell libmicrohttpd to copy our data
- ``MHD_queue_response()``: Send response to client
- ``MHD_destroy_response()``: Clean up response object

**Main Server Function (lines 104-120)**:

.. code-block:: cpp

   int main() {
       struct MHD_Daemon *daemon;
       
       daemon = MHD_start_daemon(MHD_USE_INTERNAL_POLLING_THREAD, 31337, NULL, NULL,
                                &answer_to_connection, NULL, MHD_OPTION_END);
       if (NULL == daemon) return 1;

**Server Initialization**:
- ``struct MHD_Daemon *daemon``: libmicrohttpd server instance
- ``MHD_start_daemon()``: Start HTTP server
- ``MHD_USE_INTERNAL_POLLING_THREAD``: Use libmicrohttpd's threading
- ``31337``: Port number to listen on
- ``&answer_to_connection``: Pointer to our request handler function
- ``NULL == daemon``: Check if server startup failed

.. code-block:: cpp

   std::cout << "listening on 0.0.0.0:31337" << std::endl;
   
   while (true) {
       std::this_thread::sleep_for(std::chrono::seconds(1));
   }
   
   MHD_stop_daemon(daemon);
   return 0;

**Server Main Loop**:
- ``std::cout``: Log server startup message
- ``while (true)``: Infinite loop to keep server running
- ``std::this_thread::sleep_for()``: Sleep for 1 second to avoid busy waiting
- ``std::chrono::seconds(1)``: C++11 duration literal
- ``MHD_stop_daemon()``: Clean shutdown (never reached due to infinite loop)

Key Programming Concepts
========================

Variables and Memory in C++
----------------------------

C++ provides different ways to manage variables and memory:

.. code-block:: cpp

   // Stack variables (automatic cleanup)
   std::string keyword = "potato";
   int port = 31337;
   
   // Heap variables (manual cleanup required)
   char *buffer = (char*)malloc(1024);
   free(buffer);  // Must manually free
   
   // C++ smart pointers (automatic cleanup)
   std::unique_ptr<char[]> smart_buffer(new char[1024]);
   // Automatically freed when out of scope

Memory Management Patterns
---------------------------

Our implementation demonstrates manual memory management:

.. code-block:: cpp

   // Manual allocation and reallocation
   chunk.memory = (char*)malloc(1);           // Allocate 1 byte
   ptr = (char*)realloc(memory, new_size);    // Resize buffer
   free(chunk.memory);                        // Release memory
   
   // RAII (Resource Acquisition Is Initialization)
   std::string result(chunk.memory);          // C++ string manages memory
   // String automatically freed when destroyed

Pointers and References
-----------------------

C++ provides multiple ways to access memory:

.. code-block:: cpp

   std::string text = "hello";
   
   // Value (copy)
   std::string copy = text;
   
   // Pointer (address)
   std::string* ptr = &text;
   
   // Reference (alias)
   const std::string& ref = text;  // No copy, more efficient

Function Pointers and Callbacks
-------------------------------

Our implementation uses function pointers for callbacks:

.. code-block:: cpp

   // Function pointer type
   typedef size_t (*WriteFunction)(void*, size_t, size_t, void*);
   
   // Set callback function
   curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, WriteMemoryCallback);
   
   // libcurl calls our function when data arrives
   static size_t WriteMemoryCallback(void *contents, size_t size, size_t nmemb, struct MemoryStruct *userp) {
       // Process incoming HTTP data
   }

Error Handling in C++
----------------------

C++ provides multiple error handling mechanisms:

.. code-block:: cpp

   // Return code checking (C-style)
   CURLcode res = curl_easy_perform(curl);
   if (res != CURLE_OK) {
       // Handle error
   }
   
   // Exception handling (C++-style)
   try {
       std::string result = risky_operation();
   } catch (const std::exception& e) {
       std::cerr << "Error: " << e.what() << std::endl;
   }
   
   // RAII for resource management
   {
       std::string data = fetchUrl(url);  // Automatic cleanup
   }  // String memory automatically freed here

Building and Running (Complete Beginner Guide)
===============================================

Step 1: Open Terminal/Command Prompt
------------------------------------

**Windows**: 
- Press Windows key + R
- Type "cmd" and press Enter
- A black window appears - this is your command prompt

**Mac**:
- Press Cmd + Space
- Type "terminal" and press Enter  
- A terminal window opens

**Linux**:
- Press Ctrl + Alt + T
- Terminal window opens

Step 2: Navigate to the Code
----------------------------

Type the following command and press Enter:

.. code-block:: bash

   cd /home/fox/git/webwords/cpp

This changes your current directory to where the C++ code is located. Think of it like navigating to a specific folder.

If you get "No such file or directory", the code might be in a different location. Ask where the webwords project is stored.

Step 3: Build with Docker
-------------------------

Type this command and press Enter:

.. code-block:: bash

   docker build -t webwords-cpp .

**What this does**:
- ``docker build``: Tells Docker to create a container image
- ``-t webwords-cpp``: Names the image "webwords-cpp"  
- ``.``: Use the current directory (which contains our Dockerfile)

**What you'll see**:
- Docker downloads Ubuntu Linux
- Installs C++ compiler and development tools
- Installs libcurl and libmicrohttpd libraries
- Compiles our C++ source code into an executable
- Creates the final container image

This may take 2-5 minutes the first time due to downloading packages and compilation.

Step 4: Run the Container
------------------------

Type this command:

.. code-block:: bash

   docker run -d -p 31337:31337 --name test-cpp webwords-cpp

**What this does**:
- ``docker run``: Starts a container from our image
- ``-d``: Run in background (detached mode)
- ``-p 31337:31337``: Connect port 31337 inside container to port 31337 on your computer
- ``--name test-cpp``: Give the container a friendly name
- ``webwords-cpp``: Use the image we just built

Step 5: Test the C++ HTTP Service
---------------------------------

**Test 1 - Positive Case** (should find "potato"):

.. code-block:: bash

   curl "http://localhost:31337/?keyword=potato&target=https://www.remarkbox.com"

Expected result: ``true``

**Test 2 - Negative Case** (should not find "lemon"):

.. code-block:: bash

   curl "http://localhost:31337/?keyword=lemon&target=https://www.remarkbox.com"

Expected result: ``false``

Step 6: View C++ Application Logs
---------------------------------

To see the C++ application output:

.. code-block:: bash

   docker logs test-cpp

You should see:
- "listening on 0.0.0.0:31337" when the server starts
- "found=true, keyword=potato, uri=https://www.remarkbox.com" for each request

Step 7: Monitor Performance (Optional)
--------------------------------------

To see how much CPU and memory the C++ implementation uses:

.. code-block:: bash

   docker stats test-cpp

This shows real-time resource usage. Press Ctrl+C to exit monitoring.

Step 8: Clean Up
----------------

When you're done testing:

.. code-block:: bash

   docker stop test-cpp
   docker rm test-cpp

This stops and removes the test container.

Understanding What the Program Does
===================================

When you visit ``http://localhost:31337/?keyword=potato&target=https://www.remarkbox.com``:

**Step 1**: Your browser sends an HTTP request to our C++ server
**Step 2**: libmicrohttpd receives the request and calls our answer_to_connection function
**Step 3**: Our C++ code extracts "potato" and "https://www.remarkbox.com" using libmicrohttpd
**Step 4**: The fetchUrl function creates a libcurl session to download the target webpage
**Step 5**: libcurl calls our WriteMemoryCallback function as data arrives, building up the response
**Step 6**: Our C++ code searches for "potato" in the downloaded content using std::string::find()
**Step 7**: The result ("true" or "false") is logged to console using std::cout
**Step 8**: libmicrohttpd sends the HTTP response back to your browser
**Step 9**: All dynamically allocated memory is freed using explicit free() calls

**C++ Performance Features**:
- Native machine code execution (no interpreter overhead)
- Manual memory management for optimal RAM usage
- Multi-threaded request handling via libmicrohttpd
- Zero-copy operations where possible
- Efficient string operations with C++ STL

What Happens When It Runs
=========================

**Systems Programming Environment Setup**:
1. Docker creates an isolated Linux environment with C++ runtime
2. Our compiled native executable loads into memory
3. libcurl and libmicrohttpd shared libraries are linked dynamically
4. Operating system allocates initial memory and creates main thread
5. libmicrohttpd starts listening on port 31337 using system sockets

**Request Processing Flow**:
1. HTTP request arrives at the network interface
2. Operating system routes request to our process on port 31337
3. libmicrohttpd creates a new thread for request handling
4. Our answer_to_connection function is called with request parameters
5. Query parameters are extracted using direct memory access
6. libcurl session is initialized with manual memory allocation
7. HTTP request is sent to target URL with 10-second timeout
8. Response data arrives in chunks, triggering our callback function
9. Memory buffer is dynamically resized using realloc() as data arrives
10. Search operation uses optimized C++ string algorithms
11. Response is created and sent using zero-copy operations
12. All allocated memory is explicitly freed to prevent leaks

**Systems Programming in Action**:
- Direct system calls for network operations
- Manual memory management for optimal performance
- Thread creation and management by libmicrohttpd
- Native code execution without runtime overhead

Common Problems and Solutions
============================

Problem: "docker: command not found"
-----------------------------------

**Cause**: Docker is not installed on your system.

**Solution**: 
1. Visit https://docker.com/get-started
2. Download Docker Desktop for your operating system
3. Follow the installation instructions
4. Restart your computer
5. Try the docker command again

Problem: "Permission denied" when running Docker
-----------------------------------------------

**Cause**: Your user account doesn't have permission to use Docker.

**Linux Solution**:

.. code-block:: bash

   sudo usermod -aG docker $USER
   newgrp docker

**Windows/Mac Solution**: 
Make sure Docker Desktop is running and you're logged in.

Problem: "Port is already in use" or Concurrent Testing
--------------------------------------------------------

**Cause**: Another application or container is using the port, or you want to run multiple tests simultaneously.

**Solution 1** - Find and stop the conflicting process:

.. code-block:: bash

   docker ps | grep webwords
   docker stop <container-name>

**Solution 2** - Use a random port for concurrent testing:

.. code-block:: bash

   # Generate random port between 32000-33000
   RANDOM_PORT=$((32000 + RANDOM % 1000))
   echo "Using port: $RANDOM_PORT"
   docker run -d -p $RANDOM_PORT:31337 --name test-cpp-$RANDOM_PORT webwords-cpp
   curl "http://localhost:$RANDOM_PORT/?keyword=potato&target=https://www.remarkbox.com"
   
   # Clean up
   docker stop test-cpp-$RANDOM_PORT && docker rm test-cpp-$RANDOM_PORT

**Solution 3** - Use a specific alternative port:

.. code-block:: bash

   docker run -d -p 32337:31337 --name test-cpp webwords-cpp
   curl "http://localhost:32337/?keyword=potato&target=https://www.remarkbox.com"

Problem: C++ compilation errors during build
--------------------------------------------

**Cause**: Missing development libraries or compiler issues.

**Diagnosis**:

.. code-block:: bash

   docker build -t webwords-cpp . 2>&1 | tee build.log
   grep -i error build.log

**Common C++ compilation issues**:
- Missing header files (ensure -dev packages are installed)
- Linking errors (check -lcurl -lmicrohttpd flags)
- C++ standard library issues (g++ version compatibility)

**Solution**: Check the build log for specific error messages and verify library installation.

Problem: Container starts but doesn't respond
--------------------------------------------

**Cause**: C++ application might have crashed or failed to bind to port.

**Diagnosis**:

.. code-block:: bash

   docker logs test-cpp

**Look for**: "listening on 0.0.0.0:31337" message

**Common startup issues**:
- Segmentation fault due to memory access errors
- Port binding failure
- Library loading problems

**Solution**: If you don't see the listening message, check logs for errors:

.. code-block:: bash

   docker restart test-cpp

Problem: Memory allocation errors
--------------------------------

**Symptoms**: Application crashes or returns empty responses

**Cause**: Our implementation uses manual memory management with malloc/realloc.

**Diagnosis**:

.. code-block:: bash

   docker logs test-cpp | grep -i "memory\|malloc\|realloc"
   docker stats test-cpp

**Common memory issues**:
- realloc() returns NULL when out of memory
- Memory leaks due to missing free() calls
- Buffer overflows in callback functions

**Solution**: Monitor memory usage and restart container if needed:

.. code-block:: bash

   docker restart test-cpp

Problem: "curl: command not found"
---------------------------------

**Cause**: curl is not installed on your system.

**Linux Solution**:

.. code-block:: bash

   sudo apt-get install curl

**Mac Solution**:

.. code-block:: bash

   brew install curl

**Windows Solution**: 
Use PowerShell instead of Command Prompt, or install curl from https://curl.se/

Problem: SSL/HTTPS connection failures
-------------------------------------

**Symptoms**: Target HTTPS URLs fail while HTTP URLs work

**Cause**: SSL certificate or libcurl SSL configuration issues.

**Diagnosis**:

.. code-block:: bash

   docker logs test-cpp | grep -i "ssl\|tls\|certificate"

**Solutions**:
1. Ensure libcurl4-openssl-dev provides SSL support
2. Verify ca-certificates are available in container
3. Check if target website has valid SSL certificates

Problem: High CPU or memory usage
--------------------------------

**Symptoms**: System becomes slow when testing

**Diagnosis**:

.. code-block:: bash

   docker stats test-cpp

**Possible causes**:
- Memory leaks in manual memory management
- Infinite loops in callback functions
- Too many concurrent connections

**Solutions**:
- Restart container to clear memory leaks
- Limit concurrent requests
- Monitor resource usage during testing

Systems Programming Concepts
=============================

What Makes C++ Special for Systems Programming?
-----------------------------------------------

**Traditional High-Level Languages**:
- Automatic memory management (garbage collection)
- Interpreted or virtual machine execution
- Higher abstraction levels hide hardware details

**C++ Systems Programming Approach**:
- Direct control over memory allocation and deallocation
- Compiled to native machine code for maximum performance
- Low-level access to operating system and hardware
- Zero-overhead abstractions when possible

**Example Comparison**:

.. code-block:: python

   # Python - automatic memory management
   response = requests.get(url)
   content = response.text
   # Memory automatically managed by garbage collector

.. code-block:: cpp

   // C++ - manual memory management
   char *buffer = (char*)malloc(1024);
   // ... fill buffer with HTTP response
   free(buffer);  // Must explicitly free memory

Memory Management Strategies
----------------------------

Our implementation demonstrates several memory management patterns:

**Manual Allocation**:

.. code-block:: cpp

   // Allocate initial buffer
   chunk.memory = (char*)malloc(1);
   chunk.size = 0;
   
   // Dynamically resize as data arrives
   char *ptr = (char*)realloc(chunk.memory, new_size);
   
   // Must manually free when done
   free(chunk.memory);

**RAII (Resource Acquisition Is Initialization)**:

.. code-block:: cpp

   {
       std::string result(chunk.memory);  // Constructor acquires resource
       // ... use result
   }  // Destructor automatically frees memory

**Smart Pointers (Modern C++)**:

.. code-block:: cpp

   std::unique_ptr<char[]> buffer(new char[1024]);
   // Automatically freed when buffer goes out of scope

HTTP Library Integration
------------------------

Our implementation shows how to integrate C libraries with C++:

**C Library API (libcurl)**:

.. code-block:: cpp

   // C-style function calls
   CURL *curl = curl_easy_init();
   curl_easy_setopt(curl, CURLOPT_URL, url);
   CURLcode res = curl_easy_perform(curl);
   curl_easy_cleanup(curl);

**C++ Wrapper Pattern**:

.. code-block:: cpp

   class CurlWrapper {
   private:
       CURL *curl_;
   public:
       CurlWrapper() : curl_(curl_easy_init()) {}
       ~CurlWrapper() { curl_easy_cleanup(curl_); }
       std::string fetch(const std::string& url) { /* ... */ }
   };

**Callback Function Integration**:

.. code-block:: cpp

   // C-style callback function
   static size_t WriteCallback(void *contents, size_t size, size_t nmemb, void *userp) {
       // Bridge between C library and C++ code
       return static_cast<MyClass*>(userp)->processData(contents, size * nmemb);
   }

Performance Characteristics
---------------------------

C++ provides several performance advantages:

**Compilation Benefits**:
- Source code compiled directly to machine code
- Compiler optimizations (-O2, -O3 flags)
- Link-time optimization for better performance
- No interpreter or virtual machine overhead

**Memory Efficiency**:
- Precise control over memory layout
- No garbage collection pauses
- Stack allocation for temporary objects
- Custom allocators for specific use cases

**Threading and Concurrency**:
- Direct access to OS threading primitives
- Low-overhead thread creation
- Lock-free programming techniques available
- NUMA-aware memory allocation possible

Runtime Environment Details
===========================

Native Code Execution
---------------------

Our C++ implementation runs as native machine code:

**Compilation Process**:
1. g++ parses C++ source code
2. Compiler generates assembly language
3. Assembler creates object files (.o)
4. Linker combines object files with libraries
5. Final executable contains native CPU instructions

**Runtime Characteristics**:
- Direct CPU instruction execution
- No interpreter or bytecode virtual machine
- Operating system loads executable into memory
- CPU cache optimization applies directly
- SIMD instructions can be used for performance

Library Linking
---------------

Our implementation uses dynamic linking:

**Shared Libraries**:
- libcurl.so: HTTP client functionality
- libmicrohttpd.so: HTTP server functionality
- libc.so: Standard C library functions

**Linking Process**:

.. code-block:: bash

   g++ -o webwords main.cpp -lcurl -lmicrohttpd
   # -lcurl links against libcurl
   # -lmicrohttpd links against libmicrohttpd

**Runtime Library Loading**:

.. code-block:: bash

   ldd webwords
   # Shows which shared libraries are required at runtime

System Integration
-----------------

C++ applications integrate directly with the operating system:

**System Calls**:
- Network sockets for HTTP communication
- Memory allocation through kernel interfaces
- Thread creation via pthread or similar APIs
- File I/O operations for logging and data

**Process Management**:
- Single process with multiple threads
- Each HTTP request handled in separate thread
- Shared memory space for efficient data access
- System scheduler manages thread execution

Further Learning
===============

Next Steps with C++ and Systems Programming
-------------------------------------------

1. **Learn Core C++ Concepts**:
   - Object-oriented programming (classes, inheritance)
   - Template programming and generic code
   - Standard Template Library (STL) containers and algorithms
   - Modern C++ features (C++11, C++14, C++17, C++20)

2. **Explore Systems Programming**:
   - Network programming with sockets
   - Multi-threading and concurrent programming
   - Memory management and performance optimization
   - Operating system interfaces and system calls

3. **Practice with Real Projects**:
   - Build web servers and network clients
   - Create database interfaces and file processors
   - Develop real-time applications and games
   - Contribute to open-source C++ projects

4. **Advanced Topics**:
   - Template metaprogramming and compile-time computation
   - Lock-free programming and atomic operations
   - SIMD programming for high-performance computing
   - Embedded systems and microcontroller programming

Recommended Resources
--------------------

- **C++ Primer** by Stanley Lippman: Comprehensive C++ language guide
- **Effective C++** by Scott Meyers: Best practices and idioms
- **Systems Programming** by John Shapley Gray: OS-level programming
- **cppreference.com**: Comprehensive C++ language reference
- **Compiler Explorer (godbolt.org)**: See generated assembly code
- **Valgrind**: Memory debugging and profiling tool

C++ Development Tools
--------------------

- **Compilers**: GCC, Clang, MSVC for different platforms
- **Build Systems**: CMake, Make, Ninja for project management
- **Debuggers**: GDB, LLDB for debugging native code
- **IDEs**: Qt Creator, CLion, Visual Studio for development
- **Static Analysis**: Clang Static Analyzer, PVS-Studio for code quality
- **Profilers**: Perf, Intel VTune for performance analysis

This implementation demonstrates how C++ can be used for high-performance web services, showcasing the language's strengths in systems programming, manual resource management, and native performance optimization.