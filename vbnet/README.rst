WebWords - VB.NET Implementation
================================

This directory contains the VB.NET implementation of the WebWords service using ASP.NET Core with traditional VB.NET syntax and patterns.

Docker Overview
===============

Our Dockerfile uses the standard .NET multi-stage build pattern, identical to C# and F#:

.. code-block:: dockerfile

   FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
   WORKDIR /app
   EXPOSE 31337
   
   FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
   WORKDIR /src
   COPY ["WebWords.vbproj", "."]
   RUN dotnet restore "WebWords.vbproj"
   COPY . .
   WORKDIR "/src"
   RUN dotnet build "WebWords.vbproj" -c Release -o /app/build
   
   FROM build AS publish
   RUN dotnet publish "WebWords.vbproj" -c Release -o /app/publish
   
   FROM base AS final
   WORKDIR /app
   COPY --from=publish /app/publish .
   ENTRYPOINT ["dotnet", "WebWords.dll"]

**Multi-Stage Build Breakdown:**

1. **Base Stage**: Runtime-only ASP.NET Core 6.0 environment
2. **Build Stage**: Full .NET SDK for compiling VB.NET source code
3. **Publish Stage**: Creates deployable application files
4. **Final Stage**: Minimal runtime with only the compiled application

The VB.NET compiler produces the same .NET IL bytecode as C# and F#, so the runtime environment is identical across all .NET languages.

Understanding the Code
======================

This VB.NET implementation demonstrates traditional VB.NET syntax with modern ASP.NET Core patterns, showcasing the language's verbose but readable approach to web development.

Project Configuration (WebWords.vbproj)
---------------------------------------

.. code-block:: xml

   <Project Sdk="Microsoft.NET.Sdk.Web">
     <PropertyGroup>
       <OutputType>Exe</OutputType>
       <TargetFramework>net6.0</TargetFramework>
     </PropertyGroup>
   </Project>

- ``Sdk="Microsoft.NET.Sdk.Web"``: Web application SDK (same as C# and F#)
- ``OutputType>Exe``: Produces executable console application
- ``TargetFramework>net6.0``: Targets .NET 6.0 runtime
- No explicit VB.NET language specification needed - inferred from .vb files

Main Application (Program.vb)
-----------------------------

**Namespace and Imports:**

.. code-block:: vbnet

   Imports System
   Imports System.Net.Http
   Imports System.Threading.Tasks
   Imports Microsoft.AspNetCore.Builder
   Imports Microsoft.AspNetCore.Hosting
   Imports Microsoft.AspNetCore.Http
   Imports Microsoft.Extensions.Hosting
   Imports Microsoft.Extensions.DependencyInjection

VB.NET import statements:
- ``Imports`` keyword equivalent to C# ``using`` statements
- Imports necessary ASP.NET Core and HTTP client namespaces
- VB.NET requires explicit System imports for basic functionality

**Program Class and Entry Point:**

.. code-block:: vbnet

   Namespace WebWords
       Public Class Program
           Public Shared Sub Main(args As String())
               CreateHostBuilder(args).Build().Run()
           End Sub

VB.NET class structure:
1. ``Namespace WebWords``: Explicit namespace declaration (required in VB.NET)
2. ``Public Class Program``: Main application class
3. ``Public Shared Sub Main``: Static main method (``Sub`` for void return)
4. ``args As String()``: Parameter with explicit type annotation
5. ``End Sub``: Explicit method termination (VB.NET verbosity)

**Host Builder Configuration:**

.. code-block:: vbnet

   Public Shared Function CreateHostBuilder(args As String()) As IHostBuilder
       Return Host.CreateDefaultBuilder(args) _
           .ConfigureWebHostDefaults(Sub(webBuilder)
               webBuilder.UseStartup(Of Startup)()
               webBuilder.UseUrls("http://0.0.0.0:31337")
           End Sub)
   End Function

VB.NET host builder:
1. ``Function ... As IHostBuilder``: Function with explicit return type
2. ``Return ... _``: Line continuation character for multi-line statements
3. ``Sub(webBuilder)``: Lambda expression syntax (anonymous subroutine)
4. ``UseStartup(Of Startup)()``: Generic method call with type parameter
5. ``End Sub`` and ``End Function``: Explicit block terminators

**Startup Class Configuration:**

.. code-block:: vbnet

   Public Class Startup
       Public Sub ConfigureServices(services As IServiceCollection)
           services.AddHttpClient()
       End Sub

Startup class structure:
1. ``Public Class Startup``: Configuration class for ASP.NET Core
2. ``Sub ConfigureServices``: Dependency injection configuration
3. ``services.AddHttpClient()``: Registers HTTP client factory
4. Same pattern as C# but with VB.NET syntax

**Application Pipeline Configuration:**

.. code-block:: vbnet

   Public Sub Configure(app As IApplicationBuilder, env As IWebHostEnvironment)
       If env.IsDevelopment() Then
           app.UseDeveloperExceptionPage()
       End If

       app.UseRouting()

       app.UseEndpoints(Sub(endpoints)
           endpoints.MapGet("/", AddressOf HandleRequest)
       End Sub)

       Console.WriteLine("listening on 0.0.0.0:31337")
   End Sub

Pipeline configuration:
1. ``If ... Then ... End If``: VB.NET conditional blocks
2. ``app.UseRouting()``: Enables routing middleware
3. ``AddressOf HandleRequest``: Method reference (VB.NET delegate syntax)
4. ``Console.WriteLine``: Debug output to container logs

**HTTP Request Handler:**

.. code-block:: vbnet

   Private Async Function HandleRequest(context As HttpContext) As Task
       Dim keyword As String = context.Request.Query("keyword").ToString()
       Dim target As String = context.Request.Query("target").ToString()

Request handler method:
1. ``Private Async Function``: Asynchronous method returning Task
2. ``Dim ... As String``: Variable declaration with explicit typing
3. ``context.Request.Query("keyword")``: Query parameter access
4. ``.ToString()``: Explicit string conversion

**HTTP Client and Dependency Injection:**

.. code-block:: vbnet

   Dim httpClientFactory = context.RequestServices.GetRequiredService(Of IHttpClientFactory)()
   Dim httpClient = httpClientFactory.CreateClient()

   Dim found As String = "false"

Dependency injection:
1. ``GetRequiredService(Of IHttpClientFactory)()``: Generic service resolution
2. ``httpClientFactory.CreateClient()``: HTTP client instance creation
3. ``Dim found As String = "false"``: Default response value

**Asynchronous URL Fetching:**

.. code-block:: vbnet

   If Not String.IsNullOrEmpty(keyword) AndAlso Not String.IsNullOrEmpty(target) Then
       Try
           Dim response As String = Await httpClient.GetStringAsync(target)
           If response.Contains(keyword) Then
               found = "true"
           End If

           Console.WriteLine($"found={found}, keyword={keyword}, uri={target}")
       Catch ex As Exception
           Console.WriteLine($"Error: {ex.Message}")
       End Try
   End If

Async operation and error handling:
1. ``If Not ... AndAlso Not ...``: Compound conditional with null checks
2. ``Try ... Catch ... End Try``: Exception handling block
3. ``Await httpClient.GetStringAsync(target)``: Async HTTP GET request
4. ``response.Contains(keyword)``: String search operation
5. ``ex As Exception``: Typed exception parameter
6. String interpolation with ``$"..."`` syntax (modern VB.NET feature)

**Response Writing:**

.. code-block:: vbnet

   Await context.Response.WriteAsync(found)

Final response:
- ``Await context.Response.WriteAsync(found)``: Async response writing
- Returns "true" or "false" based on keyword search result

Building and Running
====================

Step 1: Build the Docker image
------------------------------

.. code-block:: bash

   cd /home/fox/git/webwords/vbnet
   docker build -t webwords-vbnet .

VB.NET compilation occurs during the build stage using the .NET SDK.

Step 2: Run the container
-------------------------

.. code-block:: bash

   docker run -d -p 31337:31337 --name test-vbnet webwords-vbnet

Step 3: Test the service
------------------------

.. code-block:: bash

   # Test positive case (should return "true")
   curl "http://localhost:31337/?keyword=potato&target=https://www.remarkbox.com"

   # Test negative case (should return "false")
   curl "http://localhost:31337/?keyword=lemon&target=https://www.remarkbox.com"

Step 4: View logs
-----------------

.. code-block:: bash

   docker logs test-vbnet

Expected output:
- "listening on 0.0.0.0:31337" on startup
- "found=true, keyword=potato, uri=https://www.remarkbox.com" for requests

Step 5: Clean up
----------------

.. code-block:: bash

   docker stop test-vbnet
   docker rm test-vbnet

Common Issues
=============

VB.NET compilation errors
------------------------

If VB.NET compilation fails during Docker build:

.. code-block:: bash

   # Check VB.NET compiler version
   docker run -it mcr.microsoft.com/dotnet/sdk:6.0 bash
   dotnet --version
   vbc --help

Common VB.NET build issues:
- Missing ``End Sub``, ``End Function``, or ``End If`` statements
- Incorrect line continuation with ``_`` character
- Case sensitivity issues (VB.NET is case-insensitive but .NET APIs are case-sensitive)

Syntax errors
-------------

VB.NET syntax differences from C#:
- Use ``Sub`` for void methods, ``Function`` for returning methods
- Explicit ``End`` statements for all blocks
- ``Dim`` for variable declarations
- ``AddressOf`` for method references
- ``AndAlso`` / ``OrElse`` for short-circuit boolean logic

Async/Await issues
-----------------

VB.NET async patterns:
- Use ``Async Function`` for async methods returning values
- Use ``Async Sub`` only for event handlers (not recommended for WebWords)
- ``Await`` keyword usage is identical to C#
- Task and Task(Of T) types work the same as C#

String interpolation
-------------------

VB.NET string features:
- Modern string interpolation: ``$"Value: {variable}"``
- Traditional concatenation: ``"Value: " & variable``
- Ensure proper escaping in interpolated strings

Runtime compatibility
---------------------

VB.NET runtime is identical to C# and F#:
- Same .NET runtime and ASP.NET Core
- Same dependency injection and HTTP client patterns
- Same performance characteristics
- Identical IL bytecode output

Implementation Notes
===================

This VB.NET implementation demonstrates:
- **Traditional Syntax**: VB.NET's verbose but readable syntax patterns
- **Modern .NET**: Integration with ASP.NET Core and modern .NET patterns
- **Async Programming**: VB.NET's async/await syntax for non-blocking operations
- **Dependency Injection**: Same IoC container patterns as other .NET languages
- **Type Safety**: Strong typing with explicit type annotations
- **Cross-Language Compatibility**: Identical runtime behavior to C# and F#

The implementation showcases VB.NET's evolution from classic VB to a modern .NET language, maintaining its characteristic readability while embracing contemporary web development patterns. The verbose syntax makes the code highly readable for developers from business application backgrounds, while the underlying .NET infrastructure provides enterprise-grade performance and scalability.

**Why VB.NET for WebWords:**

VB.NET excels at:

- **Readability**: Natural language-like syntax makes code self-documenting
- **RAD (Rapid Application Development)**: Quick development cycles and prototyping
- **Enterprise Applications**: Strong tooling and IDE support for business applications
- **ASP.NET Integration**: First-class web development support
- **Legacy Integration**: Smooth migration path from classic VB applications

**VB.NET vs Other .NET Languages:**

- **Syntax Style**: ``If condition Then`` vs ``if (condition) {`` in C#
- **Case Sensitivity**: ``Console.WriteLine`` and ``console.writeline`` are equivalent
- **Keywords**: ``Public Function`` vs ``public`` in C#
- **String Interpolation**: ``$"Hello {name}"`` (similar to C#)
- **Null Handling**: ``If name IsNot Nothing`` vs ``if (name != null)``

**Core VB.NET Concepts:**

- **Modules and Classes**: Code organization with ``Module`` and ``Class`` constructs
- **Procedures**: ``Sub`` (void) and ``Function`` (return value) methods
- **Properties**: ``Property`` declarations with Get/Set accessors
- **Events**: Built-in event handling with ``WithEvents`` and ``Handles``
- **Namespaces**: Code organization similar to other .NET languages

HTTP Server Architecture
------------------------

**ASP.NET Core VB.NET Stack:**

.. code-block:: text

   ┌─────────────────┐
   │  HTTP Client    │ (curl request)
   └─────────┬───────┘
             │
   ┌─────────▼───────┐
   │ ASP.NET Core    │ (Kestrel web server)
   └─────────┬───────┘
             │
   ┌─────────▼───────┐
   │ Startup Class   │ (service configuration)
   └─────────┬───────┘
             │
   ┌─────────▼───────┐
   │ Endpoint Routing│ (URL to handler mapping)
   └─────────┬───────┘
             │
   ┌─────────▼───────┐
   │ Request Handler │ (VB.NET async function)
   └─────────┬───────┘
             │
   ┌─────────▼───────┐
   │ HttpClientFactory│ (managed HTTP client)
   └─────────────────┘

**Component Responsibilities:**

1. **Kestrel Server**: High-performance cross-platform web server
2. **Program Class**: Entry point and host builder configuration
3. **Startup Class**: Service registration and middleware pipeline configuration
4. **Dependency Injection**: Built-in DI container for service management
5. **Endpoint Routing**: Modern routing system mapping URLs to handlers
6. **HttpClientFactory**: Manages HttpClient instances for optimal performance

**Why ASP.NET Core with VB.NET:**

- **Full Feature Parity**: VB.NET has complete access to ASP.NET Core features
- **Performance**: Same runtime performance as C# implementations
- **Tooling**: Excellent Visual Studio support and IntelliSense
- **Migration Path**: Easy upgrade path for existing VB.NET applications
- **Team Skills**: Leverages existing VB.NET developer expertise

VB.NET Program Structure
-----------------------

**Project Configuration (WebWords.vbproj):**

.. code-block:: xml

   <Project Sdk="Microsoft.NET.Sdk.Web">
     <PropertyGroup>
       <OutputType>Exe</OutputType>
       <TargetFramework>net6.0</TargetFramework>
     </PropertyGroup>
   </Project>

**Project System Features:**

- **SDK-Style Format**: Modern project format with minimal configuration
- **Implicit References**: Web SDK automatically includes ASP.NET Core packages
- **Target Framework**: .NET 6.0 for long-term support and performance
- **Output Type**: Executable for standalone web application

**Namespace and Import Declarations:**

.. code-block:: vbnet

   Imports System
   Imports System.Net.Http
   Imports System.Threading.Tasks
   Imports Microsoft.AspNetCore.Builder
   Imports Microsoft.AspNetCore.Hosting
   Imports Microsoft.AspNetCore.Http
   Imports Microsoft.Extensions.Hosting
   Imports Microsoft.Extensions.DependencyInjection

**Import Features:**

- **System Namespaces**: Core .NET functionality
- **HTTP Libraries**: Client and server HTTP functionality
- **ASP.NET Core**: Web hosting and application builder
- **Dependency Injection**: Service container and configuration

**Main Entry Point:**

.. code-block:: vbnet

   Namespace WebWords
       Public Class Program
           Public Shared Sub Main(args As String())
               CreateHostBuilder(args).Build().Run()
           End Sub

           Public Shared Function CreateHostBuilder(args As String()) As IHostBuilder
               Return Host.CreateDefaultBuilder(args) _
                   .ConfigureWebHostDefaults(Sub(webBuilder)
                       webBuilder.UseStartup(Of Startup)()
                       webBuilder.UseUrls("http://0.0.0.0:31337")
                   End Sub)
           End Function
       End Class
   End Namespace

**Language Features:**

- **Namespace Declaration**: Organizes code into logical groups
- **Shared Methods**: ``Shared`` keyword equivalent to ``static`` in C#
- **Line Continuation**: ``_`` character for breaking long statements
- **Lambda Expressions**: ``Sub()`` for inline delegate definitions
- **Generic Types**: ``Of Startup`` syntax for generic type parameters

Startup Configuration and Dependency Injection
-----------------------------------------------

**Startup Class Implementation:**

.. code-block:: vbnet

   Public Class Startup
       Public Sub ConfigureServices(services As IServiceCollection)
           services.AddHttpClient()
       End Sub

       Public Sub Configure(app As IApplicationBuilder, env As IWebHostEnvironment)
           If env.IsDevelopment() Then
               app.UseDeveloperExceptionPage()
           End If

           app.UseRouting()

           app.UseEndpoints(Sub(endpoints)
               endpoints.MapGet("/", AddressOf HandleRequest)
           End Sub)

           Console.WriteLine("listening on 0.0.0.0:31337")
       End Sub
   End Class

**Configuration Features:**

- **Service Registration**: ``AddHttpClient()`` configures HttpClientFactory
- **Environment Detection**: Different behavior for development vs production
- **Middleware Pipeline**: Sequential request processing with UseRouting/UseEndpoints
- **Method References**: ``AddressOf`` keyword for method pointer delegation
- **Lambda Syntax**: ``Sub()`` for inline delegate definitions

Async Programming and Request Handling
---------------------------------------

**Async Request Handler:**

.. code-block:: vbnet

   Private Async Function HandleRequest(context As HttpContext) As Task
       Dim keyword As String = context.Request.Query("keyword").ToString()
       Dim target As String = context.Request.Query("target").ToString()

       Dim httpClientFactory = context.RequestServices.GetRequiredService(Of IHttpClientFactory)()
       Dim httpClient = httpClientFactory.CreateClient()

       Dim found As String = "false"

       If Not String.IsNullOrEmpty(keyword) AndAlso Not String.IsNullOrEmpty(target) Then
           Try
               Dim response As String = Await httpClient.GetStringAsync(target)
               If response.Contains(keyword) Then
                   found = "true"
               End If

               Console.WriteLine($"found={found}, keyword={keyword}, uri={target}")
           Catch ex As Exception
               Console.WriteLine($"Error: {ex.Message}")
           End Try
       End If

       Await context.Response.WriteAsync(found)
   End Function

**VB.NET Language Features:**

- **Async/Await**: ``Async Function`` and ``Await`` for asynchronous programming
- **Variable Declaration**: ``Dim`` keyword for local variable declaration
- **Type Inference**: Automatic type detection with ``As String``
- **Logical Operators**: ``AndAlso`` for short-circuit AND evaluation
- **Exception Handling**: ``Try-Catch`` blocks for error management
- **String Interpolation**: ``$"text {variable}"`` for formatted strings

**Query Parameter Handling:**

.. code-block:: vbnet

   ' Basic parameter extraction
   Dim keyword As String = context.Request.Query("keyword").ToString()
   
   ' Safe parameter extraction with null checking
   Dim keyword As String = If(context.Request.Query.ContainsKey("keyword"),
                             context.Request.Query("keyword").ToString(),
                             String.Empty)
   
   ' Using TryGetValue for safer access
   Dim keywordValues As Microsoft.Extensions.Primitives.StringValues
   If context.Request.Query.TryGetValue("keyword", keywordValues) Then
       keyword = keywordValues.ToString()
   End If

Advanced VB.NET Features
------------------------

**Object-Oriented Programming:**

.. code-block:: vbnet

   Public Class WebWordsService
       Private ReadOnly _httpClientFactory As IHttpClientFactory
       
       Public Sub New(httpClientFactory As IHttpClientFactory)
           _httpClientFactory = httpClientFactory
       End Sub
       
       Public Async Function SearchKeywordAsync(keyword As String, target As String) As Task(Of Boolean)
           Using httpClient = _httpClientFactory.CreateClient()
               Try
                   Dim response As String = Await httpClient.GetStringAsync(target)
                   Return response.Contains(keyword)
               Catch
                   Return False
               End Try
           End Using
       End Function
   End Class

**Properties and Auto-Implementation:**

.. code-block:: vbnet

   Public Class SearchResult
       ' Auto-implemented properties
       Public Property Keyword As String
       Public Property Target As String
       Public Property Found As Boolean
       Public Property Timestamp As DateTime = DateTime.UtcNow
       
       ' Custom property with backing field
       Private _status As String
       Public Property Status As String
           Get
               Return _status
           End Get
           Set(value As String)
               _status = value.ToUpperInvariant()
           End Set
       End Property
   End Class

**Collection Operations and LINQ:**

.. code-block:: vbnet

   ' LINQ queries in VB.NET
   Dim results = From request In requests
                 Where Not String.IsNullOrEmpty(request.Keyword)
                 Select New With {
                     .Keyword = request.Keyword,
                     .Found = SearchKeyword(request.Keyword, request.Target)
                 }
   
   ' Lambda expressions
   Dim filteredRequests = requests.Where(Function(r) r.Keyword.Length > 3).ToList()
   
   ' Method chaining
   Dim processedResults = requests _
       .Where(Function(r) Not String.IsNullOrEmpty(r.Target)) _
       .Select(Function(r) ProcessRequest(r)) _
       .ToList()

**Event Handling:**

.. code-block:: vbnet

   Public Class WebWordsLogger
       Public Event RequestProcessed As EventHandler(Of RequestEventArgs)
       
       Public Sub LogRequest(keyword As String, target As String, found As Boolean)
           Dim args As New RequestEventArgs With {
               .Keyword = keyword,
               .Target = target,
               .Found = found,
               .Timestamp = DateTime.UtcNow
           }
           
           RaiseEvent RequestProcessed(Me, args)
       End Sub
   End Class
   
   Public Class RequestEventArgs
       Inherits EventArgs
       Public Property Keyword As String
       Public Property Target As String
       Public Property Found As Boolean
       Public Property Timestamp As DateTime
   End Class

**Error Handling Patterns:**

.. code-block:: vbnet

   ' Try-Catch with specific exception types
   Try
       Dim response = Await httpClient.GetStringAsync(target)
       Return ProcessResponse(response)
   Catch ex As HttpRequestException
       Console.WriteLine($"HTTP error: {ex.Message}")
       Return "error"
   Catch ex As TaskCanceledException
       Console.WriteLine("Request timeout")
       Return "timeout"
   Catch ex As Exception
       Console.WriteLine($"Unexpected error: {ex.Message}")
       Return "error"
   End Try

**Nullable Reference Types:**

.. code-block:: vbnet

   ' Enable nullable reference types in project file
   ' <Nullable>enable</Nullable>
   
   Public Function SafeGetParameter(context As HttpContext, key As String) As String?
       If context.Request.Query.ContainsKey(key) Then
           Return context.Request.Query(key).ToString()
       End If
       Return Nothing
   End Function
   
   Public Sub ProcessRequest(keyword As String?, target As String?)
       If keyword IsNot Nothing AndAlso target IsNot Nothing Then
           ' Safe to use keyword and target
           Console.WriteLine($"Processing: {keyword} in {target}")
       End If
   End Sub

Configuration and Dependency Injection
---------------------------------------

**Service Registration:**

.. code-block:: vbnet

   Public Sub ConfigureServices(services As IServiceCollection)
       ' HTTP client configuration
       services.AddHttpClient("webwords", Sub(client)
           client.Timeout = TimeSpan.FromSeconds(10)
           client.DefaultRequestHeaders.Add("User-Agent", "VB.NET-WebWords/1.0")
       End Sub)
       
       ' Custom service registration
       services.AddScoped(Of IWebWordsService, WebWordsService)()
       services.AddSingleton(Of ILogger, ConsoleLogger)()
       
       ' Configuration
       services.Configure(Of WebWordsOptions)(Configuration.GetSection("WebWords"))
   End Sub

**Configuration Classes:**

.. code-block:: vbnet

   Public Class WebWordsOptions
       Public Property DefaultTimeout As Integer = 10
       Public Property MaxRetries As Integer = 3
       Public Property UserAgent As String = "VB.NET-WebWords"
       Public Property EnableLogging As Boolean = True
   End Class

**Dependency Injection Usage:**

.. code-block:: vbnet

   Public Class EnhancedStartup
       Private ReadOnly _logger As ILogger
       
       Public Sub New(logger As ILogger)
           _logger = logger
       End Sub
       
       Private Async Function HandleRequest(context As HttpContext) As Task
           Dim webWordsService = context.RequestServices.GetRequiredService(Of IWebWordsService)()
           Dim options = context.RequestServices.GetRequiredService(Of IOptions(Of WebWordsOptions))()
           
           ' Use injected services
           Dim result = Await webWordsService.ProcessRequestAsync(context)
           Await context.Response.WriteAsync(result)
       End Function
   End Class

Build and Test Process
----------------------

**Building the Application:**

.. code-block:: bash

   # Navigate to VB.NET directory
   cd /home/fox/git/webwords/vbnet
   
   # Build Docker image
   docker build -t webwords-vbnet .
   
   # Run container
   docker run -d -p 31337:31337 --name vbnet-server webwords-vbnet

**Local Development:**

.. code-block:: bash

   # Restore dependencies
   dotnet restore
   
   # Build project
   dotnet build
   
   # Run application
   dotnet run
   
   # Run with hot reload
   dotnet watch run

**Testing the Service:**

.. code-block:: bash

   # Test positive case (keyword found)
   curl "http://localhost:31337/?keyword=potato&target=https://www.remarkbox.com"
   # Expected output: true
   
   # Test negative case (keyword not found)
   curl "http://localhost:31337/?keyword=lemon&target=https://www.remarkbox.com"
   # Expected output: false

**Visual Studio Development:**

.. code-block:: bash

   # Open project in Visual Studio
   start WebWords.vbproj
   
   # Or use Visual Studio Code with VB.NET extension
   code .

**Unit Testing:**

.. code-block:: vbnet

   ' Add test project
   ' dotnet new xunit -lang VB -n WebWords.Tests
   
   Imports Xunit
   Imports System.Net.Http
   Imports Microsoft.AspNetCore.Http
   
   Public Class WebWordsTests
       <Fact>
       Public Async Sub TestValidRequest()
           ' Arrange
           Dim context = CreateMockContext("potato", "https://httpbin.org/html")
           
           ' Act
           Await HandleRequest(context)
           
           ' Assert
           ' Verify response content
       End Sub
       
       Private Function CreateMockContext(keyword As String, target As String) As HttpContext
           ' Mock implementation
           Return Nothing
       End Function
   End Class

**Expected Log Output:**
::

   info: Microsoft.Hosting.Lifetime[14]
         Now listening on: http://0.0.0.0:31337
   info: Microsoft.Hosting.Lifetime[0]
         Application started. Press Ctrl+C to shut down.
   listening on 0.0.0.0:31337
   found=true, keyword=potato, uri=https://www.remarkbox.com
   found=false, keyword=lemon, uri=https://www.remarkbox.com

Troubleshooting Common Issues
-----------------------------

**Compilation Errors:**

*Problem*: ``BC30002: Type 'HttpContext' is not defined``

*Solution*: Add missing import statements
::

   ' Add required imports at top of file
   Imports Microsoft.AspNetCore.Http
   Imports Microsoft.Extensions.DependencyInjection

*Problem*: ``BC30205: End of statement expected`` 

*Solution*: Check VB.NET syntax requirements
::

   ' Incorrect: Missing Then keyword
   If condition
       ' code
   End If
   
   ' Correct: Include Then keyword
   If condition Then
       ' code
   End If

**Runtime Issues:**

*Problem*: ``System.InvalidOperationException: Unable to resolve service``

*Solution*: Register required services in ConfigureServices
::

   Public Sub ConfigureServices(services As IServiceCollection)
       ' Ensure HttpClient is registered
       services.AddHttpClient()
       
       ' Register custom services
       services.AddScoped(Of IMyService, MyService)()
   End Sub

*Problem*: ``System.ArgumentNullException`` with query parameters

*Solution*: Handle null values properly
::

   ' Check for null/empty query parameters
   Dim keyword As String = String.Empty
   If context.Request.Query.ContainsKey("keyword") Then
       keyword = context.Request.Query("keyword").ToString()
   End If
   
   ' Or use conditional assignment
   Dim keyword As String = If(context.Request.Query.ContainsKey("keyword"),
                             context.Request.Query("keyword").ToString(),
                             String.Empty)

**Docker Build Issues:**

*Problem*: ``error MSB4025: The project file could not be loaded``

*Solution*: Verify project file syntax and SDK
::

   <!-- Ensure correct SDK in .vbproj -->
   <Project Sdk="Microsoft.NET.Sdk.Web">
     <PropertyGroup>
       <TargetFramework>net6.0</TargetFramework>
     </PropertyGroup>
   </Project>

*Problem*: VB.NET compilation errors in Docker

*Solution*: Check .NET SDK version and language support
::

   # Verify VB.NET support in SDK
   FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
   RUN dotnet --info

**VB.NET-Specific Issues:**

*Problem*: ``BC30451: 'await' is not declared``

*Solution*: Use ``Async`` and ``Await`` keywords correctly
::

   ' Correct async function syntax
   Private Async Function ProcessAsync() As Task(Of String)
       Dim result As String = Await SomeAsyncOperation()
       Return result
   End Function

*Problem*: Case sensitivity issues with external libraries

*Solution*: Use exact casing for .NET method calls
::

   ' Correct: Use exact method names
   Dim result = httpClient.GetStringAsync(url)
   
   ' Incorrect: Wrong casing might cause issues
   ' Dim result = httpClient.getstringasync(url)

Performance Optimization
------------------------

**Async Best Practices:**

.. code-block:: vbnet

   ' Use ConfigureAwait(False) for library code
   Public Async Function FetchDataAsync() As Task(Of String)
       Dim response = Await httpClient.GetStringAsync(url).ConfigureAwait(False)
       Return response
   End Function
   
   ' Parallel async operations
   Public Async Function FetchMultipleAsync(urls As String()) As Task(Of String())
       Dim tasks = urls.Select(Function(url) httpClient.GetStringAsync(url)).ToArray()
       Dim results = Await Task.WhenAll(tasks)
       Return results
   End Function

**Memory Management:**

.. code-block:: vbnet

   ' Use Using statements for disposable resources
   Using httpClient = _httpClientFactory.CreateClient()
       Dim response = Await httpClient.GetStringAsync(url)
       Return response
   End Using
   
   ' StringBuilder for string concatenation
   Dim sb As New StringBuilder()
   For Each item In items
       sb.AppendLine(item.ToString())
   Next
   Return sb.ToString()

**HttpClient Configuration:**

.. code-block:: vbnet

   Public Sub ConfigureServices(services As IServiceCollection)
       services.AddHttpClient("optimized", Sub(client)
           client.Timeout = TimeSpan.FromSeconds(30)
           client.DefaultRequestHeaders.ConnectionClose = False
           client.DefaultRequestVersion = New Version(2, 0)
       End Sub)
   End Sub

Real-World VB.NET Applications
------------------------------

**Enterprise Applications:**

- **Business Applications**: Line-of-business applications with rich user interfaces
- **Data Processing**: ETL processes and batch processing systems
- **Reporting Systems**: Crystal Reports and SQL Server Reporting Services
- **Legacy Modernization**: Upgrading classic VB applications to .NET

**Web Development:**

- **Corporate Websites**: Internal portals and public-facing websites
- **Web APIs**: RESTful services for mobile and web applications
- **E-commerce**: Online shopping and inventory management systems
- **Content Management**: Custom CMS solutions

**Integration Solutions:**

- **System Integration**: Connecting different enterprise systems
- **Database Applications**: CRUD applications with SQL Server
- **Windows Services**: Background processing and scheduled tasks
- **Web Services**: SOAP and REST API development

**Government and Education:**

- **Public Sector**: Government applications and citizen services
- **Educational Software**: Learning management systems
- **Healthcare**: Medical record systems and patient management
- **Financial Services**: Banking and insurance applications

Further Learning Resources
--------------------------

**Official Microsoft Resources:**

- VB.NET Documentation: https://docs.microsoft.com/en-us/dotnet/visual-basic/
- .NET Learning Center: https://dotnet.microsoft.com/learn
- ASP.NET Core Documentation: https://docs.microsoft.com/en-us/aspnet/core/
- Visual Studio: https://visualstudio.microsoft.com/

**VB.NET Community:**

- VB.NET Team Blog: https://devblogs.microsoft.com/vbteam/
- Stack Overflow VB.NET Tag: Active community for questions
- CodeProject VB.NET: https://www.codeproject.com/KB/vb-net/
- VB.NET Forums: Various community forums and discussion groups

**Learning Platforms:**

- Microsoft Learn: https://docs.microsoft.com/en-us/learn/
- Pluralsight: VB.NET and ASP.NET Core courses
- Udemy: VB.NET development courses
- YouTube: Free VB.NET tutorials and walkthroughs

**Books and Publications:**

- "Programming Visual Basic .NET" by Dave Grundgeiger
- "Visual Basic .NET: The Complete Reference" by Jeff Kent
- "Beginning VB.NET" by Richard Blair
- "Professional VB.NET" by Bill Evjen

**Development Tools:**

- **Visual Studio**: Full-featured IDE with excellent VB.NET support
- **Visual Studio Code**: Lightweight editor with VB.NET extensions
- **JetBrains Rider**: Cross-platform .NET IDE
- **MonoDevelop**: Open-source .NET development environment

**Advanced Topics:**

- **Interoperability**: Calling C# libraries from VB.NET
- **Code Analysis**: FxCop and Roslyn analyzers for VB.NET
- **Performance**: Profiling and optimization techniques
- **Deployment**: ClickOnce and modern deployment strategies

**Migration Resources:**

- **VB6 to VB.NET**: Migration guides and tools
- **Framework to Core**: Upgrading from .NET Framework
- **Modernization**: Best practices for updating legacy applications
- **Cross-Platform**: Running VB.NET on Linux and macOS

This VB.NET implementation demonstrates how traditional Microsoft development languages can leverage modern .NET Core capabilities while maintaining their characteristic readability and rapid development advantages.