WebWords - F# Implementation
============================

This directory contains the F# implementation of the WebWords service using ASP.NET Core with functional programming patterns and async workflows.

Docker Overview
===============

Our Dockerfile uses the same multi-stage .NET build as C#, optimized for F# compilation:

.. code-block:: dockerfile

   FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
   WORKDIR /app
   EXPOSE 31337
   
   FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
   WORKDIR /src
   COPY ["WebWords.fsproj", "."]
   RUN dotnet restore "WebWords.fsproj"
   COPY . .
   RUN dotnet build "WebWords.fsproj" -c Release -o /app/build
   
   FROM build AS publish
   RUN dotnet publish "WebWords.fsproj" -c Release -o /app/publish
   
   FROM base AS final
   WORKDIR /app
   COPY --from=publish /app/publish .
   ENTRYPOINT ["dotnet", "WebWords.dll"]

**Multi-Stage Build Breakdown:**
- Identical to C# build process, but compiles F# source
- F# compiler produces .NET IL bytecode same as C#
- Runtime environment is identical to other .NET languages
- Multi-stage build optimizes final container size

Understanding the Code
======================

This F# implementation demonstrates functional programming patterns with ASP.NET Core, showcasing immutability, pattern matching, and async workflows.

Project Configuration (WebWords.fsproj)
---------------------------------------

.. code-block:: xml

   <Project Sdk="Microsoft.NET.Sdk.Web">
     <PropertyGroup>
       <OutputType>Exe</OutputType>
       <TargetFramework>net6.0</TargetFramework>
     </PropertyGroup>
     <ItemGroup>
       <Compile Include="Program.fs" />
     </ItemGroup>
   </Project>

- ``Sdk="Microsoft.NET.Sdk.Web"``: Web application SDK (same as C#)
- ``OutputType>Exe``: Produces executable application
- ``Compile Include="Program.fs"``: F# source file compilation order

Main Application (Program.fs)
-----------------------------

**Module Imports:**

.. code-block:: fsharp

   open System
   open System.Net.Http
   open Microsoft.AspNetCore.Builder
   open Microsoft.AspNetCore.Http
   open Microsoft.Extensions.DependencyInjection

F# open statements for importing namespaces:
- Similar to C# using statements but with F# syntax
- Imports necessary ASP.NET Core and HTTP client functionality

**HTTP Client Function:**

.. code-block:: fsharp

   let fetchUrl (httpClient: HttpClient) (url: string) =
       async {
           try
               let! response = httpClient.GetStringAsync(url) |> Async.AwaitTask
               return Some response
           with
           | _ -> return None
       }

Functional HTTP client implementation:
1. ``let fetchUrl``: Function definition with curried parameters
2. ``async { ... }``: F# async workflow (computation expression)
3. ``let! response``: Async binding (equivalent to await in C#)
4. ``|> Async.AwaitTask``: Pipeline operator to convert Task to Async
5. ``Some response`` / ``None``: Option type for null safety
6. Pattern matching with ``with | _ ->`` for exception handling

**Request Handler Function:**

.. code-block:: fsharp

   let handleRequest (context: HttpContext) =
       async {
           let keyword = context.Request.Query.["keyword"].ToString()
           let target = context.Request.Query.["target"].ToString()
           
           let mutable found = "false"

Handler implementation:
1. ``async { ... }``: Async workflow for non-blocking operation
2. ``let keyword = ...``: Immutable value binding
3. ``let mutable found``: Mutable variable (exception in functional style)
4. Direct query parameter access similar to C#

**Pattern Matching and Logic:**

.. code-block:: fsharp

   let! body = fetchUrl httpClient target
   match body with
   | Some content when content.Contains(keyword) ->
       found <- "true"
   | _ -> ()

Functional pattern matching:
1. ``let! body``: Async binding to await fetchUrl result
2. ``match body with``: Pattern matching on Option type
3. ``Some content when ...``: Pattern with guard condition
4. ``found <- "true"``: Mutable assignment (imperative style)
5. ``| _ -> ()``: Catch-all pattern returning unit

**Startup Class (Object-Oriented Style):**

.. code-block:: fsharp

   type Startup() =
       member this.ConfigureServices(services: IServiceCollection) =
           services.AddHttpClient() |> ignore

       member this.Configure(app: IApplicationBuilder, env: IWebHostEnvironment) =
           app.UseRouting() |> ignore
           app.UseEndpoints(fun endpoints ->
               endpoints.MapGet("/", Func<HttpContext, Task>(handleRequest)) |> ignore
           ) |> ignore

Startup configuration:
1. ``type Startup()``: Class definition with empty constructor
2. ``member this.ConfigureServices``: Instance method
3. ``|> ignore``: Pipeline operator to discard return value
4. ``Func<HttpContext, Task>(handleRequest)``: Convert F# function to .NET delegate

**Application Entry Point:**

.. code-block:: fsharp

   [<EntryPoint>]
   let main args =
       Host.CreateDefaultBuilder(args)
           .ConfigureWebHostDefaults(fun webBuilder ->
               webBuilder.UseStartup<Startup>()
                        .UseUrls("http://0.0.0.0:31337") |> ignore
           )
           .Build()
           .Run()
       0

Main function:
1. ``[<EntryPoint>]``: Attribute marking program entry point
2. ``let main args``: Function taking command line arguments
3. Fluent API calls similar to C# but with F# syntax
4. ``return 0``: Exit code (implicit return in F#)

Building and Running
====================

Step 1: Build the Docker image
------------------------------

.. code-block:: bash

   cd /home/fox/git/webwords/fsharp
   docker build -t webwords-fsharp .

Step 2: Run the container
-------------------------

.. code-block:: bash

   docker run -d -p 31337:31337 --name test-fsharp webwords-fsharp

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

   docker logs test-fsharp

Expected output:
- "listening on 0.0.0.0:31337" on startup
- "found=true, keyword=potato, uri=https://www.remarkbox.com" for requests

Step 5: Clean up
----------------

.. code-block:: bash

   docker stop test-fsharp
   docker rm test-fsharp

Common Issues
=============

F# compilation errors
--------------------

If F# compilation fails during Docker build:

.. code-block:: bash

   # Check F# compiler version
   docker run -it mcr.microsoft.com/dotnet/sdk:6.0 bash
   dotnet --version
   dotnet fsi --help

Common F# build issues:
- Indentation errors (F# is whitespace-sensitive)
- Missing open statements for required namespaces
- Incorrect pipeline operator usage

Pattern matching compilation errors
----------------------------------

If you see pattern matching errors:
- Ensure all cases are handled in match expressions
- Use wildcard pattern ``| _ ->`` for catch-all cases
- Check Option type usage: ``Some value`` vs ``None``

Async workflow issues
--------------------

If async operations fail:
- Use ``let!`` for async binding (not ``let``)
- Convert Tasks to Async with ``|> Async.AwaitTask``
- Ensure async workflows return proper types

Type inference issues
--------------------

If F# cannot infer types:
- Add explicit type annotations: ``(parameter: Type)``
- Check pipeline operator usage and type flow
- F# has powerful type inference but sometimes needs hints

Runtime compatibility
---------------------

F# runtime is identical to C#:
- Same .NET runtime and ASP.NET Core
- Same dependency injection and HTTP client patterns
- Same performance characteristics

Implementation Notes
===================

This F# implementation demonstrates:
- **Functional Programming**: Immutable values, pattern matching, and option types
- **Async Workflows**: F#'s computation expressions for asynchronous programming  
- **Interoperability**: Seamless integration with .NET and ASP.NET Core
- **Type Safety**: Strong typing with powerful type inference
- **Pipeline Operators**: F#'s |> operator for data transformation
- **Hybrid Paradigm**: Mixing functional and object-oriented styles

The code showcases F#'s unique position as a functional-first language on .NET, combining functional programming elegance with the robustness of the .NET ecosystem, while demonstrating how functional concepts like pattern matching and option types can improve code safety and expressiveness.