WebWords - Fortran Implementation
==================================

This directory contains the Fortran implementation of the WebWords service using GFortran and a socat-based HTTP wrapper.

Docker Overview
---------------

Our Docker implementation combines modern Fortran with contemporary HTTP handling:

.. code-block:: dockerfile

   FROM gcc:latest
   
   RUN apt-get update && apt-get install -y \
       gfortran-14 \
       netcat-traditional \
       socat \
       curl \
       ca-certificates \
       && rm -rf /var/lib/apt/lists/*
   
   WORKDIR /app
   COPY webwords.f90 .
   COPY webwords-http.sh .
   COPY request-handler.sh .
   
   # Compile Fortran program
   RUN gfortran-14 -o webwords webwords.f90
   
   # Make scripts executable
   RUN chmod +x webwords-http.sh request-handler.sh
   
   EXPOSE 31337
   
   CMD ["./webwords-http.sh"]

The implementation uses a hybrid architecture:

1. **Base Image**: GCC container with comprehensive build tools
2. **Fortran Compiler**: GFortran 14 for modern Fortran standards
3. **HTTP Layer**: socat for reliable TCP connection handling
4. **Request Processing**: Bash scripts for HTTP protocol handling
5. **URL Fetching**: curl for external HTTP requests

Fortran Language Fundamentals
-----------------------------

Fortran (Formula Translation) is one of the oldest high-level programming languages, continuously evolved for scientific computing:

**Key Characteristics:**

- **Age**: Created in 1954, still actively developed (Fortran 2023)
- **Paradigm**: Procedural with object-oriented features (modern Fortran)
- **Performance**: Compiled to highly optimized machine code
- **Scientific Focus**: Excellent for numerical computations and simulations
- **Array Operations**: Native support for mathematical array operations
- **Standardized**: International standards ensure portability

**Why Fortran for WebWords:**

Fortran excels at:

- **Structured Programming**: Clear program organization with modules and procedures
- **File I/O Operations**: Robust file handling for data processing
- **String Processing**: Modern Fortran has improved string capabilities
- **Error Handling**: Explicit error checking and status reporting
- **Performance**: Fast execution for computational tasks

**Fortran vs Other Languages:**

- **Mathematical**: ``result = sum(array)`` vs loops in other languages
- **Explicit**: Variable declarations and intent declarations
- **Modular**: ``use module`` vs ``#include`` or ``import``
- **Scientific**: Built for numerical analysis and scientific computing

**Fortran Evolution:**

- **Fortran 77**: Structured programming, still widely used
- **Fortran 90/95**: Free-form source, modules, pointers
- **Fortran 2003**: Object-oriented programming, C interoperability  
- **Fortran 2008**: Coarrays for parallel programming
- **Fortran 2018**: Further parallelism and modern features

Architecture and Dependencies
-----------------------------

**Hybrid Architecture Explained:**

While modern Fortran has some networking capabilities, HTTP server implementation requires extensive low-level programming. Our solution uses a layered approach:

.. code-block:: text

   ┌─────────────────┐
   │  HTTP Client    │ (curl request)
   └─────────┬───────┘
             │
   ┌─────────▼───────┐
   │   socat Server  │ (handles TCP connections)
   └─────────┬───────┘
             │
   ┌─────────▼───────┐
   │  Bash Handler   │ (parses HTTP, processes requests)
   └─────────┬───────┘
             │
   ┌─────────▼───────┐
   │ Fortran Program │ (data processing & logging)
   └─────────────────┘

**Component Responsibilities:**

1. **socat**: Creates a TCP server listening on port 31337
2. **request-handler.sh**: Parses HTTP requests and extracts parameters
3. **curl**: Fetches content from target URLs
4. **webwords.f90**: Processes data, performs logging, and validation
5. **File Interface**: Communication between shell and Fortran via files

**Why This Approach:**

- **Fortran Strengths**: Data processing, numerical operations, file I/O
- **Shell Strengths**: System integration, HTTP protocol handling
- **Performance**: Fortran compiled code for computational efficiency
- **Maintainability**: Clear separation between protocol and logic layers

Fortran Program Structure
-------------------------

Our Fortran program follows modern Fortran 2008+ standards:

**Program Structure:**
::

   program webwords
       implicit none
       
       ! Variable declarations
       character(len=256) :: keyword, target, result_str
       character(len=512) :: log_message
       integer :: keyword_unit, target_unit, result_unit, log_unit
       integer :: ios
       
       ! Main program logic
       call read_input_files()
       call log_result()
       
   contains
       ! Internal procedures
   end program webwords

**Key Features:**

- **implicit none**: Requires explicit variable declarations (modern practice)
- **character(len=N)**: Fixed-length character variables for data storage
- **integer**: I/O unit numbers and status codes
- **contains**: Internal procedures within the program unit

**Modern Fortran Features Used:**

- **Free-form source**: No column restrictions from Fortran 77
- **Internal procedures**: Subroutines contained within the main program
- **Parameterized length**: ``character(len=256)`` for flexible string storage
- **Intent declarations**: Clear parameter passing intentions

File I/O and Data Processing
----------------------------

**File-Based Communication:**

Fortran excels at structured file operations, which we leverage for inter-process communication:

.. code-block:: fortran

   subroutine read_input_files()
       implicit none
       
       ! Initialize variables
       keyword = 'unknown'
       target = 'unknown'
       result_str = 'false'
       
       ! Read keyword file
       open(newunit=keyword_unit, file='/tmp/keyword.txt', status='old', iostat=ios)
       if (ios == 0) then
           read(keyword_unit, '(A)', iostat=ios) keyword
           close(keyword_unit)
       end if

**File I/O Features:**

- **newunit**: Automatic unit number assignment (Fortran 2008)
- **iostat**: Error status checking for robust file operations
- **status='old'**: Expects existing file, fails gracefully if missing
- **format='(A)'**: Character format for string reading

**Error Handling:**

.. code-block:: fortran

   ! Robust file operations with error checking
   open(newunit=result_unit, file='/tmp/result.txt', status='old', iostat=ios)
   if (ios == 0) then
       read(result_unit, '(A)', iostat=ios) result_str
       close(result_unit)
   end if

**Data Validation:**

Fortran's strong typing provides inherent data validation:

- **Character lengths**: Prevent buffer overflows
- **Intent declarations**: Clear parameter usage (in/out/inout)
- **Explicit interfaces**: Compile-time argument checking

HTTP Request Flow
-----------------

**Complete Request Processing:**

1. **Client Request**: ``GET /?keyword=potato&target=https://example.com``

2. **socat Reception**: TCP server accepts the connection

3. **Shell Parsing**: 
   ::

      # URL decode and extract parameters
      keyword=$(urldecode "${param#keyword=}")
      target=$(urldecode "${param#target=}")

4. **URL Fetching**:
   ::

      body=$(curl -s --max-time 10 "$target" 2>/dev/null || echo "")

5. **Keyword Matching**:
   ::

      if [[ "$body" == *"$keyword"* ]]; then
          found="true"
      else
          found="false"
      fi

6. **Fortran Processing**:
   ::

      # Create input files for Fortran
      echo "$keyword" > /tmp/keyword.txt
      echo "$target" > /tmp/target.txt
      echo "$found" > /tmp/result.txt
      
      # Execute Fortran program
      /app/webwords

7. **Fortran Data Processing**:
   .. code-block:: fortran

      ! Read input data
      call read_input_files()
      
      ! Process and log results
      call log_result()

8. **HTTP Response**:
   ::

      HTTP/1.1 200 OK
      Content-Type: text/plain
      Content-Length: 4
      
      true

Fortran Logging Implementation
------------------------------

**Structured Logging:**

.. code-block:: fortran

   subroutine log_result()
       implicit none
       
       ! Open log file for appending
       open(newunit=log_unit, file='/tmp/webwords.log', status='unknown', &
            position='append', iostat=ios)
       
       if (ios == 0) then
           ! Create formatted log message
           write(log_message, '(A,A,A,A,A,A,A,A)') &
               'FORTRAN WebWords: keyword=', trim(keyword), &
               ', target=', trim(target), &
               ', result=', trim(result_str)
           
           ! Write to log file
           write(log_unit, '(A)') trim(log_message)
           close(log_unit)
       end if
   end subroutine log_result

**Fortran I/O Features:**

- **status='unknown'**: Creates file if it doesn't exist
- **position='append'**: Adds to end of existing file
- **trim()**: Removes trailing spaces from strings
- **Formatted I/O**: Precise control over output format

**String Manipulation:**

.. code-block:: fortran

   ! Modern Fortran string concatenation
   write(log_message, '(A,A,A,A,A,A,A,A)') &
       'FORTRAN WebWords: keyword=', trim(keyword), &
       ', target=', trim(target), &
       ', result=', trim(result_str)

Build and Test Process
----------------------

**Building the Application:**

.. code-block:: bash

   # Navigate to Fortran directory
   cd /home/fox/git/webwords/fortran
   
   # Build Docker image
   docker build -t webwords-fortran .
   
   # Run container
   docker run -d -p 31337:31337 --name fortran-server webwords-fortran

**Testing the Service:**

.. code-block:: bash

   # Test positive case (keyword found)
   curl "http://localhost:31337/?keyword=potato&target=https://www.remarkbox.com"
   # Expected output: true
   
   # Test negative case (keyword not found)
   curl "http://localhost:31337/?keyword=lemon&target=https://www.remarkbox.com"
   # Expected output: false

**Compilation Verification:**

.. code-block:: bash

   # Check Fortran compilation
   docker exec fortran-server gfortran-14 --version
   
   # Verify compiled binary
   docker exec fortran-server ls -la /app/webwords

**Monitoring and Debugging:**

.. code-block:: bash

   # Check container logs
   docker logs fortran-server
   
   # View Fortran log file
   docker exec fortran-server cat /tmp/webwords.log
   
   # Debug Fortran program directly
   docker exec -it fortran-server /app/webwords

**Expected Log Output:**
::

   FORTRAN WebWords: keyword=potato, target=https://www.remarkbox.com, result=true
   FORTRAN WebWords: keyword=lemon, target=https://www.remarkbox.com, result=false

Troubleshooting Common Issues
-----------------------------

**Compilation Issues:**

*Problem*: ``gfortran: command not found``

*Solution*: Fortran compiler not installed
::

   # Install GFortran
   apt-get update && apt-get install -y gfortran-14

*Problem*: ``Error: Unexpected end of file``

*Solution*: Missing ``end program`` statement or syntax error
::

   # Check program structure
   program webwords
       ! ... code ...
   end program webwords

**Runtime Issues:**

*Problem*: ``Fortran runtime error: End of file``

*Solution*: Input files missing or empty
::

   # Verify input files exist
   ls -la /tmp/keyword.txt /tmp/target.txt /tmp/result.txt
   
   # Check file contents
   cat /tmp/keyword.txt

*Problem*: ``Fortran runtime error: File already open``

*Solution*: File unit not properly closed
::

   # Always close files after use
   if (ios == 0) then
       read(unit, ...) data
       close(unit)  ! Important!
   end if

**Fortran-Specific Issues:**

*Problem*: String truncation in output

*Solution*: Increase character variable lengths
::

   ! Increase sizes for longer data
   character(len=512) :: keyword    ! Was len=256
   character(len=1024) :: target    ! Was len=512

*Problem*: ``Format error`` in write statements

*Solution*: Check format specifications
::

   ! Correct format for character data
   write(unit, '(A)') trim(string)  ! Good
   write(unit, *) trim(string)      ! Free format alternative

**Performance Optimization:**

*Problem*: Slow file I/O operations

*Solution*: Use appropriate I/O methods
::

   ! Use unformatted I/O for large data
   ! Use direct access for random file access
   ! Buffer multiple operations when possible

Modern Fortran Features
-----------------------

**Object-Oriented Programming (Fortran 2003+):**

While our implementation uses procedural style, modern Fortran supports:

- **Derived types**: Custom data structures
- **Type-bound procedures**: Methods associated with types
- **Inheritance**: Extending existing types
- **Polymorphism**: Runtime type selection

**Parallel Programming:**

- **Coarrays**: Built-in parallel programming model
- **OpenMP**: Shared-memory parallelization
- **MPI**: Message-passing for distributed computing

**Interoperability:**

- **C Interoperability**: Call C functions from Fortran
- **ISO C Binding**: Standard interface to C libraries
- **Mixed-language programming**: Combine with C/C++

Performance Considerations
--------------------------

**Fortran Performance Advantages:**

- **Compiled Code**: Machine code execution, not interpreted
- **Compiler Optimizations**: Advanced mathematical optimizations
- **Array Operations**: Vectorized operations on large datasets
- **Memory Layout**: Predictable memory access patterns

**Optimization Flags:**

.. code-block:: bash

   # Performance compilation options
   gfortran-14 -O3 -march=native -funroll-loops webwords.f90
   
   # Debug compilation options  
   gfortran-14 -g -fcheck=all -Wall webwords.f90

**Memory Management:**

- **Static Arrays**: Fixed-size arrays for predictable memory usage
- **Allocatable Arrays**: Dynamic memory allocation when needed
- **Automatic Variables**: Compiler-managed local variables

Scientific Computing Applications
---------------------------------

**Real-World Fortran Usage:**

- **Weather Prediction**: Numerical weather models
- **Computational Fluid Dynamics**: Engineering simulations
- **Quantum Chemistry**: Molecular modeling software
- **Financial Modeling**: Risk analysis and derivatives pricing
- **Climate Research**: Global climate models

**Why Fortran Remains Relevant:**

- **Performance**: Decades of compiler optimization
- **Legacy Code**: Massive codebases in production
- **Numerical Stability**: Careful handling of floating-point arithmetic
- **Scientific Libraries**: BLAS, LAPACK, and other optimized libraries

Further Learning Resources
--------------------------

**Modern Fortran:**

- Fortran-lang.org: https://fortran-lang.org/
- Modern Fortran Tutorial: https://fortran-lang.org/learn/
- Fortran 2018 Standard: ISO/IEC 1539-1:2018

**Compilers and Tools:**

- GFortran: https://gcc.gnu.org/fortran/
- Intel Fortran Compiler: High-performance commercial compiler
- NAG Fortran Compiler: Standards-compliant compiler with excellent diagnostics

**Scientific Computing:**

- Fortran Package Manager (fpm): https://fpm.fortran-lang.org/
- BLAS/LAPACK: Linear algebra libraries
- PETSc: Parallel scientific computing toolkit
- NumPy for Fortran: Scientific computing libraries

**Community:**

- Fortran Discourse: https://fortran-lang.discourse.group/
- r/fortran: Reddit community for Fortran programmers
- Stack Overflow: Active Fortran tag for Q&A

**Books:**

- "Modern Fortran Explained" by Metcalf, Reid, and Cohen
- "Introduction to Programming with Fortran" by Nyhoff and Leestma
- "Fortran 95/2003 for Scientists and Engineers" by Chapman

This Fortran implementation demonstrates how a language optimized for scientific computing can be effectively used in modern web service architectures while maintaining its computational efficiency and robust data handling capabilities.