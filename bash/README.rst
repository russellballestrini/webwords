WebWords - Bash Implementation
==============================

This directory contains the Bash implementation of the WebWords service, demonstrating how shell scripting can be used to create a functional HTTP server.

Docker Overview
---------------

Our Dockerfile creates a lightweight server environment using Alpine Linux:

.. code-block:: dockerfile

   FROM alpine:latest
   RUN apk add --no-cache bash curl socat ca-certificates
   WORKDIR /app
   COPY webwords.sh .
   RUN chmod +x webwords.sh

The implementation uses:

- **bash**: Advanced shell with array support and regular expressions
- **socat**: Multi-purpose relay tool for creating TCP servers
- **curl**: Command-line HTTP client for fetching web content
- **ca-certificates**: SSL/TLS certificate bundle for HTTPS requests

Bash Language Fundamentals
---------------------------

Bash (Bourne Again Shell) is a powerful command-line interpreter and scripting language:

- **Interpreted**: Scripts are executed line-by-line by the bash interpreter
- **Procedural**: Follows a procedural programming paradigm with functions
- **String-oriented**: Excellent text processing capabilities with pattern matching
- **System integration**: Native access to system commands and processes
- **Cross-platform**: Available on most Unix-like systems including Linux and macOS

Key Bash Features:

.. code-block:: bash

   # Variables and parameter expansion
   name="example"
   echo "${name}"                    # Parameter expansion
   echo "${name#prefix}"            # Remove prefix pattern
   echo "${name%suffix}"            # Remove suffix pattern
   
   # Arrays
   array=("item1" "item2" "item3")
   echo "${array[0]}"               # First element
   echo "${array[@]}"               # All elements
   
   # Conditional expressions
   if [[ "$var" == "value" ]]; then
       echo "Match found"
   fi
   
   # Regular expressions
   if [[ "$text" =~ ^GET\ ([^\ ]+) ]]; then
       path="${BASH_REMATCH[1]}"
   fi

Why Bash for Web Services?
~~~~~~~~~~~~~~~~~~~~~~~~~~~

While Bash isn't typically used for web servers, it offers several advantages:

- **System commands**: Direct access to curl, grep, sed, and other text processing tools
- **Process management**: Easy spawning and coordination of multiple processes
- **Text processing**: Strong pattern matching and string manipulation capabilities
- **Rapid prototyping**: Quick development and testing of HTTP-based services
- **Debugging**: Extensive logging and error handling capabilities

Implementation Architecture
----------------------------

The Bash implementation uses **socat** to create a proper TCP server that handles HTTP requests:

**1. TCP Server Setup**:

.. code-block:: bash

   # socat creates a TCP server listening on port 31337
   socat TCP-LISTEN:31337,reuseaddr,fork SYSTEM:'bash -c handle_http'

**2. HTTP Request Processing**:

.. code-block:: bash

   handle_http() {
       # Read HTTP request line
       read -r request_line
       
       # Read and discard headers until empty line
       while IFS= read -r line; do
           line=${line%$'\r'}  # Remove carriage return
           [[ -z "$line" ]] && break
       done
       
       # Process the request
       handle_request "$request_line"
   }

**3. URL Parsing with Regular Expressions**:

.. code-block:: bash

   if [[ $request_line =~ ^GET\ ([^\ ]+)\ HTTP ]]; then
       local path_query="${BASH_REMATCH[1]}"
       local path="${path_query%%\?*}"      # Extract path
       local query="${path_query#*\?}"      # Extract query string
   fi

Code Structure Walkthrough
--------------------------

**URL Decoding Function**:

.. code-block:: bash

   urldecode() {
       local url_encoded="${1//+/ }"        # Replace + with spaces
       printf '%b' "${url_encoded//%/\\x}"  # Convert %XX to characters
   }

This function handles URL percent-encoding:
- Replaces ``+`` symbols with spaces
- Converts ``%20`` to spaces, ``%3A`` to colons, etc.

**Query Parameter Parsing**:

.. code-block:: bash

   parse_query() {
       local query="$1"
       IFS='&' read -ra PARAMS <<< "$query"  # Split by & into array
       
       for param in "${PARAMS[@]}"; do
           if [[ $param == keyword=* ]]; then
               keyword=$(urldecode "${param#keyword=}")  # Remove prefix
           elif [[ $param == target=* ]]; then
               target=$(urldecode "${param#target=}")
           fi
       done
       
       echo "$keyword|$target"  # Return as pipe-separated values
   }

**Content Fetching**:

.. code-block:: bash

   fetch_url() {
       local url="$1"
       curl -s --max-time 10 "$url" 2>/dev/null || echo ""
   }

Uses curl with:
- ``-s``: Silent mode (no progress output)
- ``--max-time 10``: 10-second timeout
- ``2>/dev/null``: Suppress error messages

**HTTP Response Generation**:

.. code-block:: bash

   local content_length=${#found}  # Calculate response body length
   echo -e "HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\nContent-Length: $content_length\r\n\r\n$found"

HTTP Request Flow
-----------------

1. **Connection**: socat accepts incoming TCP connection
2. **Request Reading**: Bash reads HTTP request line and headers
3. **URL Parsing**: Regular expressions extract path and query parameters
4. **Parameter Extraction**: Query string parsed for keyword and target
5. **Content Fetching**: curl retrieves content from target URL
6. **Keyword Search**: String matching checks if keyword exists in content
7. **Response**: Properly formatted HTTP response sent to client

Example Request Processing:

.. code-block:: bash

   # Input: GET /?keyword=potato&target=https://www.remarkbox.com HTTP/1.1
   # Parsed: path="/", query="keyword=potato&target=https://www.remarkbox.com"
   # Extracted: keyword="potato", target="https://www.remarkbox.com"
   # Fetch: curl -s "https://www.remarkbox.com"
   # Search: [[ "$body" == *"potato"* ]]
   # Response: "true" or "false"

Advanced Bash Features Used
---------------------------

**Parameter Expansion**:

.. code-block:: bash

   ${var%%pattern}    # Remove longest match of pattern from end
   ${var##pattern}    # Remove longest match of pattern from beginning
   ${var#pattern}     # Remove shortest match of pattern from beginning
   ${var%pattern}     # Remove shortest match of pattern from end

**Regular Expressions**:

.. code-block:: bash

   if [[ $string =~ pattern ]]; then
       echo "${BASH_REMATCH[1]}"  # First captured group
   fi

**Arrays**:

.. code-block:: bash

   IFS='&' read -ra ARRAY <<< "$string"  # Split string into array
   for element in "${ARRAY[@]}"; do     # Iterate over array elements
       echo "$element"
   done

Building and Running
--------------------

**Build the Docker image**:

.. code-block:: bash

   cd /home/fox/git/webwords/bash
   docker build -t webwords-bash .

**Run the container**:

.. code-block:: bash

   docker run -d -p 31337:31337 --name webwords-bash-instance webwords-bash

**Test the service**:

.. code-block:: bash

   # Test positive case (should find "potato")
   curl "http://localhost:31337/?keyword=potato&target=https://www.remarkbox.com"
   # Expected response: true

   # Test negative case (should not find "lemon")
   curl "http://localhost:31337/?keyword=lemon&target=https://www.remarkbox.com"
   # Expected response: false

**View logs**:

.. code-block:: bash

   docker logs webwords-bash-instance

**Stop and clean up**:

.. code-block:: bash

   docker stop webwords-bash-instance
   docker rm webwords-bash-instance

Bash Scripting Best Practices
------------------------------

**Error Handling**:

.. code-block:: bash

   set -euo pipefail  # Exit on error, undefined vars, pipe failures

**Quoting**:

.. code-block:: bash

   echo "$variable"        # Always quote variables
   command "${array[@]}"   # Quote array expansions

**Function Design**:

.. code-block:: bash

   function_name() {
       local param1="$1"   # Use local variables
       local param2="$2"
       # Function body
   }

**Pattern Matching**:

.. code-block:: bash

   case "$variable" in
       pattern1) action1 ;;
       pattern2) action2 ;;
       *) default_action ;;
   esac

Bash Learning Resources
-----------------------

**Core Concepts**:
- Variables and parameter expansion
- Command substitution and process substitution
- Conditional expressions and control structures
- Functions and local variables
- Arrays and associative arrays

**Advanced Topics**:
- Regular expressions and pattern matching
- Process management and job control
- Input/output redirection
- Signal handling and traps
- Debugging with set -x and trap

**Recommended Learning Path**:
1. Master basic syntax and variable handling
2. Learn control structures (if, while, for, case)
3. Practice with functions and parameter passing
4. Study pattern matching and regular expressions
5. Explore advanced features like process substitution
6. Learn debugging techniques and best practices

This implementation demonstrates Bash's capabilities as a systems programming language, showcasing its text processing power, system integration features, and surprising flexibility for building network services.