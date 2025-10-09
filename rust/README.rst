WebWords - Rust Implementation
==============================

This directory contains the Rust implementation of the WebWords service using the Warp web framework and reqwest HTTP client, demonstrating async/await patterns and memory safety.

Docker Overview
===============

Our Dockerfile uses a multi-stage build with Rust compiler and Debian runtime:

.. code-block:: dockerfile

   FROM rust:1.82 AS builder
   
   WORKDIR /app
   COPY Cargo.toml ./
   COPY src ./src
   RUN cargo build --release
   
   FROM debian:bookworm-slim
   RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*
   COPY --from=builder /app/target/release/webwords /usr/local/bin/webwords
   
   EXPOSE 31337
   CMD ["webwords"]

**Multi-Stage Build Breakdown:**

**Stage 1 (Builder):**
- ``FROM rust:1.82 AS builder``: Use Rust 1.82 compiler with Cargo toolchain
- ``COPY Cargo.toml ./``: Copy dependency manifest first for Docker layer caching
- ``COPY src ./src``: Copy source code directory
- ``RUN cargo build --release``: Compile with optimizations enabled

**Stage 2 (Runtime):**
- ``FROM debian:bookworm-slim``: Use minimal Debian for runtime (~80MB)
- ``apt-get install -y ca-certificates``: Add SSL certificates for HTTPS requests
- ``COPY --from=builder /app/target/release/webwords``: Copy optimized binary
- Final image contains only the compiled executable and minimal runtime

Understanding the Code
======================

This Rust implementation uses modern async/await patterns with the Warp web framework and reqwest HTTP client, emphasizing memory safety and performance.

Dependencies (Cargo.toml)
-------------------------

.. code-block:: toml

   [dependencies]
   tokio = { version = "1", features = ["full"] }
   warp = "0.3"
   reqwest = { version = "0.11", features = ["json"] }
   serde = { version = "1.0", features = ["derive"] }

- ``tokio``: Async runtime for concurrent programming with full feature set
- ``warp``: Composable web framework built on hyper HTTP library
- ``reqwest``: High-level HTTP client with async support
- ``serde``: Serialization/deserialization framework (for JSON handling)

Main Application (src/main.rs)
------------------------------

**Imports and Setup:**

.. code-block:: rust

   use std::collections::HashMap;
   use warp::Filter;
   
   #[tokio::main]
   async fn main() {

- ``std::collections::HashMap``: Standard library hash map for query parameters
- ``warp::Filter``: Core trait for composing HTTP handlers in Warp
- ``#[tokio::main]``: Attribute macro that sets up the Tokio async runtime

**Warp Filter Chain:**

.. code-block:: rust

   let webwords = warp::path::end()
       .and(warp::query::<HashMap<String, String>>())
       .and_then(handle_request);

Warp filter composition:
1. ``warp::path::end()``: Matches requests to the root path "/"
2. ``.and()``: Combines filters using Warp's combinator pattern
3. ``warp::query::<HashMap<String, String>>()``: Extracts query parameters into HashMap
4. ``.and_then(handle_request)``: Passes matched requests to handler function

**Server Startup:**

.. code-block:: rust

   println!("listening on 0.0.0.0:31337");
   warp::serve(webwords)
       .run(([0, 0, 0, 0], 31337))
       .await;

Server initialization:
1. Print startup message to stdout
2. ``warp::serve(webwords)``: Create server with the filter chain
3. ``.run(([0, 0, 0, 0], 31337))``: Bind to all interfaces on port 31337
4. ``.await``: Asynchronously run the server indefinitely

**Request Handler Function:**

.. code-block:: rust

   async fn handle_request(params: HashMap<String, String>) -> Result<impl warp::Reply, warp::Rejection> {
       let keyword = params.get("keyword").unwrap_or(&String::new()).clone();
       let target = params.get("target").unwrap_or(&String::new()).clone();

Handler function signature:
- ``async fn``: Asynchronous function that doesn't block the thread
- ``params: HashMap<String, String>``: Query parameters extracted by Warp
- ``Result<impl warp::Reply, warp::Rejection>``: Returns success response or error
- ``params.get("keyword").unwrap_or(&String::new())``: Safe parameter extraction with default

**HTTP Request Processing:**

.. code-block:: rust

   if !keyword.is_empty() && !target.is_empty() {
       match reqwest::get(&target).await {
           Ok(response) => {
               match response.text().await {
                   Ok(body) => {
                       if body.contains(&keyword) {
                           found = "true";
                       }

Async HTTP request flow:
1. Validate both parameters are non-empty
2. ``reqwest::get(&target).await``: Asynchronously fetch target URL
3. ``match`` pattern matching for explicit error handling
4. ``response.text().await``: Asynchronously convert response to text
5. ``body.contains(&keyword)``: Perform substring search

**Error Handling:**

.. code-block:: rust

   Err(e) => {
       println!("Error making request: {}", e);
   }

Rust's explicit error handling:
- All errors must be handled explicitly
- ``match`` ensures all Result variants are covered
- Errors are logged but don't crash the server
- Returns "false" for any error condition

Building and Running
====================

Step 1: Build the Docker image
------------------------------

.. code-block:: bash

   cd /home/fox/git/webwords/rust
   docker build -t webwords-rust .

Step 2: Run the container
-------------------------

.. code-block:: bash

   docker run -d -p 31337:31337 --name test-rust webwords-rust

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

   docker logs test-rust

Expected output:
- "listening on 0.0.0.0:31337" on startup
- "found=true, keyword=potato, uri=https://www.remarkbox.com" for requests

Step 5: Clean up
----------------

.. code-block:: bash

   docker stop test-rust
   docker rm test-rust

Common Issues
=============

Rust compilation errors
-----------------------

If the build fails with Rust compiler errors:

.. code-block:: bash

   # Check Rust version
   docker run -it rust:1.82 bash
   rustc --version
   cargo --version

Common Rust build issues:
- Dependency version conflicts (update Cargo.toml)
- Missing features for dependencies
- Compilation can take 10-15 minutes due to dependency building

Network request timeouts
------------------------

If HTTP requests fail or timeout:
- reqwest has built-in reasonable timeouts
- Network errors are logged but don't crash the server
- SSL certificates are required for HTTPS (installed in Dockerfile)

Binary size concerns
--------------------

Rust release builds can be large (~50MB+):
- Use ``cargo build --release`` for optimized builds
- Multi-stage Docker build keeps only the binary in final image
- Consider ``strip`` command to reduce binary size further

Memory and performance
---------------------

If you experience performance issues:
- Rust's zero-cost abstractions provide native performance
- Tokio runtime efficiently handles thousands of concurrent requests
- Memory safety prevents common crashes and security vulnerabilities

Async runtime errors
-------------------

If you see "no reactor running" or similar async errors:
- Ensure ``#[tokio::main]`` attribute is present
- All async functions must be `.await`ed within async context
- Warp and reqwest both require Tokio async runtime

Implementation Notes
===================

This Rust implementation demonstrates:
- **Memory Safety**: Compile-time guarantees prevent buffer overflows and memory leaks
- **Zero-Cost Abstractions**: High-level code compiles to efficient machine code
- **Async/Await**: Non-blocking I/O for handling thousands of concurrent requests
- **Pattern Matching**: Explicit error handling with Rust's Result type
- **Ownership System**: Automatic memory management without garbage collection
- **Type Safety**: Strong type system catches errors at compile time

The code combines Rust's performance and safety guarantees with modern async web programming patterns, resulting in a highly efficient and reliable WebWords service.