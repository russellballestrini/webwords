WebWords - MATLAB Implementation
=================================

This directory contains the MATLAB implementation of the WebWords service, demonstrating mathematical analysis and statistical computing concepts.

What is Programming?
====================

Programming is the process of creating instructions for computers to follow. Think of it like writing a recipe - you provide step-by-step instructions that the computer follows exactly. Just as a recipe tells you how to cook a meal, a computer program tells the computer how to solve problems or perform tasks.

Programming languages are different ways of writing these instructions. Some languages are good for web applications, others for mobile apps, and some (like MATLAB) are specially designed for mathematical and scientific computing.

What is MATLAB?
===============

MATLAB (Matrix Laboratory) is a specialized programming language and environment designed specifically for mathematical computing, data analysis, and engineering applications. Unlike general programming languages, MATLAB is built around matrices and mathematical operations.

Key characteristics of MATLAB:

- **Mathematical Focus**: Built specifically for numerical computation and analysis
- **Interactive Environment**: You can type commands and see results immediately
- **Visualization**: Excellent tools for creating graphs, plots, and data visualizations  
- **Toolboxes**: Specialized collections of functions for specific fields (signal processing, machine learning, etc.)
- **Industry Standard**: Widely used in engineering, research, finance, and scientific computing

Real-world MATLAB applications:
- Automotive companies use it to design control systems
- Financial firms use it for risk analysis and algorithmic trading
- Medical researchers use it to analyze patient data and medical imaging
- Aerospace engineers use it to model flight systems

What is Mathematical Computing?
===============================

Mathematical computing involves using computers to solve mathematical problems that would be difficult or impossible to solve by hand. This includes:

- **Statistical Analysis**: Finding patterns in data, calculating averages, standard deviations
- **Linear Algebra**: Working with matrices and vectors (lists of numbers)
- **Signal Processing**: Analyzing sound, images, or sensor data
- **Modeling**: Creating mathematical representations of real-world systems

MATLAB excels at these tasks because it treats everything as matrices (grids of numbers) and provides built-in functions for common mathematical operations.

What are Runtime Environments?
==============================

A runtime environment is the software infrastructure needed to run programs written in a specific language. Think of it like the kitchen equipment needed to follow a recipe:

- **Just as a recipe needs**: An oven, stove, mixing bowls, measuring cups
- **A MATLAB program needs**: MATLAB interpreter, mathematical libraries, memory management

Runtime Environment Components:
- **Interpreter**: The software that reads and executes MATLAB code
- **Libraries**: Pre-written mathematical functions (sin, cos, matrix operations, etc.)
- **Memory Manager**: Handles storing and organizing data during calculations
- **Toolboxes**: Specialized function collections for specific domains

Our Docker Implementation Approach:
Since full MATLAB requires expensive licensing, our implementation uses:
- **Octave compatibility**: Open-source MATLAB-compatible interpreter
- **Shell wrapper**: Handles HTTP requests and calls mathematical processing
- **bc calculator**: Performs mathematical operations in a MATLAB-like style

Docker Overview
===============

Docker is a tool that packages applications into containers - think of containers as lightweight, portable virtual machines that include everything needed to run an application.

Why use Docker for MATLAB?
- **Environment Consistency**: Ensures mathematical libraries work the same everywhere
- **Dependency Management**: Includes all required mathematical tools and libraries
- **Portability**: Can run on any system with Docker installed
- **Isolation**: Prevents conflicts with other software on the host system

Our Dockerfile Breakdown
========================

Let's examine each line of our Dockerfile and understand what it does:

.. code-block:: dockerfile

   FROM ubuntu:22.04

**Line 1 - Base Image Selection**:
This tells Docker to start with Ubuntu Linux version 22.04 as our foundation. Ubuntu is chosen because:
- Excellent package management for installing mathematical tools
- Good compatibility with open-source MATLAB alternatives
- Stable platform for running mathematical computations

.. code-block:: dockerfile

   RUN apt-get update && apt-get install -y \
       curl \
       socat \
       ca-certificates \
       bc \
       && rm -rf /var/lib/apt/lists/*

**Lines 4-9 - Installing Mathematical Tools**:
- ``apt-get update``: Downloads the latest package list from Ubuntu repositories
- ``curl``: Tool for downloading web content (for fetching target URLs)
- ``socat``: Network tool for handling HTTP connections (like a simple web server)
- ``ca-certificates``: Security certificates for HTTPS connections
- ``bc``: Command-line calculator for mathematical operations (MATLAB alternative)
- ``rm -rf /var/lib/apt/lists/*``: Cleans up package cache to keep container small

.. code-block:: dockerfile

   WORKDIR /app
   COPY webwords.m .
   COPY webwords-http.sh .
   COPY request-handler.sh .
   COPY matlab_process.sh .

**Lines 11-15 - Setting up Application Files**:
- ``WORKDIR /app``: Creates and switches to the /app directory (like cd /app)
- ``COPY`` commands: Copy our MATLAB code and shell scripts into the container
- ``.`` means "copy to current directory" (which is /app)

.. code-block:: dockerfile

   RUN chmod +x webwords-http.sh request-handler.sh matlab_process.sh

**Line 17 - Making Scripts Executable**:
``chmod +x`` makes the shell scripts executable (like programs you can run).
This is necessary because by default, copied files can't be executed.

.. code-block:: dockerfile

   EXPOSE 31337
   CMD ["./webwords-http.sh"]

**Lines 19-21 - Server Configuration**:
- ``EXPOSE 31337``: Tells Docker our application listens on port 31337
- ``CMD``: Specifies which program to run when the container starts

Understanding the Code
======================

What is an HTTP Server?
-----------------------

An HTTP server is a program that waits for requests from web browsers and responds with information. Think of it like a restaurant:

- **Client (Browser)**: Customer who places an order
- **HTTP Request**: The customer's order ("I want potato search results")
- **Server (Our Program)**: Restaurant that prepares and serves the food
- **HTTP Response**: The prepared meal delivered to the customer

Our HTTP server listens on port 31337 and responds to requests like:
``http://localhost:31337/?keyword=potato&target=https://example.com``

Line-by-Line Code Explanation
-----------------------------

**MATLAB Processing Function (webwords.m)**:

.. code-block:: matlab

   function webwords_process()
       % MATLAB/Octave WebWords Processing Function

**Lines 1-2 - Function Declaration**:
- ``function``: MATLAB keyword that starts a function definition
- ``webwords_process()``: Name of our function (like naming a recipe)
- ``%``: MATLAB comment symbol (like // in other languages)

.. code-block:: matlab

   if exist('/tmp/keyword.txt', 'file')
       fid = fopen('/tmp/keyword.txt', 'r');
       keyword = fgetl(fid);
       fclose(fid);

**Lines 8-11 - Reading Input Files**:
- ``exist()``: MATLAB function that checks if a file exists
- ``fopen()``: Opens a file for reading ('r' means read mode)
- ``fgetl()``: Reads one line from the file
- ``fclose()``: Closes the file (important for memory management)

This code reads the search keyword from a temporary file that the HTTP wrapper created.

.. code-block:: matlab

   keyword_length = length(keyword);
   target_length = length(target);
   analysis_vector = [keyword_length, target_length];
   mean_length = mean(analysis_vector);

**Lines 35-40 - Mathematical Analysis**:
- ``length()``: MATLAB function that counts characters in a string
- ``[]``: Creates a vector (list) containing the two lengths
- ``mean()``: Calculates the average of the numbers in the vector
- ``std()``: Calculates the standard deviation (measure of variability)

This demonstrates MATLAB's strength in mathematical operations - we can easily perform statistical analysis on our data.

.. code-block:: matlab

   analysis_data = struct();
   analysis_data.keyword = keyword;
   analysis_data.result = result;
   save('/tmp/matlab_analysis.mat', 'analysis_data');

**Lines 53-64 - Data Structure Creation**:
- ``struct()``: Creates a MATLAB structure (like a container with labeled compartments)
- ``.keyword``: Accesses a field in the structure (like a labeled box)
- ``save()``: Saves the data structure to a .mat file (MATLAB's data format)

**HTTP Wrapper Scripts**:

Our implementation uses shell scripts to handle HTTP requests because:
- MATLAB excels at mathematical processing, not web servers
- Shell scripts are perfect for text processing and HTTP parsing
- This separation follows good programming practice (each tool does what it's best at)

.. code-block:: bash

   socat TCP-LISTEN:31337,reuseaddr,fork EXEC:"/app/request-handler.sh"

**HTTP Server Setup**:
- ``socat``: Network utility that creates a simple HTTP server
- ``TCP-LISTEN:31337``: Listen for connections on port 31337
- ``fork``: Handle multiple requests simultaneously
- ``EXEC``: Run our request handler script for each request

.. code-block:: bash

   KEYWORD=$(echo "$QUERY" | sed -n "s/.*keyword=\([^&]*\).*/\1/p")
   TARGET=$(echo "$QUERY" | sed -n "s/.*target=\([^&]*\).*/\1/p")

**Parameter Extraction**:
- ``sed``: Stream editor for filtering and transforming text
- Regular expressions extract the keyword and target URL from the HTTP request
- URL decoding converts %20 to spaces, %3A to colons, etc.

Key Programming Concepts
========================

Variables in MATLAB
-------------------

Variables store information for later use. In MATLAB, variables can hold:

.. code-block:: matlab

   keyword = 'potato';           % String (text)
   length_value = 6;             % Number (scalar)
   data_vector = [1, 2, 3, 4];   % Vector (list of numbers)
   analysis_result = struct();    % Structure (organized data)

MATLAB treats everything as matrices, so even single numbers are 1x1 matrices.

Functions in MATLAB
-------------------

Functions are reusable blocks of code that perform specific tasks:

.. code-block:: matlab

   function result = analyze_keyword(keyword)
       result = struct();
       result.length = length(keyword);
       result.vowel_count = sum(ismember(lower(keyword), 'aeiou'));
   end

- ``function``: Declares a new function
- ``result =``: Specifies what the function returns
- Function body contains the mathematical operations
- ``end``: Marks the end of the function

Mathematical Operations
-----------------------

MATLAB provides built-in functions for complex mathematical operations:

.. code-block:: matlab

   mean_value = mean([1, 2, 3, 4, 5]);      % Average
   std_value = std([1, 2, 3, 4, 5]);        % Standard deviation
   char_codes = double('hello');             % Convert text to numbers
   vowel_count = sum(ismember(text, 'aeiou')); % Count vowels

Data Structures
---------------

MATLAB structures organize related data:

.. code-block:: matlab

   analysis = struct();
   analysis.keyword = 'potato';
   analysis.length = 6;
   analysis.mean_ascii = 112.5;

This creates a container with labeled compartments for organizing analysis results.

Building and Running (Complete Beginner Guide)
==============================================

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

   cd /home/fox/git/webwords/matlab

This changes your current directory to where the MATLAB code is located. Think of it like navigating to a specific folder.

If you get "No such file or directory", the code might be in a different location. Ask where the webwords project is stored.

Step 3: Build with Docker
-------------------------

Type this command and press Enter:

.. code-block:: bash

   docker build -t webwords-matlab .

**What this does**:
- ``docker build``: Tells Docker to create a container image
- ``-t webwords-matlab``: Names the image "webwords-matlab"  
- ``.``: Use the current directory (which contains our Dockerfile)

**What you'll see**:
- Docker downloads Ubuntu Linux
- Installs mathematical tools (curl, socat, bc)
- Copies our MATLAB code into the container
- Sets up the runtime environment

This may take 2-5 minutes the first time.

Step 4: Run the Container
------------------------

Type this command:

.. code-block:: bash

   docker run -d -p 31337:31337 --name test-matlab webwords-matlab

**What this does**:
- ``docker run``: Starts a container from our image
- ``-d``: Run in background (detached mode)
- ``-p 31337:31337``: Connect port 31337 inside container to port 31337 on your computer
- ``--name test-matlab``: Give the container a friendly name
- ``webwords-matlab``: Use the image we just built

Step 5: Test the Mathematical Analysis Service
---------------------------------------------

**Test 1 - Positive Case** (should find "potato"):

.. code-block:: bash

   curl "http://localhost:31337/?keyword=potato&target=https://www.remarkbox.com"

Expected result: ``true``

**Test 2 - Negative Case** (should not find "lemon"):

.. code-block:: bash

   curl "http://localhost:31337/?keyword=lemon&target=https://www.remarkbox.com"

Expected result: ``false``

Step 6: View Mathematical Analysis Logs
---------------------------------------

To see the MATLAB-style analysis output:

.. code-block:: bash

   docker logs test-matlab

You should see mathematical analysis reports showing:
- Keyword and target URL analysis
- Statistical calculations (mean, standard deviation)
- Data structure information

Step 7: Clean Up
----------------

When you're done testing:

.. code-block:: bash

   docker stop test-matlab
   docker rm test-matlab

This stops and removes the test container.

Understanding What the Program Does
===================================

When you visit ``http://localhost:31337/?keyword=potato&target=https://www.remarkbox.com``:

**Step 1**: Your browser sends an HTTP request to our MATLAB service
**Step 2**: The socat server receives the request and calls request-handler.sh
**Step 3**: The shell script extracts "potato" and "https://www.remarkbox.com" from the URL
**Step 4**: curl downloads the target webpage content
**Step 5**: grep searches for "potato" in the webpage content  
**Step 6**: The result ("true" or "false") is saved to temporary files
**Step 7**: matlab_process.sh is called to perform mathematical analysis
**Step 8**: MATLAB code reads the inputs and performs statistical analysis:
   - Calculates keyword and URL lengths
   - Computes mean and standard deviation
   - Creates analysis vectors and data structures
   - Saves results in MATLAB .mat format
**Step 9**: The HTTP response "true" or "false" is sent back to your browser

**Mathematical Analysis Features**:
- Character-level analysis of keywords
- ASCII value calculations and statistics
- Vowel/consonant counting algorithms
- Complexity scoring based on mathematical formulas
- Data structure creation and persistence

What Happens When It Runs
=========================

**Runtime Environment Setup**:
1. Docker creates an isolated environment with Ubuntu Linux
2. Mathematical tools (bc calculator, curl) are loaded into memory
3. MATLAB-compatible processing environment is initialized
4. HTTP server (socat) begins listening on port 31337

**Request Processing Flow**:
1. HTTP request arrives with keyword and target URL parameters
2. Shell scripts parse the request using text processing tools
3. URL content is fetched using curl with timeout protection
4. Pattern matching searches for keyword in the content
5. Temporary files store the results for MATLAB processing
6. Mathematical analysis functions are executed:
   - Statistical calculations on text data
   - Data structure creation and manipulation
   - Results logging and persistence
7. HTTP response is formatted and sent back

**Mathematical Computing in Action**:
- Vector operations on character data
- Statistical analysis of text properties
- Data structure manipulation and storage
- Numerical analysis of search parameters

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

Problem: "Port 31337 is already in use"
--------------------------------------

**Cause**: Another application or container is using port 31337.

**Solution 1** - Find and stop the conflicting process:

.. code-block:: bash

   docker ps | grep 31337
   docker stop <container-name>

**Solution 2** - Use a different port:

.. code-block:: bash

   docker run -d -p 32337:31337 --name test-matlab webwords-matlab
   curl "http://localhost:32337/?keyword=potato&target=https://www.remarkbox.com"

Problem: Container starts but doesn't respond
--------------------------------------------

**Cause**: The HTTP server might not be binding correctly.

**Diagnosis**:

.. code-block:: bash

   docker logs test-matlab

**Look for**: "listening on 0.0.0.0:31337" message

**Solution**: If you don't see the listening message, restart the container:

.. code-block:: bash

   docker restart test-matlab

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

Problem: Mathematical Analysis Not Working
-----------------------------------------

**Symptoms**: Service responds with true/false but no analysis logs

**Diagnosis**:

.. code-block:: bash

   docker exec -it test-matlab /bin/bash
   ls -la /tmp/

**Look for**: keyword.txt, target.txt, result.txt files

**Solution**: If files are missing, the HTTP parsing isn't working correctly. Check the logs:

.. code-block:: bash

   docker logs test-matlab

Mathematical Computing Concepts
===============================

What Makes MATLAB Special?
--------------------------

MATLAB is designed around matrices and mathematical operations:

**Traditional Programming Languages**:
- Focus on general-purpose computing
- Manual implementation of mathematical functions
- Complex syntax for numerical operations

**MATLAB Approach**:
- Everything is a matrix by default
- Built-in mathematical functions
- Optimized for numerical computation
- Interactive development environment

**Example Comparison**:

.. code-block:: c

   // C language - manual implementation
   float mean(float data[], int size) {
       float sum = 0;
       for(int i = 0; i < size; i++) {
           sum += data[i];
       }
       return sum / size;
   }

.. code-block:: matlab

   % MATLAB - built-in function
   result = mean(data);

Statistical Analysis Features
----------------------------

Our implementation demonstrates these MATLAB concepts:

**Descriptive Statistics**:
- Mean (average) calculation
- Standard deviation (variability measure)
- Data distribution analysis

**Data Structures**:
- Struct creation and manipulation
- Field assignment and access
- Data persistence in .mat format

**Text Processing**:
- String length analysis
- ASCII value extraction and statistics
- Character classification (vowels/consonants)

Working with Matrices and Vectors
---------------------------------

MATLAB treats all data as matrices:

.. code-block:: matlab

   scalar = 5;              % 1x1 matrix
   vector = [1, 2, 3];      % 1x3 matrix  
   matrix = [1, 2; 3, 4];   % 2x2 matrix

Operations work element-wise:

.. code-block:: matlab

   data = [1, 2, 3, 4, 5];
   squared = data .^ 2;     % [1, 4, 9, 16, 25]
   mean_val = mean(data);   % 3
   std_val = std(data);     % 1.5811

Runtime Environment Details
===========================

Mathematical Libraries
----------------------

Our container includes mathematical computation tools:

**bc Calculator**: 
- Command-line mathematical processor
- Arbitrary precision arithmetic
- MATLAB-like mathematical operations

**Shell Mathematical Functions**:
- Text processing for numerical data
- Statistical calculations via external tools
- Data persistence through file operations

**HTTP Processing Environment**:
- Network request handling via socat
- URL parsing and parameter extraction
- Content fetching with curl

Memory Management
----------------

Mathematical computing requires careful memory management:

**Data Storage**:
- Temporary files for data exchange between processes
- Structured data persistence in MATLAB format
- Memory-efficient text processing

**Process Coordination**:
- HTTP server process manages incoming requests
- Mathematical analysis runs as separate process
- Clean resource handling and cleanup

**Runtime Optimization**:
- Minimal container overhead
- Fast mathematical computation startup
- Efficient data transfer between components

Further Learning
===============

Next Steps with MATLAB/Mathematical Computing
--------------------------------------------

1. **Learn Core MATLAB Syntax**:
   - Basic operations and functions
   - Matrix manipulation
   - Plotting and visualization

2. **Explore Mathematical Concepts**:
   - Linear algebra fundamentals
   - Statistical analysis methods
   - Signal processing basics

3. **Practice with Real Data**:
   - Import CSV files and analyze data
   - Create visualizations and plots
   - Perform regression analysis

4. **Advanced Topics**:
   - Machine learning with MATLAB
   - Image processing and computer vision
   - Control systems and simulation

Recommended Resources
--------------------

- **MATLAB Onramp**: Free interactive MATLAB tutorial from MathWorks
- **GNU Octave Documentation**: Open-source MATLAB alternative
- **Coursera/edX**: Mathematical computing courses
- **Khan Academy**: Statistics and linear algebra fundamentals

Mathematical Computing Applications
----------------------------------

- **Engineering**: Control systems, signal processing, simulation
- **Finance**: Risk analysis, algorithmic trading, portfolio optimization  
- **Science**: Data analysis, modeling, statistical research
- **Industry**: Quality control, process optimization, predictive maintenance

This implementation demonstrates how mathematical computing concepts can be integrated into web services, showing the bridge between academic mathematics and practical software applications.