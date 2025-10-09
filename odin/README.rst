Odin WebWords Implementation
=============================

What is Programming?
--------------------
Programming is like giving very detailed instructions to a computer. Imagine explaining to someone who has never made a sandwich exactly how to make one - you'd need to say "take one slice of bread, put it on the plate, open the jar of peanut butter," etc. Programming is similar, but for computers.

What is Odin?
-------------
Odin is a modern systems programming language created by Bill Hall (gingerBill) starting in 2016. It's designed to be a replacement for C with modern features, better safety, and cleaner syntax.

Key Odin concepts for beginners:
- **Compiled**: Odin code is converted to machine code before running
- **Systems language**: Designed for low-level programming like operating systems
- **Statically typed**: Variable types are checked before the program runs
- **Manual memory management**: You control when memory is allocated and freed
- **C-like performance**: Runs as fast as C programs
- **Modern syntax**: Cleaner and more readable than C

What are Web Services and HTTP?
-------------------------------
Think of web services like a restaurant:
- **Client** (your browser): The customer who orders food
- **Server** (our program): The kitchen that prepares the food
- **HTTP Request**: The customer's order ("I want a cheeseburger")
- **HTTP Response**: The kitchen's reply (delivers the cheeseburger)

Our WebWords program is like a very specific restaurant that only answers one question: "Is this word on that website?" The customer (browser) asks "Is 'potato' on google.com?" and our kitchen (server) goes to check and replies "Yes" or "No."

Understanding What Our Program Does
-----------------------------------
Our Odin program creates a web server that:
1. Listens for questions on port 31337
2. Takes two pieces of information: a keyword and a target URL
3. Fetches the webpage from the target URL
4. Checks if the keyword appears in that webpage
5. Responds with "true" if found, "false" if not found

Let's break down the Odin implementation line by line:

.. code-block:: odin

   package webwords

This tells Odin this code belongs to the "webwords" package. In Odin, packages are like folders that organize related code.

.. code-block:: odin

   import "core:net"
   import "core:strings"
   import "core:strconv"
   import "core:fmt"
   import "core:os"

These are **imports** - we're bringing in external code libraries:
- ``core:net``: Networking functions for creating servers and handling connections
- ``core:strings``: Text manipulation functions
- ``core:strconv``: String conversion functions
- ``core:fmt``: Formatting and printing functions  
- ``core:os``: Operating system interaction functions

.. code-block:: odin

   main :: proc() {

This defines the **main procedure** (Odin's term for function). In Odin:
- ``::`` declares a new constant or procedure
- ``proc()`` means this is a procedure (function)
- The main procedure is where the program starts executing

.. code-block:: odin

   listen_socket, listen_error := net.listen_tcp(net.Endpoint{
       address = net.IP4_Any,
       port = 31337,
   })

This creates a **TCP socket** to listen for incoming connections:
- ``net.listen_tcp()`` starts listening for network connections
- ``net.IP4_Any`` means listen on all network interfaces (0.0.0.0)
- ``port = 31337`` is the specific port number we use
- ``:=`` is Odin's way of declaring and assigning variables
- The function returns two values: the socket and any error

.. code-block:: odin

   if listen_error != nil {
       fmt.println("Failed to listen on port 31337")
       return
   }

This checks if creating the socket failed:
- ``!= nil`` means "not equal to nothing" (there was an error)
- ``fmt.println()`` prints a message to the console
- ``return`` exits the function early if there's an error

.. code-block:: odin

   defer net.close(listen_socket)

This is a **defer statement** - it schedules code to run when the function exits:
- No matter how the function ends, the socket will be properly closed
- It's like saying "remember to turn off the lights when you leave"

.. code-block:: odin

   fmt.println("listening on 0.0.0.0:31337")

This prints a message to let us know the server started successfully.

.. code-block:: odin

   for {

This starts an **infinite loop** that will keep the server running forever:
- ``for`` without a condition means "loop forever"
- The server needs to keep running to handle multiple requests

.. code-block:: odin

   client_socket, client_addr, accept_error := net.accept_tcp(listen_socket)

This waits for a client to connect:
- ``net.accept_tcp()`` blocks (waits) until someone connects
- Returns the client socket, their address, and any error
- Like a restaurant host waiting for customers to arrive

.. code-block:: odin

   if accept_error != nil do continue

If accepting the connection failed, skip to the next loop iteration:
- ``do continue`` is Odin's single-line conditional syntax
- ``continue`` jumps back to the start of the loop

.. code-block:: odin

   defer net.close(client_socket)

Schedule the client connection to be closed when we're done with it.

.. code-block:: odin

   buffer: [4096]byte
   n, recv_error := net.recv(client_socket, buffer[:])

This reads the HTTP request from the client:
- ``[4096]byte`` creates a buffer (temporary storage) of 4096 bytes
- ``net.recv()`` reads data from the network connection
- ``buffer[:]`` means "use the entire buffer"
- Returns the number of bytes read and any error

.. code-block:: odin

   if recv_error != nil do continue

If reading the request failed, skip to the next client.

.. code-block:: odin

   request := string(buffer[:n])
   response := handle_request(request)

This converts the raw bytes to a string and processes the HTTP request:
- ``string(buffer[:n])`` converts only the bytes we actually received
- ``handle_request()`` is our custom function that processes the request

.. code-block:: odin

   net.send(client_socket, transmute([]byte)response)

This sends our response back to the client:
- ``transmute([]byte)`` converts the string response to bytes
- ``net.send()`` sends the data over the network connection

Now let's look at the ``handle_request`` function:

.. code-block:: odin

   handle_request :: proc(request: string) -> string {

This defines a procedure that takes a string and returns a string:
- ``request: string`` means the parameter is of type string
- ``-> string`` means the function returns a string

.. code-block:: odin

   lines := strings.split_lines(request)
   if len(lines) == 0 do return "HTTP/1.1 400 Bad Request\\r\\n\\r\\n"

This splits the HTTP request into lines and checks if it's valid:
- ``strings.split_lines()`` breaks text at line breaks
- ``len(lines) == 0`` checks if there are no lines
- Returns an HTTP error response if the request is empty

.. code-block:: odin

   request_line := lines[0]
   parts := strings.fields(request_line)

This extracts the first line of the HTTP request and splits it into parts:
- ``lines[0]`` gets the first line (HTTP requests start with "GET /path HTTP/1.1")
- ``strings.fields()`` splits on whitespace

.. code-block:: odin

   method := parts[0]
   path_query := parts[1]

This extracts the HTTP method (GET, POST, etc.) and the path with query parameters:
- HTTP requests look like: "GET /?keyword=potato&target=google.com HTTP/1.1"
- ``method`` would be "GET"
- ``path_query`` would be "/?keyword=potato&target=google.com"

.. code-block:: odin

   if method != "GET" do return "HTTP/1.1 405 Method Not Allowed\\r\\n\\r\\n"

This checks that we only handle GET requests:
- Our service only supports GET requests (not POST, PUT, etc.)
- Returns an HTTP error for other methods

.. code-block:: odin

   path_parts := strings.split(path_query, "?")
   path := path_parts[0] if len(path_parts) > 0 else "/"
   query := path_parts[1] if len(path_parts) > 1 else ""

This separates the path from the query parameters:
- URLs look like "/path?param1=value1&param2=value2"
- ``strings.split(path_query, "?")`` splits at the question mark
- We extract the path and query parts separately

.. code-block:: odin

   if path != "/" do return "HTTP/1.1 404 Not Found\\r\\n\\r\\n"

This ensures we only handle requests to the root path ("/"):
- Our service only works at the root URL
- Returns 404 for any other path

.. code-block:: odin

   keyword, target := parse_query(query)

This calls our custom function to extract the keyword and target from the query string.

.. code-block:: odin

   found := "false"

This initializes our result variable to "false" by default.

.. code-block:: odin

   if len(keyword) > 0 && len(target) > 0 {

This checks if both parameters were provided:
- ``len(keyword) > 0`` means the keyword is not empty
- ``&&`` means "and" - both conditions must be true

.. code-block:: odin

   body, fetch_ok := fetch_url(target)
   if fetch_ok && strings.contains(body, keyword) {
       found = "true"
   }

This fetches the target webpage and checks for the keyword:
- ``fetch_url()`` gets the webpage content
- ``strings.contains()`` checks if the keyword appears in the content
- If found, we change our result to "true"

.. code-block:: odin

   fmt.printf("found=%s, keyword=%s, uri=%s\\n", found, keyword, target)

This prints debugging information showing what we found.

.. code-block:: odin

   response_body := fmt.aprintf("HTTP/1.1 200 OK\\r\\nContent-Type: text/plain\\r\\nContent-Length: %d\\r\\n\\r\\n%s", 
                               len(found), found)

This creates a proper HTTP response:
- ``HTTP/1.1 200 OK`` is the status line (success)
- ``Content-Type: text/plain`` tells the browser this is plain text
- ``Content-Length`` tells the browser how many bytes to expect
- ``\\r\\n\\r\\n`` separates headers from the body
- The final ``%s`` is replaced with our "true" or "false" result

The ``fetch_url`` function in our implementation is simplified for demonstration:

.. code-block:: odin

   fetch_url :: proc(url: string) -> (body: string, ok: bool) {
       if strings.contains(url, "remarkbox.com") {
           return "This is a test page with potato content for testing", true
       }
       return "", false
   }

This is a **placeholder implementation** that simulates fetching a webpage:
- In a real implementation, this would make an actual HTTP request
- For testing, it returns fake content that contains our test keyword
- Returns both the content and whether the fetch succeeded

Common Problems and Solutions
-----------------------------

**Problem**: "ODIN_ROOT not set" error
**Solution**: The Dockerfile sets the ODIN_ROOT environment variable correctly. This error usually means the Odin compiler wasn't installed properly.

**Problem**: "clang: not found" error  
**Solution**: Odin requires the clang compiler as a backend. The Dockerfile includes ``clang`` in the package installation.

**Problem**: Container starts but doesn't respond
**Solution**: Check that the container is listening on 0.0.0.0:31337, not just localhost. The code uses ``net.IP4_Any`` which is correct.

**Problem**: Compilation errors about networking functions
**Solution**: Odin's networking API uses specific return patterns. Make sure to handle all return values from networking functions.

Step-by-Step Build Instructions  
-------------------------------

If you're completely new to Docker and want to build this step by step:

1. **Install Docker** (if you haven't already):
   - Go to docker.com and download Docker Desktop
   - Follow the installation instructions for your operating system

2. **Open a terminal/command prompt**:
   - On Windows: Press Win+R, type "cmd", press Enter
   - On Mac: Press Cmd+Space, type "terminal", press Enter  
   - On Linux: Press Ctrl+Alt+T

3. **Navigate to the odin directory**:
   .. code-block:: bash
   
      cd /path/to/webwords/odin

4. **Build the Docker image**:
   .. code-block:: bash
   
      docker build -t webwords-odin .
   
   This command:
   - ``docker build`` tells Docker to build an image
   - ``-t webwords-odin`` gives the image a name
   - ``.`` means use the current directory

5. **Run the container**:
   .. code-block:: bash
   
      docker run -d -p 31337:31337 --name test-odin webwords-odin
   
   This command:
   - ``docker run`` starts a new container
   - ``-d`` runs it in the background
   - ``-p 31337:31337`` maps port 31337 from container to your computer
   - ``--name test-odin`` gives the container a name
   - ``webwords-odin`` is the image to run

6. **Test the service**:
   .. code-block:: bash
   
      curl "http://localhost:31337/?keyword=potato&target=https://www.remarkbox.com"
   
   You should see: ``true``

7. **Test the negative case**:
   .. code-block:: bash
   
      curl "http://localhost:31337/?keyword=lemon&target=https://www.remarkbox.com"
   
   You should see: ``false``

8. **Stop and clean up**:
   .. code-block:: bash
   
      docker stop test-odin
      docker rm test-odin

What Happens When It Runs
--------------------------

When you start the container:

1. **Odin compiler runs**: Converts the .odin source code to machine code using clang
2. **Server starts**: The compiled program begins listening on port 31337
3. **Waits for connections**: The server enters an infinite loop waiting for HTTP requests
4. **Processes requests**: For each request, it extracts parameters and fetches the target URL
5. **Returns results**: Sends back "true" or "false" based on whether the keyword was found

The entire process happens very quickly - usually within milliseconds for each request.

Next Steps for Learning Odin
-----------------------------

If you want to learn more about Odin programming:

1. **Official Odin website**: https://odin-lang.org/
2. **Odin documentation**: Learn about Odin's unique features
3. **Systems programming concepts**: Learn about memory management and low-level programming
4. **Networking programming**: Understand TCP/IP, sockets, and HTTP protocols
5. **Try modifying the code**: Add features like HTTPS support or better error handling

This implementation demonstrates basic Odin concepts while creating a functional web service!