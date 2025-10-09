WebWords - C# Implementation
=============================

This directory contains the C# implementation of the WebWords service using ASP.NET Core with dependency injection and the IHttpClientFactory pattern.

Docker Overview
===============

Our Dockerfile uses a multi-stage build with .NET 6.0 SDK and runtime:

.. code-block:: dockerfile

   FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
   WORKDIR /app
   EXPOSE 31337
   
   FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
   WORKDIR /src
   COPY ["WebWords.csproj", "."]
   RUN dotnet restore "WebWords.csproj"
   COPY . .
   RUN dotnet build "WebWords.csproj" -c Release -o /app/build
   
   FROM build AS publish
   RUN dotnet publish "WebWords.csproj" -c Release -o /app/publish
   
   FROM base AS final
   WORKDIR /app
   COPY --from=publish /app/publish .
   ENTRYPOINT ["dotnet", "WebWords.dll"]

**Multi-Stage Build Breakdown:**

**Stage 1 (Base Runtime):**
- ``FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base``: .NET 6.0 runtime environment
- ``EXPOSE 31337``: Document the application port

**Stage 2 (Build Environment):**
- ``FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build``: Full .NET SDK for compilation
- ``COPY ["WebWords.csproj", "."]``: Copy project file first for dependency caching
- ``RUN dotnet restore``: Download NuGet packages and dependencies
- ``RUN dotnet build -c Release``: Compile in Release configuration

**Stage 3 (Publish):**
- ``FROM build AS publish``: Continue from build stage
- ``RUN dotnet publish -c Release``: Create deployment-ready package

**Stage 4 (Final Runtime):**
- ``COPY --from=publish /app/publish .``: Copy only published artifacts
- ``ENTRYPOINT ["dotnet", "WebWords.dll"]``: Run the compiled application

Understanding the Code
======================

This C# implementation uses ASP.NET Core's minimal hosting model with dependency injection, demonstrating modern .NET web development patterns.

Project Configuration (WebWords.csproj)
---------------------------------------

.. code-block:: xml

   <Project Sdk="Microsoft.NET.Sdk.Web">
     <PropertyGroup>
       <TargetFramework>net6.0</TargetFramework>
       <Nullable>enable</Nullable>
       <ImplicitUsings>enable</ImplicitUsings>
     </PropertyGroup>
   </Project>

- ``Sdk="Microsoft.NET.Sdk.Web"``: Web application project template
- ``TargetFramework>net6.0``: Target .NET 6.0 runtime
- ``Nullable>enable``: Enable nullable reference types for better null safety
- ``ImplicitUsings>enable``: Automatically include common using statements

Main Application (Program.cs)
-----------------------------

**Program Entry Point:**

.. code-block:: csharp

   public static void Main(string[] args)
   {
       CreateHostBuilder(args).Build().Run();
   }

Standard ASP.NET Core entry point that builds and runs the web host.

**Host Builder Configuration:**

.. code-block:: csharp

   public static IHostBuilder CreateHostBuilder(string[] args) =>
       Host.CreateDefaultBuilder(args)
           .ConfigureWebHostDefaults(webBuilder =>
           {
               webBuilder.UseStartup<Startup>();
               webBuilder.UseUrls("http://0.0.0.0:31337");
           });

Host configuration:
1. ``Host.CreateDefaultBuilder(args)``: Creates host with default configuration
2. ``ConfigureWebHostDefaults``: Configure web-specific settings
3. ``UseStartup<Startup>()``: Use Startup class for application configuration
4. ``UseUrls("http://0.0.0.0:31337")``: Bind to all interfaces on port 31337

**Startup Class - Service Configuration:**

.. code-block:: csharp

   public void ConfigureServices(IServiceCollection services)
   {
       services.AddHttpClient();
   }

Service registration:
- ``services.AddHttpClient()``: Register IHttpClientFactory for dependency injection
- IHttpClientFactory provides proper HttpClient lifecycle management
- Prevents socket exhaustion and DNS issues common with HttpClient

**Application Pipeline Configuration:**

.. code-block:: csharp

   public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
   {
       if (env.IsDevelopment())
       {
           app.UseDeveloperExceptionPage();
       }
       
       app.UseRouting();

Pipeline setup:
1. ``UseDeveloperExceptionPage()``: Enhanced error pages in development
2. ``UseRouting()``: Enable endpoint routing middleware

**Request Handler Implementation:**

.. code-block:: csharp

   app.UseEndpoints(endpoints =>
   {
       endpoints.MapGet("/", async context =>
       {
           var keyword = context.Request.Query["keyword"].ToString();
           var target = context.Request.Query["target"].ToString();

Endpoint mapping:
1. ``endpoints.MapGet("/")``: Map GET requests to root path
2. ``context.Request.Query["keyword"]``: Extract query parameters
3. ``async context``: Asynchronous request handler

**HTTP Client Usage:**

.. code-block:: csharp

   var httpClientFactory = context.RequestServices.GetRequiredService<IHttpClientFactory>();
   var httpClient = httpClientFactory.CreateClient();
   
   try
   {
       var response = await httpClient.GetStringAsync(target);
       var found = response.Contains(keyword) ? "true" : "false";

HTTP client pattern:
1. ``GetRequiredService<IHttpClientFactory>()``: Resolve from dependency injection
2. ``httpClientFactory.CreateClient()``: Create properly configured HttpClient
3. ``await httpClient.GetStringAsync(target)``: Async HTTP GET request
4. ``response.Contains(keyword)``: Simple substring search

**Error Handling and Response:**

.. code-block:: csharp

   Console.WriteLine($"found={found}, keyword={keyword}, uri={target}");
   await context.Response.WriteAsync(found);
   }
   catch (Exception ex)
   {
       Console.WriteLine($"Error: {ex.Message}");
       await context.Response.WriteAsync("false");
   }

Response handling:
1. ``Console.WriteLine(...)``: Log request details to stdout
2. ``await context.Response.WriteAsync(found)``: Send response asynchronously
3. ``catch (Exception ex)``: Handle any HTTP or network errors
4. Return "false" for any error condition

Building and Running
====================

Step 1: Build the Docker image
------------------------------

.. code-block:: bash

   cd /home/fox/git/webwords/csharp
   docker build -t webwords-csharp .

Step 2: Run the container
-------------------------

.. code-block:: bash

   docker run -d -p 31337:31337 --name test-csharp webwords-csharp

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

   docker logs test-csharp

Expected output:
- "listening on 0.0.0.0:31337" on startup
- "found=true, keyword=potato, uri=https://www.remarkbox.com" for requests

Step 5: Clean up
----------------

.. code-block:: bash

   docker stop test-csharp
   docker rm test-csharp

Common Issues
=============

.NET build failures
-------------------

If the build fails with .NET compilation errors:

.. code-block:: bash

   # Check .NET version
   docker run -it mcr.microsoft.com/dotnet/sdk:6.0 bash
   dotnet --version

Common .NET build issues:
- Missing package references in WebWords.csproj
- Target framework mismatch
- Syntax errors in C# code

NuGet package restore failures
------------------------------

If package restoration fails:
- Network connectivity issues during docker build
- NuGet package version conflicts
- Missing package sources

HTTP client issues
-----------------

If HTTP requests fail:
- IHttpClientFactory automatically handles connection pooling
- Built-in retry policies and timeout management
- SSL/HTTPS support included by default

Port binding issues
------------------

If the server fails to start on port 31337:
- Check no other containers are using the port
- ASP.NET Core binds to all interfaces when configured with 0.0.0.0
- Kestrel web server handles concurrent requests automatically

Memory and performance
---------------------

If you experience performance issues:
- ASP.NET Core uses async/await throughout for non-blocking I/O
- IHttpClientFactory prevents HttpClient socket exhaustion
- Automatic garbage collection manages memory

Implementation Notes
===================

This C# implementation demonstrates:
- **ASP.NET Core Framework**: Modern, cross-platform web framework
- **Dependency Injection**: Built-in IoC container for service management
- **IHttpClientFactory Pattern**: Proper HttpClient lifecycle management
- **Async/Await**: Non-blocking asynchronous programming throughout
- **Multi-Stage Docker Build**: Optimized container images for production
- **Configuration Management**: Host builder pattern with environment-specific settings

The code showcases modern .NET development practices with proper error handling, dependency injection, and asynchronous programming patterns that scale well for production web services.