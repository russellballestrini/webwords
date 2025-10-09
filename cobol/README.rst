WebWords - COBOL Implementation
===============================

This directory contains the COBOL implementation of the WebWords service, demonstrating how a traditional business-oriented language can be adapted for modern web service functionality.

Docker Overview
---------------

Our Dockerfile creates a hybrid implementation combining COBOL business logic with shell scripting for HTTP handling:

.. code-block:: dockerfile

   FROM debian:bookworm-slim
   RUN apt-get update && apt-get install -y \
       gnucobol4 \
       socat \
       curl \
       ca-certificates
   
   # Compile COBOL program
   RUN cobc -x -o webwords webwords.cob

The implementation uses:

- **GnuCOBOL**: Modern, open-source COBOL compiler and runtime
- **socat**: TCP server for handling HTTP connections
- **curl**: For fetching content from target URLs
- **Shell scripting**: HTTP request parsing and response formatting

COBOL Language Fundamentals
---------------------------

COBOL (Common Business-Oriented Language) is a high-level programming language designed for business applications:

- **English-like syntax**: Uses English words and phrases for readability
- **Fixed-format**: Traditional column-based source code layout
- **Business-oriented**: Designed for data processing, file handling, and reports
- **Compiled**: Source code is compiled to machine code or bytecode
- **Structured**: Well-defined divisions and sections for program organization

Key COBOL Characteristics:

.. code-block:: cobol

   IDENTIFICATION DIVISION.
   PROGRAM-ID. HELLO-WORLD.
   
   PROCEDURE DIVISION.
   DISPLAY "Hello, World!".
   STOP RUN.

**COBOL Program Structure**:

1. **IDENTIFICATION DIVISION**: Program metadata and documentation
2. **ENVIRONMENT DIVISION**: File associations and system dependencies  
3. **DATA DIVISION**: Variable declarations and file descriptions
4. **PROCEDURE DIVISION**: Executable program logic

Why COBOL for Web Services?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

While COBOL wasn't designed for web services, it offers several valuable features:

- **Data processing**: Excellent for structured data handling and validation
- **File operations**: Robust file I/O capabilities for logging and storage
- **Business logic**: Natural fit for business rule implementation
- **Reliability**: Proven stability in enterprise environments
- **Legacy integration**: Bridges modern web services with existing COBOL systems

**Modern COBOL**: Contemporary COBOL compilers like GnuCOBOL support modern features including dynamic memory allocation, object-oriented programming, and integration with other languages.

Implementation Architecture
----------------------------

This implementation uses a **hybrid wrapper approach** where COBOL handles business logic and logging:

**1. HTTP Server Layer (Shell + socat)**:

.. code-block:: bash

   # Creates TCP server listening on port 31337
   socat TCP-LISTEN:31337,fork,reuseaddr SYSTEM:"/app/request-handler.sh"

**2. Request Processing (Shell scripting)**:

.. code-block:: bash

   # Parse HTTP request and extract parameters
   if [[ "$REQUEST_LINE" =~ ^GET\ ([^\ ]+) ]]; then
       path_query="${BASH_REMATCH[1]}"
       # Extract keyword and target parameters
   fi

**3. Content Fetching (curl)**:

.. code-block:: bash

   # Fetch target URL content
   body=$(curl -s --max-time 10 "$target" 2>/dev/null || echo "")

**4. Business Logic and Logging (COBOL)**:

.. code-block:: cobol

   PROCEDURE DIVISION.
   MAIN-SECTION.
       PERFORM READ-INPUT-FILES.
       PERFORM LOG-RESULT.
       STOP RUN.

Code Structure Walkthrough
--------------------------

**webwords.cob** - The COBOL business logic program:

**IDENTIFICATION DIVISION**:

.. code-block:: cobol

   IDENTIFICATION DIVISION.
   PROGRAM-ID. WEBWORDS.

Defines the program name and metadata.

**ENVIRONMENT DIVISION**:

.. code-block:: cobol

   ENVIRONMENT DIVISION.
   INPUT-OUTPUT SECTION.
   FILE-CONTROL.
       SELECT WS-LOG-FILE ASSIGN TO "/tmp/webwords.log"
       ORGANIZATION IS SEQUENTIAL
       ACCESS MODE IS SEQUENTIAL.

Defines file associations and I/O configuration.

**DATA DIVISION**:

.. code-block:: cobol

   WORKING-STORAGE SECTION.
   01 WS-KEYWORD PIC X(256).
   01 WS-TARGET PIC X(512).
   01 WS-RESULT PIC X(10).

Declares variables with PICTURE clauses:
- ``PIC X(256)``: String field, 256 characters maximum
- ``PIC X(512)``: String field, 512 characters maximum
- ``PIC X(10)``: String field, 10 characters maximum

**PROCEDURE DIVISION**:

.. code-block:: cobol

   PROCEDURE DIVISION.
   MAIN-SECTION.
       PERFORM READ-INPUT-FILES.
       PERFORM LOG-RESULT.
       STOP RUN.

Main program logic with structured paragraph calls.

**File Processing Logic**:

.. code-block:: cobol

   READ-INPUT-FILES.
       OPEN INPUT KEYWORD-FILE.
       READ KEYWORD-FILE INTO WS-KEYWORD
           AT END MOVE "unknown" TO WS-KEYWORD.
       CLOSE KEYWORD-FILE.

Demonstrates COBOL's robust file handling:
- ``OPEN INPUT``: Opens file for reading
- ``READ ... INTO``: Reads record into working storage
- ``AT END``: Error handling clause
- ``CLOSE``: Properly closes file

**String Manipulation**:

.. code-block:: cobol

   STRING "COBOL WebWords: keyword=" 
          FUNCTION TRIM(WS-KEYWORD)
          ", target=" 
          FUNCTION TRIM(WS-TARGET)
          ", result=" 
          FUNCTION TRIM(WS-RESULT)
   INTO WS-LOG-MESSAGE.

COBOL string operations:
- ``STRING ... INTO``: Concatenates multiple strings
- ``FUNCTION TRIM``: Removes leading/trailing spaces
- Automatic memory management for string operations

HTTP Request Flow
-----------------

1. **Connection**: socat accepts TCP connection on port 31337
2. **Request Parsing**: Shell script processes HTTP request line and headers
3. **Parameter Extraction**: Bash extracts keyword and target from query string
4. **Content Fetching**: curl retrieves content from target URL
5. **Keyword Search**: Bash checks if keyword exists in fetched content
6. **COBOL Processing**: Parameters and results written to temporary files
7. **Business Logic**: COBOL program processes files and creates audit log
8. **Response**: HTTP response sent with "true" or "false" result

Example Request Processing:

.. code-block:: bash

   # Input: GET /?keyword=potato&target=https://www.remarkbox.com HTTP/1.1
   # Shell: Extracts keyword="potato", target="https://www.remarkbox.com"
   # Fetch: curl -s "https://www.remarkbox.com"
   # Search: [[ "$body" == *"potato"* ]]
   # Files: keyword -> /tmp/keyword.txt, target -> /tmp/target.txt, result -> /tmp/result.txt
   # COBOL: Processes files and writes to /tmp/webwords.log
   # Response: "true" or "false"

COBOL File Operations
---------------------

**File Definition**:

.. code-block:: cobol

   FILE-CONTROL.
       SELECT WS-LOG-FILE ASSIGN TO "/tmp/webwords.log"
       ORGANIZATION IS SEQUENTIAL
       ACCESS MODE IS SEQUENTIAL.

**File Record Structure**:

.. code-block:: cobol

   FD WS-LOG-FILE.
   01 WS-LOG-RECORD PIC X(200).

**File Processing Pattern**:

.. code-block:: cobol

   OPEN EXTEND WS-LOG-FILE.      # Open for appending
   MOVE WS-LOG-MESSAGE TO WS-LOG-RECORD.
   WRITE WS-LOG-RECORD.          # Write record to file
   CLOSE WS-LOG-FILE.            # Close file properly

Building and Running
--------------------

**Build the Docker image**:

.. code-block:: bash

   cd /home/fox/git/webwords/cobol
   docker build -t webwords-cobol .

**Run the container**:

.. code-block:: bash

   docker run -d -p 31337:31337 --name webwords-cobol-instance webwords-cobol

**Test the service**:

.. code-block:: bash

   # Test positive case (should find "potato")
   curl "http://localhost:31337/?keyword=potato&target=https://www.remarkbox.com"
   # Expected response: true

   # Test negative case (should not find "lemon")
   curl "http://localhost:31337/?keyword=lemon&target=https://www.remarkbox.com"
   # Expected response: false

**View COBOL audit logs**:

.. code-block:: bash

   docker exec webwords-cobol-instance cat /tmp/webwords.log

**Stop and clean up**:

.. code-block:: bash

   docker stop webwords-cobol-instance
   docker rm webwords-cobol-instance

COBOL Programming Best Practices
---------------------------------

**Data Definition**:

.. code-block:: cobol

   01 WS-CUSTOMER-RECORD.
      05 WS-CUSTOMER-ID    PIC 9(8).
      05 WS-CUSTOMER-NAME  PIC X(50).
      05 WS-ACCOUNT-BALANCE PIC 9(7)V99.

**Error Handling**:

.. code-block:: cobol

   READ CUSTOMER-FILE INTO WS-CUSTOMER-RECORD
       AT END 
           DISPLAY "End of file reached"
           MOVE 'Y' TO WS-EOF-FLAG
       NOT AT END
           PERFORM PROCESS-CUSTOMER-RECORD
   END-READ.

**Structured Programming**:

.. code-block:: cobol

   PROCEDURE DIVISION.
   MAIN-LOGIC.
       PERFORM INITIALIZATION.
       PERFORM PROCESS-DATA UNTIL WS-EOF-FLAG = 'Y'.
       PERFORM CLEANUP.
       STOP RUN.

Modern COBOL Features
---------------------

**GnuCOBOL Extensions**:
- Dynamic memory allocation
- Function pointers
- Object-oriented programming
- Integration with C libraries
- Modern data types and operations

**Contemporary Usage**:
- Mainframe modernization projects
- Legacy system integration
- Financial and banking applications
- Government and enterprise systems
- Teaching structured programming concepts

COBOL Learning Resources
------------------------

**Core Concepts**:
- COBOL program structure and divisions
- PICTURE clauses and data definition
- File operations and record processing
- Structured programming with PERFORM
- String manipulation and arithmetic

**Advanced Features**:
- Table (array) processing with OCCURS
- Conditional logic with EVALUATE
- Subprogram calls and parameter passing
- Sort and merge operations
- Report generation facilities

**Recommended Learning Path**:
1. Understand COBOL program structure and divisions
2. Learn data definition with PICTURE clauses
3. Practice file operations and record processing
4. Study structured programming with PERFORM statements
5. Explore modern COBOL features and object-oriented extensions
6. Work on business logic and data processing projects

**Historical Context**:
COBOL was developed in 1959 by a committee led by Grace Hopper for the U.S. Department of Defense. It was designed to be readable by business managers and has remained in production use for over 60 years, powering critical systems in banking, government, and enterprise environments worldwide.

This implementation demonstrates COBOL's enduring relevance and adaptability, showing how traditional business programming languages can be integrated into modern web service architectures while maintaining their core strengths in data processing and business logic implementation.