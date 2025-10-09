WebWords - AWK Implementation
=============================

This directory contains the AWK implementation of the WebWords service, demonstrating how a text processing language can be adapted for web service functionality.

Docker Overview
---------------

Our Dockerfile creates a hybrid implementation using AWK for text processing combined with shell scripting for HTTP handling:

.. code-block:: dockerfile

   FROM alpine:latest
   RUN apk add --no-cache gawk curl socat ca-certificates
   WORKDIR /app
   COPY webwords.awk .
   RUN chmod +x webwords.awk

The implementation uses:

- **gawk**: GNU AWK interpreter for text processing logic
- **socat**: For creating a TCP server that listens on port 31337
- **curl**: For fetching content from target URLs
- **Shell scripting**: For HTTP request parsing and response formatting

AWK Language Fundamentals
--------------------------

AWK is a pattern-scanning and text-processing language designed for data extraction and reporting:

- **Interpreted**: AWK scripts are executed line-by-line by the AWK interpreter
- **Pattern-action**: Programs consist of patterns (conditions) and actions (code blocks)
- **Text-oriented**: Excels at processing structured text data, especially line-based formats
- **Built-in variables**: Automatic handling of input records, fields, and line numbers
- **Regular expressions**: Native support for pattern matching and text manipulation

Key AWK Characteristics:

.. code-block:: awk

   # Pattern-action structure
   BEGIN { print "Starting..." }        # Executes before processing input
   /pattern/ { action }                 # Executes when pattern matches
   END { print "Finished." }           # Executes after all input processed

Why AWK for Web Services?
~~~~~~~~~~~~~~~~~~~~~~~~~

While AWK wasn't designed for web services, it demonstrates several interesting capabilities:

- **Text processing**: Excellent for parsing HTTP headers and query parameters
- **Pattern matching**: Built-in regex support for URL parsing and content searching
- **System integration**: Can execute external commands (curl) for HTTP requests
- **String manipulation**: Rich set of string functions for data processing

Implementation Architecture
----------------------------

Since AWK lacks native networking capabilities, this implementation uses a hybrid approach:

**1. HTTP Server Layer (Shell + socat)**:

.. code-block:: bash

   # Creates TCP server listening on port 31337
   socat TCP-LISTEN:31337,reuseaddr,fork EXEC:./handle_request.sh

**2. Request Processing (Shell scripting)**:

.. code-block:: bash

   # Parse HTTP request line
   QUERY=$(echo "$REQUEST" | sed "s/GET \/?\([^ ]*\).*/\1/")
   KEYWORD=$(echo "$QUERY" | sed -n "s/.*keyword=\([^&]*\).*/\1/p")
   TARGET=$(echo "$QUERY" | sed -n "s/.*target=\([^&]*\).*/\1/p")

**3. Content Fetching (curl)**:

.. code-block:: bash

   # Fetch target URL content
   BODY=$(curl -s --max-time 10 "$TARGET" 2>/dev/null || echo "")

**4. Text Processing (AWK capability demonstration)**:

.. code-block:: awk

   # AWK functions for text processing
   function parse_query(query_string,    params, pairs, i, kv) {
       delete params
       split(query_string, pairs, "&")
       for (i in pairs) {
           if (split(pairs[i], kv, "=") == 2) {
               params[kv[1]] = kv[2]
           }
       }
       return length(params)
   }

Code Structure Walkthrough
--------------------------

**webwords.awk** - The core AWK program:

.. code-block:: awk

   BEGIN {
       # Initialization block - runs once at startup
       port = 31337
       keyword = ""
       target = ""
       found = "false"
       
       print "listening on 0.0.0.0:" port " (AWK simulation)"
   }

**Key Functions**:

1. **simulate_request()**: Demonstrates how AWK would process a request
2. **parse_query()**: Shows AWK's text parsing capabilities for URL parameters
3. **url_decode()**: Basic URL decoding using AWK string manipulation

**Dockerfile-generated scripts**:

- **handle_request.sh**: Processes incoming HTTP requests
- **webwords.sh**: Main server startup script

HTTP Request Flow
-----------------

1. **Connection**: socat accepts TCP connection on port 31337
2. **Request Reading**: Shell script reads HTTP request headers
3. **Parameter Extraction**: sed commands parse keyword and target from query string
4. **URL Fetching**: curl retrieves content from target URL
5. **Content Search**: grep searches for keyword in fetched content
6. **Response**: HTTP response sent with "true" or "false" result

Example Request Processing:

.. code-block:: bash

   # Input: GET /?keyword=potato&target=https://www.remarkbox.com HTTP/1.1
   # Extracted: keyword=potato, target=https://www.remarkbox.com
   # Fetch: curl -s "https://www.remarkbox.com"
   # Search: grep "potato" in content
   # Response: HTTP/1.1 200 OK with body "true" or "false"

Building and Running
--------------------

**Build the Docker image**:

.. code-block:: bash

   cd /home/fox/git/webwords/awk
   docker build -t webwords-awk .

**Run the container**:

.. code-block:: bash

   docker run -d -p 31337:31337 --name webwords-awk-instance webwords-awk

**Test the service**:

.. code-block:: bash

   # Test positive case (should find "potato")
   curl "http://localhost:31337/?keyword=potato&target=https://www.remarkbox.com"
   # Expected response: true

   # Test negative case (should not find "lemon")
   curl "http://localhost:31337/?keyword=lemon&target=https://www.remarkbox.com"
   # Expected response: false

**Stop and clean up**:

.. code-block:: bash

   docker stop webwords-awk-instance
   docker rm webwords-awk-instance

AWK Learning Resources
----------------------

**Core Concepts**:
- Pattern-action programming model
- Built-in variables (NR, NF, FS, RS)
- Field processing ($1, $2, $3, etc.)
- Regular expression patterns
- String functions (gsub, sub, index, split)

**Advanced Features**:
- Associative arrays
- User-defined functions
- External command execution with system()
- Input/output redirection
- Mathematical operations and functions

**Recommended Learning Path**:
1. Start with simple text processing tasks
2. Learn pattern matching with regular expressions
3. Practice with CSV/TSV file processing
4. Explore associative arrays for data aggregation
5. Study advanced string manipulation functions

This implementation showcases AWK's flexibility as a text processing tool, even when adapted for unconventional use cases like web services, demonstrating the language's power in parsing, pattern matching, and system integration scenarios.