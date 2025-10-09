WebWords - PowerShell Implementation
====================================

This directory contains the PowerShell implementation of the WebWords service, demonstrating object-oriented scripting and .NET framework integration concepts.

What is Programming?
====================

Programming is the process of creating instructions for computers to follow. Think of it like writing a detailed recipe - you provide step-by-step instructions that the computer follows exactly. Just as a recipe tells you how to cook a meal, a computer program tells the computer how to solve problems or perform tasks.

Programming languages are different ways of writing these instructions. Some languages are good for web applications, others for mobile apps, and some (like PowerShell) are specially designed for system administration and automation.

What is PowerShell?
===================

PowerShell is a powerful command-line shell and scripting language built on top of the .NET framework. Unlike traditional command-line interfaces that work with text, PowerShell works with .NET objects, making it incredibly powerful for automation and system administration.

Key characteristics of PowerShell:

- **Object-Oriented**: Works with .NET objects instead of just text
- **Cross-Platform**: Runs on Windows, Linux, and macOS  
- **Cmdlet-Based**: Uses verb-noun commands (Get-Process, Set-Location, etc.)
- **Pipeline Power**: Can pass complex objects between commands
- **Automation Focus**: Designed for scripting and system administration
- **.NET Integration**: Full access to .NET framework libraries

Real-world PowerShell applications:
- System administrators use it to manage servers and workstations
- DevOps engineers use it for deployment automation
- Cloud engineers use it to manage Azure and AWS resources
- Database administrators use it for SQL Server management
- Network administrators use it for network device configuration

What are Interpreters?
======================

An interpreter is a program that reads and executes code line-by-line, without needing to compile the entire program first. Think of it like a translator who translates a speech in real-time:

- **Compiled Languages** (like C++): Translate the entire program to machine code before running (like translating a whole book)
- **Interpreted Languages** (like PowerShell): Translate and execute one instruction at a time (like real-time interpretation)

PowerShell Interpreter Characteristics:
- **Interactive Mode**: You can type commands and see results immediately
- **Script Mode**: Run entire files of PowerShell code
- **Object Pipeline**: Pass rich .NET objects between commands
- **Error Handling**: Detailed error information and stack traces
- **.NET Runtime**: Built on top of .NET Core runtime environment

What are Runtime Environments?
==============================

A runtime environment is the software infrastructure needed to run programs written in a specific language. Think of it like the stage setup needed for a theater performance:

- **Just as a play needs**: A stage, lighting, sound system, props
- **A PowerShell script needs**: .NET runtime, PowerShell engine, system libraries, cmdlets

PowerShell Runtime Environment Components:
- **.NET Runtime**: Core execution environment that manages memory and provides base services
- **PowerShell Engine**: Interprets PowerShell syntax and manages execution
- **Cmdlet Library**: Built-in commands for common tasks (Get-Content, Invoke-RestMethod, etc.)
- **Module System**: Extensible library system for adding functionality
- **Execution Policy**: Security system that controls script execution
- **Provider System**: Interface for accessing different data stores (filesystem, registry, etc.)

Our Docker Implementation:
- **PowerShell Core**: Cross-platform version that runs on Linux
- **HTTP Listener**: .NET HttpListener class for web server functionality
- **REST Integration**: Invoke-RestMethod for HTTP client capabilities
- **Object Processing**: Native .NET string and object manipulation

Docker Overview
===============

Docker is a tool that packages applications into containers - think of containers as lightweight, portable virtual machines that include everything needed to run an application.

Why use Docker for PowerShell?
- **Runtime Consistency**: Ensures PowerShell Core and .NET runtime work the same everywhere
- **Cross-Platform**: Run PowerShell scripts on any system with Docker
- **Dependency Management**: Includes all required .NET libraries and PowerShell modules
- **Isolation**: Prevents conflicts with other software on the host system
- **Portability**: Same container works on Windows, Linux, and macOS

Our Dockerfile Breakdown
========================

Let's examine each line of our Dockerfile and understand what it does:

.. code-block:: dockerfile

   FROM mcr.microsoft.com/powershell:latest

**Line 1 - Base Image Selection**:
This tells Docker to start with Microsoft's official PowerShell container image. This image includes:
- PowerShell Core (cross-platform version)
- .NET runtime environment
- All necessary PowerShell cmdlets and modules
- Optimized Linux environment for PowerShell execution

.. code-block:: dockerfile

   WORKDIR /app
   COPY webwords.ps1 .

**Lines 3-4 - Application Setup**:
- ``WORKDIR /app``: Creates and switches to the /app directory (like cd /app)
- ``COPY webwords.ps1 .``: Copies our PowerShell script into the container
- ``.`` means "copy to current directory" (which is /app)

.. code-block:: dockerfile

   # Execution policy not needed in Linux containers

**Line 6 - Security Comment**:
This comment explains that PowerShell's execution policy (security feature) isn't needed in Linux containers because:
- Execution policies are primarily a Windows security feature
- Linux containers provide isolation through containerization
- Scripts run in controlled, isolated environment

.. code-block:: dockerfile

   EXPOSE 31337
   CMD ["pwsh", "-ExecutionPolicy", "Bypass", "-File", "./webwords.ps1"]

**Lines 8-10 - Server Configuration**:
- ``EXPOSE 31337``: Tells Docker our application listens on port 31337
- ``CMD``: Specifies which program to run when the container starts
- ``pwsh``: PowerShell Core executable
- ``-ExecutionPolicy Bypass``: Allows script execution (security override for container)
- ``-File ./webwords.ps1``: Run our specific PowerShell script

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

**Script Parameters**:

.. code-block:: powershell

   param(
       [int]$Port = 31337
   )

**Lines 2-4 - Parameter Declaration**:
- ``param()``: PowerShell keyword for declaring script parameters
- ``[int]``: Type constraint - ensures Port is an integer
- ``$Port = 31337``: Default value if no port is specified when running the script
- ``$`` prefix: PowerShell variables always start with $

**HTTP Listener Setup**:

.. code-block:: powershell

   $listener = New-Object System.Net.HttpListener
   $listener.Prefixes.Add("http://+:$Port/")

**Lines 7-8 - Server Creation**:
- ``New-Object``: PowerShell cmdlet that creates .NET objects
- ``System.Net.HttpListener``: .NET class for HTTP server functionality
- ``$listener``: Variable to store our server object
- ``Prefixes.Add()``: Tells the server which URLs to listen for
- ``http://+:$Port/``: Listen on all network interfaces on the specified port

**Server Startup**:

.. code-block:: powershell

   try {
       $listener.Start()
       Write-Host "listening on 0.0.0.0:$Port"

**Lines 10-12 - Error Handling and Startup**:
- ``try {}``: PowerShell error handling block (like try/catch in other languages)
- ``$listener.Start()``: Begin listening for HTTP requests
- ``Write-Host``: PowerShell cmdlet to display messages (like print in other languages)

**Request Processing Loop**:

.. code-block:: powershell

   while ($listener.IsListening) {
       $context = $listener.GetContext()
       $request = $context.Request
       $response = $context.Response

**Lines 15-20 - Main Server Loop**:
- ``while``: PowerShell loop that continues while condition is true
- ``$listener.IsListening``: Boolean property - true if server is running
- ``GetContext()``: Waits for and receives an HTTP request
- ``$context``: Contains both the request and response objects
- ``$request``: The incoming HTTP request with URL, headers, etc.
- ``$response``: The outgoing HTTP response we'll send back

**Parameter Extraction**:

.. code-block:: powershell

   $keyword = $request.QueryString["keyword"]
   $target = $request.QueryString["target"]
   $found = "false"

**Lines 23-25 - Query Parameter Processing**:
- ``QueryString[]``: .NET collection containing URL parameters
- ``["keyword"]``: Extract the keyword parameter from the URL
- ``["target"]``: Extract the target URL parameter
- ``$found = "false"``: Initialize result variable with default value

**URL Fetching and Search**:

.. code-block:: powershell

   if ($keyword -and $target) {
       $body = Invoke-RestMethod -Uri $target -Method Get -TimeoutSec 10
       $bodyStr = $body.ToString()
       if ($bodyStr.Contains($keyword)) {
           $found = "true"
       }

**Lines 27-36 - Core Logic**:
- ``if ($keyword -and $target)``: Check that both parameters exist
- ``Invoke-RestMethod``: PowerShell cmdlet for HTTP requests
- ``-Uri $target``: Specify which URL to fetch
- ``-Method Get``: Use HTTP GET method
- ``-TimeoutSec 10``: Timeout after 10 seconds if no response
- ``ToString()``: Convert response to string format
- ``Contains()``: .NET string method to search for keyword

**Response Generation**:

.. code-block:: powershell

   $response.ContentType = "text/plain"
   $responseBytes = [System.Text.Encoding]::UTF8.GetBytes($found)
   $response.ContentLength64 = $responseBytes.Length
   $response.OutputStream.Write($responseBytes, 0, $responseBytes.Length)

**Lines 47-50 - HTTP Response**:
- ``ContentType``: Tell browser this is plain text
- ``[System.Text.Encoding]::UTF8``: .NET class for text encoding
- ``GetBytes()``: Convert string to byte array for HTTP transmission
- ``ContentLength64``: Specify response size in bytes
- ``OutputStream.Write()``: Send response data to client

Key Programming Concepts
========================

Variables in PowerShell
-----------------------

PowerShell variables store .NET objects, not just text:

.. code-block:: powershell

   $name = "WebWords"              # String object
   $port = 31337                   # Integer object  
   $listener = New-Object System.Net.HttpListener  # HttpListener object
   $found = $true                  # Boolean object

Variables are strongly typed but PowerShell can automatically convert between types when needed.

Objects and Methods
------------------

PowerShell works with .NET objects that have properties and methods:

.. code-block:: powershell

   $listener = New-Object System.Net.HttpListener
   $listener.Start()               # Method: start the server
   $isRunning = $listener.IsListening  # Property: check if running
   $context = $listener.GetContext()    # Method: get next request

This is more powerful than text-based shells because you can directly manipulate complex data structures.

Error Handling
--------------

PowerShell provides structured error handling:

.. code-block:: powershell

   try {
       # Code that might fail
       $body = Invoke-RestMethod -Uri $target
   }
   catch {
       # Handle the error
       Write-Host "Error: $($_.Exception.Message)"
   }
   finally {
       # Code that always runs
       $listener.Close()
   }

Cmdlets and Pipeline
-------------------

PowerShell commands (cmdlets) follow Verb-Noun naming:

.. code-block:: powershell

   Get-Process                     # List running processes
   Set-Location                    # Change directory
   Invoke-RestMethod               # Make HTTP request
   Write-Host                      # Display output

You can pipe objects between cmdlets:

.. code-block:: powershell

   Get-Process | Where-Object {$_.CPU -gt 100} | Sort-Object CPU

This passes process objects through a filter and sort operation.

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

   cd /home/fox/git/webwords/powershell

This changes your current directory to where the PowerShell code is located. Think of it like navigating to a specific folder.

If you get "No such file or directory", the code might be in a different location. Ask where the webwords project is stored.

Step 3: Build with Docker
-------------------------

Type this command and press Enter:

.. code-block:: bash

   docker build -t webwords-powershell .

**What this does**:
- ``docker build``: Tells Docker to create a container image
- ``-t webwords-powershell``: Names the image "webwords-powershell"  
- ``.``: Use the current directory (which contains our Dockerfile)

**What you'll see**:
- Docker downloads Microsoft's PowerShell image
- Copies our PowerShell script into the container
- Sets up the .NET runtime environment

This may take 2-5 minutes the first time.

Step 4: Run the Container
------------------------

Type this command:

.. code-block:: bash

   docker run -d -p 31337:31337 --name test-powershell webwords-powershell

**What this does**:
- ``docker run``: Starts a container from our image
- ``-d``: Run in background (detached mode)
- ``-p 31337:31337``: Connect port 31337 inside container to port 31337 on your computer
- ``--name test-powershell``: Give the container a friendly name
- ``webwords-powershell``: Use the image we just built

Step 5: Test the PowerShell Web Service
---------------------------------------

**Test 1 - Positive Case** (should find "potato"):

.. code-block:: bash

   curl "http://localhost:31337/?keyword=potato&target=https://www.remarkbox.com"

Expected result: ``true``

**Test 2 - Negative Case** (should not find "lemon"):

.. code-block:: bash

   curl "http://localhost:31337/?keyword=lemon&target=https://www.remarkbox.com"

Expected result: ``false``

Step 6: View PowerShell Logs
----------------------------

To see the PowerShell output and any error messages:

.. code-block:: bash

   docker logs test-powershell

You should see:
- "listening on 0.0.0.0:31337" when the server starts
- "found=true, keyword=potato, uri=https://www.remarkbox.com" for successful searches

Step 7: Clean Up
----------------

When you're done testing:

.. code-block:: bash

   docker stop test-powershell
   docker rm test-powershell

This stops and removes the test container.

Understanding What the Program Does
===================================

When you visit ``http://localhost:31337/?keyword=potato&target=https://www.remarkbox.com``:

**Step 1**: Your browser sends an HTTP request to our PowerShell service
**Step 2**: The .NET HttpListener receives the request and creates a context object
**Step 3**: PowerShell extracts "potato" and "https://www.remarkbox.com" from the query parameters
**Step 4**: Invoke-RestMethod downloads the target webpage content
**Step 5**: PowerShell searches for "potato" in the downloaded content using .NET string methods
**Step 6**: The result ("true" or "false") is converted to bytes and sent back as an HTTP response

**PowerShell-Specific Features**:
- Object-oriented parameter handling through .NET collections
- Robust HTTP client capabilities with Invoke-RestMethod
- Strong typing and automatic type conversions
- Comprehensive error handling with structured exception information
- Cross-platform execution through PowerShell Core

What Happens When It Runs
=========================

**Runtime Environment Initialization**:
1. Docker starts PowerShell Core (.NET-based interpreter)
2. .NET runtime environment loads with garbage collection and memory management
3. PowerShell engine initializes with cmdlet library and type system
4. Our script creates an HttpListener object for web server functionality
5. Server begins listening on port 31337 for incoming HTTP requests

**Request Processing Flow**:
1. HTTP request arrives with keyword and target URL parameters
2. .NET HttpListener creates context objects containing request and response
3. PowerShell extracts parameters using .NET QueryString collection
4. Invoke-RestMethod cmdlet fetches URL content with timeout protection
5. .NET string Contains() method searches for keyword in the content
6. HTTP response is generated using .NET encoding and stream operations
7. Response is sent back to client through HttpListener

**Object-Oriented Processing**:
- Request/Response objects provide structured access to HTTP data
- String objects offer rich text manipulation methods
- Exception objects provide detailed error information
- Type conversions happen automatically when needed

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

   docker run -d -p 32337:31337 --name test-powershell webwords-powershell
   curl "http://localhost:32337/?keyword=potato&target=https://www.remarkbox.com"

Problem: Container starts but doesn't respond
--------------------------------------------

**Cause**: PowerShell might have encountered an execution error.

**Diagnosis**:

.. code-block:: bash

   docker logs test-powershell

**Look for**: "listening on 0.0.0.0:31337" message

**Common Issues**:
- Execution policy errors (should be resolved by -ExecutionPolicy Bypass)
- .NET runtime issues
- Network binding problems

**Solution**: If you see errors, check the logs for specific error messages and restart:

.. code-block:: bash

   docker restart test-powershell

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
Use PowerShell instead of Command Prompt:

.. code-block:: powershell

   Invoke-RestMethod "http://localhost:31337/?keyword=potato&target=https://www.remarkbox.com"

Problem: PowerShell Cmdlet Errors
--------------------------------

**Symptoms**: Errors about Invoke-RestMethod or other cmdlets not being available

**Cause**: PowerShell version compatibility issues

**Diagnosis**:

.. code-block:: bash

   docker exec -it test-powershell pwsh -Command "Get-Host"

**Solution**: Our container uses PowerShell Core which should include all necessary cmdlets. If issues persist, the image might be corrupted:

.. code-block:: bash

   docker rmi webwords-powershell
   docker build -t webwords-powershell .

PowerShell Concepts Deep Dive
=============================

What Makes PowerShell Different?
--------------------------------

**Traditional Shells (bash, cmd)**:
- Work with text strings
- Parse output manually
- Limited built-in functionality
- Platform-specific commands

**PowerShell Approach**:
- Work with .NET objects
- Rich data structures passed between commands
- Extensive built-in functionality through cmdlets
- Cross-platform with consistent behavior

**Example Comparison**:

.. code-block:: bash

   # Bash - text parsing required
   ps aux | grep firefox | awk '{print $2}' | head -1

.. code-block:: powershell

   # PowerShell - object manipulation
   Get-Process firefox | Select-Object -First 1 -ExpandProperty Id

Object Pipeline
---------------

PowerShell's most powerful feature is passing objects through pipelines:

.. code-block:: powershell

   # Get all running processes
   Get-Process |
   # Filter to high CPU usage
   Where-Object {$_.CPU -gt 100} |
   # Sort by memory usage
   Sort-Object WorkingSet -Descending |
   # Select top 5
   Select-Object -First 5 Name, CPU, WorkingSet

Each ``|`` passes rich objects containing properties and methods, not just text.

.NET Integration
---------------

PowerShell provides full access to .NET framework:

.. code-block:: powershell

   # Create .NET objects directly
   $listener = New-Object System.Net.HttpListener
   
   # Access static methods
   $bytes = [System.Text.Encoding]::UTF8.GetBytes("hello")
   
   # Use .NET types for parameters
   [int]$port = 31337
   [string]$keyword = "potato"

This gives PowerShell enormous power for system administration and automation.

Runtime Environment Details
===========================

PowerShell Core Architecture
----------------------------

Our container runs PowerShell Core, which consists of:

**Core Runtime Layer**:
- .NET Core runtime for cross-platform execution
- Garbage collector for automatic memory management
- Just-in-time (JIT) compiler for performance optimization

**PowerShell Engine Layer**:
- Parser for PowerShell syntax
- Execution engine for running scripts
- Variable and scope management
- Error handling and debugging support

**Cmdlet and Provider Layer**:
- Built-in cmdlets (Get-Process, Invoke-RestMethod, etc.)
- Providers for accessing different data stores
- Module system for extensibility
- Type system for .NET object manipulation

Execution Policy and Security
-----------------------------

PowerShell includes security features for script execution:

**Execution Policies** (Windows-focused):
- ``Restricted``: No scripts allowed
- ``RemoteSigned``: Local scripts OK, remote scripts need digital signatures
- ``Unrestricted``: All scripts allowed

**Container Security**:
- Our container uses ``-ExecutionPolicy Bypass`` for simplicity
- Container isolation provides security boundary
- No persistent file system access outside container

Memory and Performance
---------------------

PowerShell's .NET foundation provides:

**Automatic Memory Management**:
- Garbage collection handles object cleanup
- No manual memory allocation/deallocation
- Memory leaks are rare due to GC

**Performance Characteristics**:
- JIT compilation improves performance over time
- Object creation overhead compared to text processing
- Rich functionality offsets performance costs
- Excellent for automation tasks, adequate for web services

Further Learning
===============

Next Steps with PowerShell
--------------------------

1. **Learn Core PowerShell Syntax**:
   - Variables, arrays, and hash tables
   - Conditional statements and loops
   - Functions and script blocks

2. **Explore Cmdlets and Pipeline**:
   - Get-Help cmdlet for learning
   - Pipeline techniques and filtering
   - Object property access and manipulation

3. **Practice System Administration**:
   - File and folder operations
   - Process and service management
   - Registry and environment variables

4. **Advanced Topics**:
   - PowerShell modules and script organization
   - Remote management with PowerShell remoting
   - Desired State Configuration (DSC)
   - PowerShell classes and advanced functions

Recommended Resources
--------------------

- **Microsoft Learn**: Free PowerShell learning paths
- **PowerShell Gallery**: Repository of PowerShell modules
- **GitHub**: PowerShell open-source project
- **PowerShell.org**: Community resources and forums

PowerShell in DevOps and Automation
-----------------------------------

- **Infrastructure as Code**: Managing cloud resources with PowerShell
- **CI/CD Pipelines**: Build and deployment automation
- **Configuration Management**: System configuration and compliance
- **Monitoring and Reporting**: System health and performance monitoring
- **Cross-Platform Administration**: Managing Windows, Linux, and macOS systems

This implementation demonstrates how PowerShell's object-oriented approach and .NET integration make it powerful for web services and automation tasks, bridging the gap between traditional scripting and modern application development.