WebWords - Deno Implementation
==============================

This directory contains the Deno implementation of the WebWords service using Deno's built-in HTTP server and modern web standards.

Docker Overview
===============

Our Dockerfile uses the official Deno runtime image with minimal configuration:

.. code-block:: dockerfile

   FROM denoland/deno:1.36.4
   
   WORKDIR /app
   COPY main.ts .
   
   EXPOSE 31337
   
   CMD ["run", "--allow-net", "main.ts"]

**Single-Stage Build Benefits:**

1. **Official Deno Image**: Pre-built runtime with TypeScript support
2. **No Build Step**: TypeScript compilation happens at runtime  
3. **Minimal Footprint**: Single main.ts file with URL imports
4. **Permission Security**: Explicit ``--allow-net`` for network access
5. **Web Standards**: Native fetch() and Request/Response APIs

The Deno approach eliminates traditional Node.js complexity - no package.json, no node_modules, no build tools required.

Understanding the Code
======================

This Deno implementation demonstrates modern web standards and TypeScript-first development with security by default.

Main Application (main.ts)
--------------------------

**URL Import and Standard Library:**

.. code-block:: typescript

   import { serve } from "https://deno.land/std@0.200.0/http/server.ts";

URL-based imports:
- ``https://deno.land/std@0.200.0/``: Deno's official standard library
- ``http/server.ts``: Built-in HTTP server module
- No package.json or node_modules - dependencies resolved at runtime
- Versioned imports ensure reproducible builds

**HTTP Client Function:**

.. code-block:: typescript

   async function fetchUrl(url: string): Promise<string | null> {
     try {
       const response = await fetch(url, { 
         signal: AbortSignal.timeout(10000)
       });
       return await response.text();
     } catch (error) {
       console.log(`Error fetching ${url}: ${error.message}`);
       return null;
     }
   }

Modern async HTTP client:
1. ``async function``: Native async/await support
2. ``Promise<string | null>``: TypeScript return type annotation
3. ``fetch(url, { ... })``: Web standard fetch API (same as browsers)
4. ``AbortSignal.timeout(10000)``: Built-in timeout mechanism (10 seconds)
5. ``response.text()``: Stream-based response body reading
6. Error handling returns null for failed requests

**Request Handler Function:**

.. code-block:: typescript

   async function handler(request: Request): Promise<Response> {
     const url = new URL(request.url);
     const keyword = url.searchParams.get("keyword") || "";
     const target = url.searchParams.get("target") || "";

Request processing:
1. ``handler(request: Request)``: Web standard Request object
2. ``new URL(request.url)``: Built-in URL parser
3. ``url.searchParams.get("keyword")``: Standard URLSearchParams API
4. ``|| ""``: Default empty string for missing parameters

**URL Fetching and Keyword Search:**

.. code-block:: typescript

   let found = "false";
   
   if (keyword && target) {
     const body = await fetchUrl(target);
     if (body && body.includes(keyword)) {
       found = "true";
     }
     
     console.log(`found=${found}, keyword=${keyword}, uri=${target}`);
   }

Logic flow:
1. ``let found = "false"``: Mutable variable for result
2. ``if (keyword && target)``: Validate both parameters exist
3. ``await fetchUrl(target)``: Async URL content fetching
4. ``body.includes(keyword)``: Case-sensitive string search
5. Template literal logging with parameter values

**Response Generation:**

.. code-block:: typescript

   return new Response(found, {
     status: 200,
     headers: { "content-type": "text/plain" }
   });

Web standard Response:
1. ``new Response(found, { ... })``: Standard Response constructor
2. ``status: 200``: HTTP success status
3. ``"content-type": "text/plain"``: Plain text response type
4. Returns "true" or "false" based on keyword search

**HTTP Server Startup:**

.. code-block:: typescript

   console.log("listening on 0.0.0.0:31337");
   await serve(handler, { port: 31337, hostname: "0.0.0.0" });

Server configuration:
1. ``await serve(handler, { ... })``: Async server startup
2. ``port: 31337``: WebWords standard port
3. ``hostname: "0.0.0.0"``: Listen on all interfaces (Docker requirement)
4. Top-level await (Deno supports this natively)

Building and Running
====================

Step 1: Build the Docker image
------------------------------

.. code-block:: bash

   cd /home/fox/git/webwords/deno
   docker build -t webwords-deno .

Deno downloads dependencies and caches them during first run.

Step 2: Run the container
-------------------------

.. code-block:: bash

   docker run -d -p 31337:31337 --name test-deno webwords-deno

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

   docker logs test-deno

Expected output:
- "listening on 0.0.0.0:31337" on startup
- "found=true, keyword=potato, uri=https://www.remarkbox.com" for requests

Step 5: Clean up
----------------

.. code-block:: bash

   docker stop test-deno
   docker rm test-deno

Common Issues
=============

Permission errors
----------------

If Deno fails to start with permission errors:

.. code-block:: bash

   # Check Deno version and permissions
   docker run -it denoland/deno:1.36.4 --version
   
   # Verify network permission in command
   CMD ["run", "--allow-net", "main.ts"]

Deno security model requires explicit permissions:
- ``--allow-net``: Required for HTTP server and fetch operations
- ``--allow-read``: Would be needed for file system access
- ``--allow-env``: Would be needed for environment variables

Import resolution errors
-----------------------

If URL imports fail during startup:

.. code-block:: bash

   # Check network connectivity from container
   docker run -it denoland/deno:1.36.4 deno info https://deno.land/std@0.200.0/http/server.ts

Common import issues:
- Network connectivity problems (firewall, proxy)
- Version mismatches in URL imports
- Deno cache corruption (rare)

TypeScript compilation errors
---------------------------

If TypeScript compilation fails:

.. code-block:: bash

   # Check TypeScript syntax locally
   docker run -v $(pwd):/app -it denoland/deno:1.36.4 deno check /app/main.ts

Deno TypeScript is strict by default:
- All types must be properly annotated
- Implicit any types are not allowed
- Modern ES modules syntax required

Fetch timeout issues
-------------------

If external URL fetching times out:

.. code-block:: bash

   # Test fetch timeout behavior
   docker logs test-deno | grep "Error fetching"

AbortSignal timeout handling:
- 10-second timeout configured in fetchUrl function
- Adjust timeout for slower target websites
- Error handling returns null for timeouts

Runtime compatibility
--------------------

Deno runtime differences from Node.js:
- No CommonJS (require/module.exports) - only ES modules
- Different global objects (no `process`, `Buffer`, etc.)
- Built-in TypeScript support
- Web-standard APIs instead of Node.js APIs

Implementation Notes
===================

This Deno implementation demonstrates:
- **Modern JavaScript**: Latest ES2020+ features and web standards
- **TypeScript First**: Native TypeScript support without configuration
- **Security Model**: Permission-based security with explicit network access
- **Web Standards**: Fetch API, URL API, Request/Response objects
- **Minimal Dependencies**: Single URL import from Deno standard library
- **Runtime Compilation**: TypeScript compilation happens at runtime

The implementation showcases Deno's philosophy of security by default, web standards compatibility, and simplified dependency management. Unlike Node.js applications that require package.json, node_modules, and build tools, this Deno application is a single TypeScript file with URL-based imports, demonstrating the runtime's focus on simplicity and modern web development practices.

- **Permissions**: Explicit ``--allow-net`` vs Node's all-or-nothing access
- **Modules**: ``import { serve } from "https://deno.land/..."`` vs ``require("express")``
- **TypeScript**: Built-in vs requiring external tools (tsc, ts-node)
- **Standards**: Web APIs (fetch, URL) vs Node-specific APIs (http, url)
- **Security**: Sandboxed by default vs full system access

**Core Deno Features:**

- **URL Imports**: ``import { serve } from "https://deno.land/std@0.200.0/http/server.ts"``
- **Permission Flags**: ``--allow-net``, ``--allow-read``, ``--allow-write``, ``--allow-env``
- **Standard Library**: https://deno.land/std/ provides common functionality
- **Type Checking**: Built-in TypeScript compiler and type checker
- **Web APIs**: Fetch, URL, TextEncoder, crypto, and other web standards

HTTP Server Architecture
------------------------

**Deno HTTP Server Stack:**

.. code-block:: text

   ┌─────────────────┐
   │  HTTP Client    │ (curl request)
   └─────────┬───────┘
             │
   ┌─────────▼───────┐
   │ Deno HTTP Server│ (serve() from std/http)
   └─────────┬───────┘
             │
   ┌─────────▼───────┐
   │ Request Handler │ (handler function)
   └─────────┬───────┘
             │
   ┌─────────▼───────┐
   │ Web Fetch API   │ (standard fetch for external URLs)
   └─────────────────┘

**Component Responsibilities:**

1. **serve()**: High-performance HTTP server from Deno standard library
2. **handler()**: Async function processing each HTTP request
3. **URL**: Web standard URL parsing for query parameters
4. **fetch()**: Web standard HTTP client for external requests
5. **Response**: Web standard Response object construction
6. **AbortSignal**: Timeout mechanism using web standards

**Why Pure Web Standards:**

Deno uses web platform APIs instead of Node.js-specific alternatives:

- **Fetch API**: Standard web API vs http.request() in Node.js
- **URL Constructor**: Web standard vs Node.js url.parse()
- **Response Object**: Same API as browsers vs Node.js res.writeHead()
- **AbortSignal**: Standard timeout mechanism vs Node.js timers
- **Streaming**: Web Streams API vs Node.js streams

TypeScript Program Structure
----------------------------

**Direct URL Imports:**

.. code-block:: typescript

   import { serve } from "https://deno.land/std@0.200.0/http/server.ts";

**Module System Features:**

- **URL Imports**: No package.json or node_modules required
- **Version Pinning**: ``@0.200.0`` ensures reproducible builds
- **Deno Standard Library**: Well-tested, maintained modules
- **Caching**: Deno caches imported modules locally
- **Type Information**: Automatic TypeScript definitions

**HTTP Client Function:**

.. code-block:: typescript

   async function fetchUrl(url: string): Promise<string | null> {
     try {
       const response = await fetch(url, { 
         signal: AbortSignal.timeout(10000)
       });
       return await response.text();
     } catch (error) {
       console.log(`Error fetching ${url}: ${error.message}`);
       return null;
     }
   }

**TypeScript Features:**

- **Type Annotations**: ``url: string`` and ``Promise<string | null>``
- **Async/Await**: Modern asynchronous programming
- **Union Types**: ``string | null`` represents success or failure
- **Web Standards**: ``fetch()``, ``AbortSignal``, ``Response``
- **Error Handling**: try-catch with proper error typing

**Request Handler Implementation:**

.. code-block:: typescript

   async function handler(request: Request): Promise<Response> {
     const url = new URL(request.url);
     const keyword = url.searchParams.get("keyword") || "";
     const target = url.searchParams.get("target") || "";

**URL Processing Features:**

- **URL Constructor**: Web standard URL parsing
- **URLSearchParams**: Query string parameter extraction
- **Null Coalescing**: ``|| ""`` provides default values
- **Type Safety**: TypeScript ensures string handling

**Business Logic:**

.. code-block:: typescript

   let found = "false";
   
   if (keyword && target) {
     const body = await fetchUrl(target);
     if (body && body.includes(keyword)) {
       found = "true";
     }
     
     console.log(`found=${found}, keyword=${keyword}, uri=${target}`);
   }

**Response Generation:**

.. code-block:: typescript

   return new Response(found, {
     status: 200,
     headers: { "content-type": "text/plain" }
   });

Advanced Deno Features
----------------------

**Permission System:**

.. code-block:: bash

   # Network access only
   deno run --allow-net main.ts
   
   # File system read access
   deno run --allow-read main.ts
   
   # Environment variable access
   deno run --allow-env main.ts
   
   # All permissions (not recommended)
   deno run --allow-all main.ts
   
   # Specific network access
   deno run --allow-net=api.example.com main.ts

**Environment Configuration:**

.. code-block:: typescript

   // Environment variables with fallbacks
   const PORT = parseInt(Deno.env.get("PORT") || "31337");
   const HOST = Deno.env.get("HOST") || "0.0.0.0";
   const TIMEOUT = parseInt(Deno.env.get("TIMEOUT") || "10000");
   
   await serve(handler, { port: PORT, hostname: HOST });

**Error Handling and Logging:**

.. code-block:: typescript

   // Structured error handling
   interface WebWordsError {
     type: "network" | "parsing" | "timeout";
     message: string;
     url?: string;
   }
   
   async function fetchUrlWithRetry(url: string, retries = 3): Promise<string | null> {
     for (let i = 0; i < retries; i++) {
       try {
         const response = await fetch(url, {
           signal: AbortSignal.timeout(10000)
         });
         
         if (!response.ok) {
           throw new Error(`HTTP ${response.status}: ${response.statusText}`);
         }
         
         return await response.text();
       } catch (error) {
         console.error(`Attempt ${i + 1} failed for ${url}:`, error.message);
         if (i === retries - 1) return null;
         await new Promise(resolve => setTimeout(resolve, 1000 * (i + 1)));
       }
     }
     return null;
   }

**Type Definitions and Interfaces:**

.. code-block:: typescript

   // Request/Response interfaces
   interface WebWordsRequest {
     keyword: string;
     target: string;
   }
   
   interface WebWordsResponse {
     found: boolean;
     error?: string;
     timestamp: string;
   }
   
   // Enhanced handler with types
   async function typedHandler(request: Request): Promise<Response> {
     const url = new URL(request.url);
     const webWordsRequest: WebWordsRequest = {
       keyword: url.searchParams.get("keyword") || "",
       target: url.searchParams.get("target") || ""
     };
     
     const result: WebWordsResponse = {
       found: false,
       timestamp: new Date().toISOString()
     };
     
     // Process request...
     
     return Response.json(result);
   }

**Middleware and Routing:**

.. code-block:: typescript

   // Simple middleware pattern
   type Middleware = (
     request: Request,
     next: () => Promise<Response>
   ) => Promise<Response>;
   
   const loggingMiddleware: Middleware = async (request, next) => {
     const start = Date.now();
     const response = await next();
     const duration = Date.now() - start;
     console.log(`${request.method} ${request.url} ${response.status} ${duration}ms`);
     return response;
   };
   
   const corsMiddleware: Middleware = async (request, next) => {
     const response = await next();
     response.headers.set("Access-Control-Allow-Origin", "*");
     return response;
   };
   
   // Route handling
   async function router(request: Request): Promise<Response> {
     const url = new URL(request.url);
     
     switch (url.pathname) {
       case "/":
         return handler(request);
       case "/health":
         return new Response("OK", { status: 200 });
       default:
         return new Response("Not Found", { status: 404 });
     }
   }

Build and Test Process
----------------------

**Running the Application:**

.. code-block:: bash

   # Navigate to Deno directory
   cd /home/fox/git/webwords/deno
   
   # Build Docker image
   docker build -t webwords-deno .
   
   # Run container
   docker run -d -p 31337:31337 --name deno-server webwords-deno

**Local Development:**

.. code-block:: bash

   # Run directly with Deno
   deno run --allow-net main.ts
   
   # Run with additional permissions
   deno run --allow-net --allow-env main.ts
   
   # Run with watch mode (auto-restart on changes)
   deno run --allow-net --watch main.ts

**Testing the Service:**

.. code-block:: bash

   # Test positive case (keyword found)
   curl "http://localhost:31337/?keyword=potato&target=https://www.remarkbox.com"
   # Expected output: true
   
   # Test negative case (keyword not found)
   curl "http://localhost:31337/?keyword=lemon&target=https://www.remarkbox.com"
   # Expected output: false

**Development Tools:**

.. code-block:: bash

   # Format code
   deno fmt main.ts
   
   # Lint code
   deno lint main.ts
   
   # Type check without running
   deno check main.ts
   
   # Bundle for distribution
   deno bundle main.ts webwords.js
   
   # Compile to executable
   deno compile --allow-net --output webwords main.ts

**Testing Framework:**

.. code-block:: typescript

   // test.ts
   import { assertEquals } from "https://deno.land/std@0.200.0/testing/asserts.ts";
   
   Deno.test("fetchUrl returns content for valid URL", async () => {
     const content = await fetchUrl("https://httpbin.org/html");
     assertEquals(content !== null, true);
   });
   
   Deno.test("handler returns false for missing keyword", async () => {
     const request = new Request("http://localhost/?keyword=missing&target=https://httpbin.org/html");
     const response = await handler(request);
     const result = await response.text();
     assertEquals(result, "false");
   });

**Running Tests:**

.. code-block:: bash

   # Run tests
   deno test --allow-net test.ts
   
   # Run tests with coverage
   deno test --coverage=coverage --allow-net test.ts
   deno coverage coverage

**Expected Log Output:**
::

   listening on 0.0.0.0:31337
   found=true, keyword=potato, uri=https://www.remarkbox.com
   found=false, keyword=lemon, uri=https://www.remarkbox.com

Troubleshooting Common Issues
-----------------------------

**Permission Errors:**

*Problem*: ``error: Uncaught PermissionDenied: Requires net access``

*Solution*: Add required permission flags
::

   # Add network permission
   deno run --allow-net main.ts
   
   # Add specific network access
   deno run --allow-net=example.com,api.service.com main.ts

*Problem*: ``error: Uncaught PermissionDenied: Requires env access``

*Solution*: Add environment variable permission
::

   # Add environment access
   deno run --allow-net --allow-env main.ts

**Module Import Issues:**

*Problem*: ``error: Module not found`` or network errors during import

*Solution*: Check URL and version
::

   # Verify standard library version exists
   curl -I https://deno.land/std@0.200.0/http/server.ts
   
   # Update to latest version
   import { serve } from "https://deno.land/std@0.208.0/http/server.ts";
   
   # Force reload cache
   deno run --reload --allow-net main.ts

*Problem*: ``error: Relative import path "..." not prefixed with / or ./ or ../``

*Solution*: Use proper import syntax
::

   // Incorrect
   import { serve } from "http/server.ts";
   
   // Correct
   import { serve } from "https://deno.land/std@0.200.0/http/server.ts";
   import { serve } from "./local-server.ts";

**Runtime Issues:**

*Problem*: ``TypeError: AbortSignal.timeout is not a function``

*Solution*: Check Deno version or use alternative timeout
::

   # Check Deno version (AbortSignal.timeout requires Deno 1.32+)
   deno --version
   
   # Alternative timeout implementation
   const controller = new AbortController();
   setTimeout(() => controller.abort(), 10000);
   const response = await fetch(url, { signal: controller.signal });

*Problem*: ``error: Uncaught TypeError: Cannot read property 'includes' of null``

*Solution*: Handle null responses properly
::

   // Add null checks
   const body = await fetchUrl(target);
   if (body && body.includes(keyword)) {
     found = "true";
   }

**Docker Issues:**

*Problem*: Container exits immediately

*Solution*: Check Deno command syntax and permissions
::

   # Verify Docker command format
   CMD ["run", "--allow-net", "main.ts"]
   
   # Test locally first
   deno run --allow-net main.ts
   
   # Check container logs
   docker logs deno-server

**Performance Issues:**

*Problem*: Slow startup or high memory usage

*Solution*: Optimize imports and caching
::

   # Cache dependencies ahead of time
   deno cache main.ts
   
   # Use specific imports instead of entire modules
   import { serve } from "https://deno.land/std@0.200.0/http/server.ts";
   // Instead of importing entire std library
   
   # Bundle for faster startup
   deno bundle main.ts bundle.js

Deno Ecosystem and Tooling
---------------------------

**Standard Library Modules:**

.. code-block:: typescript

   // HTTP utilities
   import { serve } from "https://deno.land/std@0.200.0/http/server.ts";
   import { Status } from "https://deno.land/std@0.200.0/http/http_status.ts";
   
   // File system
   import { readTextFile, writeTextFile } from "https://deno.land/std@0.200.0/fs/mod.ts";
   
   // Path utilities
   import { join, resolve } from "https://deno.land/std@0.200.0/path/mod.ts";
   
   // Testing
   import { assertEquals, assertThrows } from "https://deno.land/std@0.200.0/testing/asserts.ts";
   
   // Crypto
   import { crypto } from "https://deno.land/std@0.200.0/crypto/mod.ts";

**Third-Party Modules:**

.. code-block:: typescript

   // Popular frameworks
   import { Application } from "https://deno.land/x/oak@v12.6.1/mod.ts";  // Oak web framework
   import { serve } from "https://deno.land/x/sift@0.6.0/mod.ts";         // Sift web framework
   
   // Database drivers
   import { Client } from "https://deno.land/x/postgres@v0.17.0/mod.ts";  // PostgreSQL
   import { MongoClient } from "https://deno.land/x/mongo@v0.32.0/mod.ts"; // MongoDB
   
   // Utilities
   import { load } from "https://deno.land/std@0.200.0/dotenv/mod.ts";     // Environment files
   import { parse } from "https://deno.land/std@0.200.0/flags/mod.ts";     // CLI argument parsing

**Configuration and Deployment:**

.. code-block:: typescript

   // deno.json configuration file
   {
     "tasks": {
       "start": "deno run --allow-net main.ts",
       "dev": "deno run --allow-net --watch main.ts",
       "test": "deno test --allow-net",
       "bundle": "deno bundle main.ts dist/bundle.js"
     },
     "importMap": "import_map.json",
     "compilerOptions": {
       "strict": true,
       "lib": ["dom", "esnext"]
     }
   }
   
   // import_map.json for URL aliases
   {
     "imports": {
       "std/": "https://deno.land/std@0.200.0/",
       "oak": "https://deno.land/x/oak@v12.6.1/mod.ts"
     }
   }

Real-World Deno Applications
----------------------------

**Web APIs and Microservices:**

- **REST APIs**: Fast, lightweight HTTP APIs
- **GraphQL**: Type-safe GraphQL servers with schema-first development
- **WebSocket Services**: Real-time communication servers
- **Serverless Functions**: Edge computing with Deno Deploy

**Development Tools:**

- **CLI Applications**: Command-line tools with built-in argument parsing
- **Build Tools**: Custom bundlers and code generators
- **Testing Utilities**: Test runners and assertion libraries
- **Documentation**: Static site generators and documentation tools

**Cloud and Edge Computing:**

- **Deno Deploy**: Global edge runtime for instant deployment
- **AWS Lambda**: Serverless functions with minimal cold start
- **Cloudflare Workers**: Edge computing with V8 isolation
- **Docker Containers**: Lightweight containers with security isolation

**Enterprise Applications:**

- **Internal Tools**: Admin dashboards and data processing
- **API Gateways**: Request routing and authentication
- **Monitoring Services**: Log aggregation and metrics collection
- **Data Pipelines**: ETL processes and batch processing

Further Learning Resources
--------------------------

**Official Deno Resources:**

- Deno Website: https://deno.land/
- Deno Manual: https://deno.land/manual/
- Standard Library: https://deno.land/std/
- Third-Party Modules: https://deno.land/x/

**TypeScript Resources:**

- TypeScript Handbook: https://www.typescriptlang.org/docs/
- TypeScript in Deno: https://deno.land/manual/typescript/
- Advanced Types: https://www.typescriptlang.org/docs/handbook/2/types-from-types.html

**Web Standards Documentation:**

- Fetch API: https://developer.mozilla.org/en-US/docs/Web/API/Fetch_API
- URL API: https://developer.mozilla.org/en-US/docs/Web/API/URL
- AbortSignal: https://developer.mozilla.org/en-US/docs/Web/API/AbortSignal
- Web Streams: https://developer.mozilla.org/en-US/docs/Web/API/Streams_API

**Community and Tools:**

- Deno Discord: https://discord.gg/deno
- Reddit r/Deno: https://www.reddit.com/r/Deno/
- GitHub Deno Organization: https://github.com/denoland
- Awesome Deno: https://github.com/denolib/awesome-deno

**Deployment Platforms:**

- Deno Deploy: https://deno.com/deploy
- Docker Hub Deno: https://hub.docker.com/r/denoland/deno
- Heroku Buildpack: https://github.com/chibat/heroku-buildpack-deno
- Railway: https://railway.app/ (with Deno support)

**Books and Courses:**

- "Deno Web Development" by Alexandre Portela dos Santos
- "Modern Web Development with Deno" (upcoming publications)
- Deno courses on educational platforms
- Official Deno blog: https://deno.com/blog

**Advanced Topics:**

- WebAssembly: https://deno.land/manual/runtime/webassembly
- Worker Threads: https://deno.land/manual/runtime/workers
- FFI (Foreign Function Interface): https://deno.land/manual/runtime/ffi_api
- Custom Extensions: https://deno.land/manual/references/contributing/building_from_source

This Deno implementation showcases how modern JavaScript runtimes can provide excellent security, developer experience, and performance while embracing web standards and eliminating traditional Node.js complexity around package management and configuration.