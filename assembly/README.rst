WebWords - Assembly Implementation
==================================

This directory contains the Assembly implementation of the WebWords service.

.. note::
   Assembly is one of the lowest-level programming languages, making HTTP servers extremely complex to implement natively. This implementation uses a shell script wrapper with `socat` to handle HTTP communication while demonstrating Assembly concepts.

Docker Overview
---------------

Our Dockerfile creates a practical HTTP server using a multi-layered approach:

.. code-block:: dockerfile

   FROM ubuntu:22.04
   RUN apt-get update && apt-get install -y \
       nasm \
       binutils \
       socat \
       curl \
       ca-certificates

The build process:

1. **Base Image**: Ubuntu 22.04 for comprehensive tool support
2. **Assembly Tools**: NASM (Netwide Assembler) and binutils for compilation
3. **HTTP Tools**: socat for connection handling, curl for web requests
4. **Wrapper Scripts**: Shell scripts to bridge Assembly and HTTP protocols

Assembly Language Fundamentals
------------------------------

Assembly language is the most fundamental level of programming above machine code:

**Core Concepts:**

- **Registers**: CPU's built-in storage locations (RAX, RBX, RCX, etc.)
- **Instructions**: Direct CPU operations (MOV, ADD, CALL, etc.)  
- **Memory**: Direct access to system memory addresses
- **System Calls**: Direct interface to operating system functions
- **Stack**: Memory region for function calls and local variables

**Why Assembly is Challenging for HTTP:**

HTTP servers require:

- Complex string processing (Assembly works with individual bytes)
- Network programming (requires extensive system call knowledge)
- Memory management (manual allocation/deallocation)
- Protocol parsing (HTTP headers, URL decoding, etc.)

A complete HTTP server in Assembly would require 1000+ lines of intricate code.

Architecture and Dependencies
----------------------------

**Assembly Program (webwords.asm):**

The Assembly file demonstrates core language features:

.. code-block:: asm

   section .data
       http_response db 'HTTP/1.1 200 OK', 13, 10, ...
       
   section .bss
       sockfd resq 1    ; Socket file descriptor
       buffer resb 1024 ; Input buffer
       
   section .text
       global _start
   _start:
       ; Assembly code here

**HTTP Wrapper (handle_request.sh):**

Since Assembly HTTP is impractical, we use a shell wrapper:

- **socat**: Handles TCP connections and HTTP protocol
- **curl**: Fetches web content from target URLs
- **sed**: Parses URL parameters from HTTP requests
- **grep**: Searches for keywords in fetched content

Code Walkthrough
---------------

**Assembly Demonstration:**

The Assembly code shows fundamental concepts:

.. code-block:: asm

   ; Print startup message
   mov rax, 1              ; sys_write system call
   mov rdi, 1              ; stdout file descriptor  
   mov rsi, listening_msg  ; message address
   mov rdx, listening_len  ; message length
   syscall                 ; invoke system call

**HTTP Wrapper Logic:**

.. code-block:: bash

   # Parse HTTP request
   read REQUEST
   QUERY=$(echo "$REQUEST" | sed "s/GET \/?\([^ ]*\).*/\1/")
   
   # Extract parameters
   KEYWORD=$(echo "$QUERY" | sed -n "s/.*keyword=\([^&]*\).*/\1/p")
   TARGET=$(echo "$QUERY" | sed -n "s/.*target=\([^&]*\).*/\1/p")
   
   # Fetch and search
   BODY=$(curl -s --max-time 10 "$TARGET")
   if echo "$BODY" | grep -q "$KEYWORD"; then
       RESULT="true"
   else
       RESULT="false"
   fi

Build and Deployment
-------------------

**Prerequisites:**

- Docker installed and running
- Internet connection for package installation

**Building the Image:**

.. code-block:: bash

   cd /path/to/webwords/assembly
   docker build -t webwords-assembly .

**Running the Service:**

.. code-block:: bash

   docker run -d -p 31337:31337 --name webwords-assembly webwords-assembly

**Testing the Service:**

.. code-block:: bash

   # Test positive case (should return "true")
   curl "http://localhost:31337/?keyword=potato&target=https://www.remarkbox.com"
   
   # Test negative case (should return "false")  
   curl "http://localhost:31337/?keyword=lemon&target=https://www.remarkbox.com"

**Expected Output:**

- Positive test: ``true``
- Negative test: ``false``

Troubleshooting
--------------

**Common Issues:**

1. **Build Failures:**
   
   - Ensure Docker has internet access for package downloads
   - Check that port 31337 is not already in use

2. **Connection Refused:**
   
   - Wait 2-3 seconds after starting container for socat initialization
   - Verify container is running: ``docker ps``

3. **Always Returns "false":**
   
   - Check container logs: ``docker logs webwords-assembly``
   - Verify target URL is accessible and contains expected content

**Performance Considerations:**

- Shell wrapper adds overhead compared to native implementations
- Suitable for demonstration and educational purposes
- Production systems would use higher-level languages

Learning Assembly
----------------

**Next Steps:**

1. **Basic Assembly Tutorial**: Learn registers, instructions, and memory
2. **System Programming**: Understand system calls and OS interfaces  
3. **Network Programming**: Study socket programming in Assembly
4. **NASM Documentation**: Master the assembler syntax and features

**Recommended Resources:**

- Programming from the Ground Up (Assembly textbook)
- Intel 64 and IA-32 Architecture Software Developer's Manual
- Linux Assembly HOWTO
- NASM Documentation and Tutorial

**Important Note:**

This implementation prioritizes educational value and practical functionality over pure Assembly implementation. Real-world Assembly HTTP servers require extensive low-level networking code that would obscure the core language concepts this example aims to demonstrate.