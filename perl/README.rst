WebWords - Perl Implementation
==============================

This directory contains the Perl implementation of the WebWords service using HTTP::Daemon and LWP::UserAgent with traditional Perl scripting patterns.

Docker Overview
===============

Our Dockerfile uses the official Perl image with CPAN module installation:

.. code-block:: dockerfile

   FROM perl:5.36
   
   RUN cpanm HTTP::Daemon HTTP::Status LWP::UserAgent URI::Escape URL::Encode LWP::Protocol::https
   
   WORKDIR /app
   COPY app.pl .
   RUN chmod +x app.pl
   
   EXPOSE 31337
   
   CMD ["./app.pl"]

**Single-Stage Build Features:**

1. **Official Perl Image**: Perl 5.36 with full interpreter and standard library
2. **CPAN Installation**: ``cpanm`` installs HTTP server and client libraries
3. **Module Dependencies**: HTTP::Daemon, LWP::UserAgent, and URL processing utilities
4. **HTTPS Support**: LWP::Protocol::https for secure external connections
5. **Script Execution**: Direct execution of Perl script as executable

The build leverages Perl's mature ecosystem of CPAN modules for HTTP server and client functionality.

Understanding the Code
======================

This Perl implementation demonstrates traditional Perl scripting with CPAN modules for HTTP processing and text manipulation.

Main Application (app.pl)
-------------------------

**Shebang and Pragma Directives:**

.. code-block:: perl

   #!/usr/bin/env perl
   use strict;
   use warnings;
   use HTTP::Daemon;
   use HTTP::Status;
   use LWP::UserAgent;
   use URI::Escape;
   use URL::Encode qw(url_decode);

Perl script initialization:
- ``#!/usr/bin/env perl``: Shebang for script execution
- ``use strict;``: Enforces variable declarations and reduces common errors
- ``use warnings;``: Enables warning messages for potential issues
- ``use HTTP::Daemon;``: HTTP server framework module
- ``use HTTP::Status;``: HTTP status code constants
- ``use LWP::UserAgent;``: HTTP client library
- ``use URI::Escape;``: URL encoding/decoding utilities
- ``use URL::Encode qw(url_decode);``: Additional URL encoding functions

**HTTP Server Initialization:**

.. code-block:: perl

   my $daemon = HTTP::Daemon->new(
       LocalAddr => '0.0.0.0',
       LocalPort => 31337,
       ReuseAddr => 1
   ) or die "Cannot start daemon: $!";

HTTP::Daemon server setup:
1. ``my $daemon = HTTP::Daemon->new(...)``: Create HTTP server instance
2. ``LocalAddr => '0.0.0.0'``: Listen on all interfaces (Docker requirement)
3. ``LocalPort => 31337``: WebWords standard port
4. ``ReuseAddr => 1``: Allow port reuse (prevents "Address already in use" errors)
5. ``or die "Cannot start daemon: $!"``: Error handling with system error message

**Server Event Loop:**

.. code-block:: perl

   print "listening on 0.0.0.0:31337\n";
   
   while (my $client = $daemon->accept) {
       while (my $request = $client->get_request) {

Connection handling:
1. ``print "listening on 0.0.0.0:31337\n"``: Startup notification
2. ``while (my $client = $daemon->accept)``: Accept incoming connections
3. ``while (my $request = $client->get_request)``: Process HTTP requests
4. Nested loops handle multiple clients and multiple requests per client

**Request Processing:**

.. code-block:: perl

   if ($request->method eq 'GET' && $request->uri->path eq '/') {
       my %query = $request->uri->query_form;
       my $keyword = $query{keyword} || '';
       my $target = $query{target} || '';
       my $found = 'false';

Request parsing:
1. ``$request->method eq 'GET'``: Check HTTP method
2. ``$request->uri->path eq '/'``: Verify root path
3. ``my %query = $request->uri->query_form``: Parse query parameters into hash
4. ``my $keyword = $query{keyword} || ''``: Extract parameter with default
5. ``my $found = 'false'``: Initialize response value

**HTTP Client and Content Processing:**

.. code-block:: perl

   if ($keyword && $target) {
       my $ua = LWP::UserAgent->new(timeout => 10);
       my $response = $ua->get($target);
       
       if ($response->is_success) {
           my $body = $response->content;
           if (index($body, $keyword) != -1) {
               $found = 'true';
           }
       }

URL fetching and string search:
1. ``if ($keyword && $target)``: Validate both parameters exist
2. ``my $ua = LWP::UserAgent->new(timeout => 10)``: Create HTTP client with timeout
3. ``my $response = $ua->get($target)``: HTTP GET request
4. ``if ($response->is_success)``: Check for successful response
5. ``my $body = $response->content``: Extract response body
6. ``index($body, $keyword) != -1``: Perl string search (returns -1 if not found)

**Response Generation:**

.. code-block:: perl

   print "found=$found, keyword=$keyword, uri=$target\n";

   $client->send_response(HTTP::Response->new(
       RC_OK,
       'OK',
       ['Content-Type' => 'text/plain'],
       $found
   ));

HTTP response:
1. ``print "found=$found, ..."``: Debug logging to STDOUT
2. ``$client->send_response(...)``: Send HTTP response to client
3. ``HTTP::Response->new(...)``: Create response object
4. ``RC_OK``: HTTP 200 status constant
5. ``['Content-Type' => 'text/plain']``: Headers as array reference
6. ``$found``: Response body ("true" or "false")

**Error Handling and Cleanup:**

.. code-block:: perl

   } else {
       $client->send_error(RC_NOT_FOUND);
   }
   }
   $client->close;
   undef($client);

Connection cleanup:
1. ``$client->send_error(RC_NOT_FOUND)``: Send 404 for unmatched routes
2. ``$client->close``: Close client connection
3. ``undef($client)``: Clear client reference for garbage collection

Building and Running
====================

Step 1: Build the Docker image
------------------------------

.. code-block:: bash

   cd /home/fox/git/webwords/perl
   docker build -t webwords-perl .

CPAN modules will be downloaded and installed during build.

Step 2: Run the container
-------------------------

.. code-block:: bash

   docker run -d -p 31337:31337 --name test-perl webwords-perl

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

   docker logs test-perl

Expected output:
- "listening on 0.0.0.0:31337" on startup
- "found=true, keyword=potato, uri=https://www.remarkbox.com" for requests

Step 5: Clean up
----------------

.. code-block:: bash

   docker stop test-perl
   docker rm test-perl

Common Issues
=============

CPAN module installation errors
------------------------------

If CPAN module installation fails during Docker build:

.. code-block:: bash

   # Check CPAN module installation manually
   docker run -it perl:5.36 bash
   cpanm HTTP::Daemon

Common CPAN issues:
- Network connectivity problems downloading from CPAN mirrors
- Missing system dependencies for compiled modules
- Module version conflicts or circular dependencies

Perl syntax errors
-----------------

If Perl script fails to execute due to syntax errors:

.. code-block:: bash

   # Check Perl syntax
   docker run -v $(pwd):/app -it perl:5.36 bash
   cd /app && perl -c app.pl

Common Perl syntax issues:
- Missing semicolons at end of statements
- Incorrect sigils (``$``, ``@``, ``%``) for variable types
- Unmatched parentheses or brackets in complex expressions

HTTP::Daemon connection issues
-----------------------------

If HTTP server fails to bind or accept connections:

.. code-block:: bash

   # Check server binding and connection logs
   docker logs test-perl | grep -E "(bind|accept|daemon)"

HTTP::Daemon troubleshooting:
- Port 31337 already in use by another process
- Firewall blocking incoming connections
- Incorrect LocalAddr configuration for Docker

LWP::UserAgent timeout issues
----------------------------

If external HTTP requests timeout or fail:

.. code-block:: bash

   # Check HTTP client errors
   docker logs test-perl | grep -E "(timeout|error|fail)"

LWP::UserAgent configuration:
- Timeout setting too low for slow websites
- SSL certificate verification failures (HTTPS)
- Proxy configuration requirements

Variable scoping issues
---------------------

If variables are undefined or have unexpected values:

.. code-block:: bash

   # Enable warnings and strict mode debugging
   perl -Mdiagnostics app.pl

Perl variable scoping:
- Always use ``my`` for lexical variable declarations
- Avoid global variables without proper ``our`` declarations
- Be careful with loop variable scoping in nested loops

Implementation Notes
===================

This Perl implementation demonstrates:
- **Traditional Scripting**: Classic Perl scripting patterns with event loops
- **CPAN Ecosystem**: Leveraging mature HTTP server and client libraries
- **Text Processing**: Efficient string search using built-in ``index`` function
- **Error Handling**: Perl's ``or die`` pattern for graceful error handling
- **Connection Management**: Proper cleanup and resource management
- **Object-Oriented Modules**: Using HTTP::Daemon and LWP::UserAgent objects

The implementation showcases Perl's strengths in systems programming and web development. The HTTP::Daemon and LWP::UserAgent modules provide robust, production-ready HTTP functionality while maintaining Perl's characteristic simplicity and flexibility. The event-loop architecture efficiently handles multiple concurrent connections, demonstrating Perl's continued relevance for web service development despite its age.
- **System Integration**: Excellent for gluing systems together
- **Rapid Development**: Concise syntax for quick prototyping and scripting

**Perl vs Other Languages:**

- **Expressive**: ``$content =~ /keyword/i`` vs verbose string methods
- **Flexible**: Multiple ways to accomplish the same task
- **Pragmatic**: "Do what I mean" philosophy with sensible defaults
- **Powerful**: Complex text processing in single lines of code
- **Mature**: Decades of real-world usage in production systems

**Perl Syntax Essentials:**

- **Variables**: ``$scalar``, ``@array``, ``%hash`` for different data types
- **Sigils**: Symbols indicating variable type and context
- **Context**: Scalar vs list context affects behavior
- **References**: ``\$scalar``, ``\@array`` for memory efficiency
- **Regular Expressions**: ``/pattern/flags`` built into language syntax

HTTP Server Architecture
------------------------

**Native Perl HTTP Stack:**

.. code-block:: text

   ┌─────────────────┐
   │  HTTP Client    │ (curl/browser request)
   └─────────┬───────┘
             │
   ┌─────────▼───────┐
   │  HTTP::Daemon   │ (Perl HTTP server)
   └─────────┬───────┘
             │
   ┌─────────▼───────┐
   │ Request Handler │ (app.pl main loop)
   └─────────┬───────┘
             │
   ┌─────────▼───────┐
   │ LWP::UserAgent  │ (HTTP client for external requests)
   └─────────────────┘

**Component Responsibilities:**

1. **HTTP::Daemon**: Creates TCP server, handles HTTP protocol
2. **app.pl**: Main application loop and request processing
3. **LWP::UserAgent**: Fetches content from external URLs
4. **URI::Escape**: Handles URL encoding/decoding
5. **HTTP::Response**: Constructs proper HTTP responses

**Why Pure Perl:**

Unlike implementations requiring wrapper scripts, Perl handles the complete HTTP stack natively:

- **Self-Contained**: No external servers or proxies needed
- **Production Ready**: HTTP::Daemon used in real web applications
- **Robust**: Comprehensive error handling and edge case coverage
- **Efficient**: Optimized C-based implementations in core modules

Perl Program Structure
----------------------

**Module Imports and Configuration:**

.. code-block:: perl

   #!/usr/bin/env perl
   use strict;
   use warnings;
   use HTTP::Daemon;
   use HTTP::Status;
   use LWP::UserAgent;
   use URI::Escape;
   use URL::Encode qw(url_decode);

**Key Pragmas and Modules:**

- **strict**: Enforces variable declarations and safe programming practices
- **warnings**: Enables helpful warning messages for potential issues
- **HTTP::Daemon**: Full-featured HTTP server implementation
- **HTTP::Status**: HTTP status code constants (RC_OK, RC_NOT_FOUND, etc.)
- **LWP::UserAgent**: World Wide Web library for Perl client functionality

**HTTP Server Initialization:**

.. code-block:: perl

   my $daemon = HTTP::Daemon->new(
       LocalAddr => '0.0.0.0',
       LocalPort => 31337,
       ReuseAddr => 1
   ) or die "Cannot start daemon: $!";
   
   print "listening on 0.0.0.0:31337\n";

**Server Configuration Options:**

- **LocalAddr**: Bind to all interfaces (0.0.0.0) for container accessibility
- **LocalPort**: Listen on port 31337 as specified by WebWords protocol
- **ReuseAddr**: Allow port reuse to prevent "Address already in use" errors
- **Error Handling**: Die with descriptive message if server creation fails

Request Processing Loop
-----------------------

**Main Server Loop:**

.. code-block:: perl

   while (my $client = $daemon->accept) {
       while (my $request = $client->get_request) {
           if ($request->method eq 'GET' && $request->uri->path eq '/') {
               # Process WebWords request
               my %query = $request->uri->query_form;
               my $keyword = $query{keyword} || '';
               my $target = $query{target} || '';
               my $found = 'false';
               
               # Implementation continues...
           }
       }
   }

**Loop Structure:**

- **Outer Loop**: Accepts new client connections
- **Inner Loop**: Handles multiple requests per connection (HTTP keep-alive)
- **Method Check**: Validates HTTP method is GET
- **Path Check**: Ensures request is for root path ('/')
- **Query Parsing**: Extracts keyword and target parameters

**HTTP Request Object Methods:**

.. code-block:: perl

   # HTTP method (GET, POST, etc.)
   my $method = $request->method;
   
   # Request URI object
   my $uri = $request->uri;
   
   # Path component of URI
   my $path = $uri->path;
   
   # Query parameters as hash
   my %query = $uri->query_form;
   
   # Headers
   my $user_agent = $request->header('User-Agent');

URL Fetching and Processing
---------------------------

**LWP::UserAgent Configuration:**

.. code-block:: perl

   if ($keyword && $target) {
       my $ua = LWP::UserAgent->new(timeout => 10);
       my $response = $ua->get($target);
       
       if ($response->is_success) {
           my $body = $response->content;
           if (index($body, $keyword) != -1) {
               $found = 'true';
           }
       }
       
       print "found=$found, keyword=$keyword, uri=$target\n";
   }

**LWP::UserAgent Features:**

- **timeout => 10**: Prevents hanging on slow/unresponsive servers
- **Automatic Redirects**: Follows HTTP redirects by default
- **SSL/HTTPS Support**: LWP::Protocol::https enables secure connections
- **Error Handling**: is_success() method for robust error checking
- **Content Access**: content() method retrieves response body

**String Searching:**

.. code-block:: perl

   # Case-sensitive search using index()
   if (index($body, $keyword) != -1) {
       $found = 'true';
   }
   
   # Case-insensitive search using regular expressions
   if ($body =~ /\Q$keyword\E/i) {
       $found = 'true';
   }
   
   # Alternative using lc() for lowercase comparison
   if (index(lc($body), lc($keyword)) != -1) {
       $found = 'true';
   }

**Advanced URL Processing:**

.. code-block:: perl

   use URI;
   use URI::QueryParam;
   
   # Parse and validate URLs
   my $uri = URI->new($target);
   unless ($uri->scheme && $uri->host) {
       # Invalid URL format
       $found = 'error';
   }
   
   # Extract domain for logging
   my $domain = $uri->host;
   
   # Add query parameters
   $uri->query_param(source => 'webwords');

HTTP Response Generation
------------------------

**Creating HTTP Responses:**

.. code-block:: perl

   $client->send_response(HTTP::Response->new(
       RC_OK,                    # 200 status code
       'OK',                     # status message
       ['Content-Type' => 'text/plain'],  # headers
       $found                    # response body
   ));

**HTTP Response Components:**

- **Status Code**: RC_OK (200), RC_NOT_FOUND (404), RC_BAD_REQUEST (400)
- **Status Message**: Human-readable status description
- **Headers**: Array reference with header name/value pairs
- **Body**: Response content (search result: 'true' or 'false')

**Error Response Handling:**

.. code-block:: perl

   if ($request->method ne 'GET') {
       $client->send_error(RC_METHOD_NOT_ALLOWED);
   } elsif ($request->uri->path ne '/') {
       $client->send_error(RC_NOT_FOUND);
   } else {
       # Process valid request
   }

**Custom Headers and Status:**

.. code-block:: perl

   my $response = HTTP::Response->new(
       RC_OK,
       'OK',
       [
           'Content-Type' => 'text/plain',
           'Cache-Control' => 'no-cache',
           'Server' => 'Perl-WebWords/1.0',
           'Content-Length' => length($found)
       ],
       $found
   );
   $client->send_response($response);

Advanced Perl Features
----------------------

**Regular Expressions:**

.. code-block:: perl

   # Case-insensitive matching
   if ($body =~ /$keyword/i) {
       $found = 'true';
   }
   
   # Word boundary matching
   if ($body =~ /\b\Q$keyword\E\b/i) {
       $found = 'true';
   }
   
   # Multiple keywords
   my @keywords = split(/,/, $keyword);
   if (grep { $body =~ /\Q$_\E/i } @keywords) {
       $found = 'true';
   }

**Error Handling:**

.. code-block:: perl

   use Try::Tiny;
   
   try {
       my $response = $ua->get($target);
       if ($response->is_success) {
           my $body = $response->content;
           $found = (index($body, $keyword) != -1) ? 'true' : 'false';
       } else {
           warn "HTTP error: " . $response->status_line;
       }
   } catch {
       warn "Request failed: $_";
       $found = 'false';
   };

**Object-Oriented Programming:**

.. code-block:: perl

   package WebWords::Server;
   use Moose;
   
   has 'daemon' => (is => 'ro', isa => 'HTTP::Daemon', required => 1);
   has 'user_agent' => (is => 'ro', isa => 'LWP::UserAgent', lazy => 1, default => sub {
       LWP::UserAgent->new(timeout => 10)
   });
   
   sub process_request {
       my ($self, $request) = @_;
       # Request processing logic
   }

**Configuration Management:**

.. code-block:: perl

   use Config::YAML;
   
   my $config = Config::YAML->new(config => 'webwords.yml');
   
   my $daemon = HTTP::Daemon->new(
       LocalAddr => $config->{server}{bind_address},
       LocalPort => $config->{server}{port},
       Timeout   => $config->{server}{timeout}
   );

Build and Test Process
----------------------

**Building the Application:**

.. code-block:: bash

   # Navigate to Perl directory
   cd /home/fox/git/webwords/perl
   
   # Build Docker image
   docker build -t webwords-perl .
   
   # Run container
   docker run -d -p 31337:31337 --name perl-server webwords-perl

**Testing the Service:**

.. code-block:: bash

   # Test positive case (keyword found)
   curl "http://localhost:31337/?keyword=potato&target=https://www.remarkbox.com"
   # Expected output: true
   
   # Test negative case (keyword not found)
   curl "http://localhost:31337/?keyword=lemon&target=https://www.remarkbox.com"
   # Expected output: false

**Development Testing:**

.. code-block:: bash

   # Run Perl directly for debugging
   docker exec -it perl-server perl /app/app.pl
   
   # Check Perl version and modules
   docker exec perl-server perl -v
   docker exec perl-server perl -MHTTP::Daemon -e 'print $HTTP::Daemon::VERSION'

**Module Installation Verification:**

.. code-block:: bash

   # Verify CPAN modules are installed
   docker exec perl-server perl -MHTTP::Daemon -e 'print "HTTP::Daemon OK\n"'
   docker exec perl-server perl -MLWP::UserAgent -e 'print "LWP::UserAgent OK\n"'
   docker exec perl-server perl -MLWP::Protocol::https -e 'print "HTTPS support OK\n"'

**Interactive Testing:**

.. code-block:: perl

   # Test components interactively
   perl -e '
   use LWP::UserAgent;
   my $ua = LWP::UserAgent->new(timeout => 10);
   my $response = $ua->get("https://www.remarkbox.com");
   print "Status: ", $response->status_line, "\n";
   print "Content contains potato: ", (index($response->content, "potato") != -1 ? "YES" : "NO"), "\n";
   '

**Expected Output:**
::

   listening on 0.0.0.0:31337
   found=true, keyword=potato, uri=https://www.remarkbox.com
   found=false, keyword=lemon, uri=https://www.remarkbox.com

Troubleshooting Common Issues
-----------------------------

**Module Installation Issues:**

*Problem*: ``Can't locate HTTP/Daemon.pm in @INC``

*Solution*: Install missing CPAN modules
::

   # Install via cpanm
   cpanm HTTP::Daemon HTTP::Status LWP::UserAgent
   
   # Or via traditional CPAN
   perl -MCPAN -e 'install HTTP::Daemon'

*Problem*: ``SSL connect attempt failed with unknown error``

*Solution*: Install HTTPS support
::

   # Install SSL/HTTPS support
   cpanm LWP::Protocol::https
   
   # Alternative: disable SSL verification (not recommended for production)
   $ua->ssl_opts(verify_hostname => 0);

**Runtime Issues:**

*Problem*: ``bind: Address already in use``

*Solution*: Port 31337 occupied or ReuseAddr not set
::

   # Check what's using the port
   netstat -tulpn | grep 31337
   
   # Ensure ReuseAddr is enabled
   my $daemon = HTTP::Daemon->new(ReuseAddr => 1, ...);

*Problem*: ``Use of uninitialized value in string eq``

*Solution*: Handle undefined values properly
::

   # Check for undefined values
   my $keyword = $query{keyword} // '';  # Use // for defined-or
   my $target = $query{target} || '';    # Use || for true-or

**HTTP Client Issues:**

*Problem*: ``500 read timeout``

*Solution*: Adjust timeout settings
::

   # Increase timeout for slow servers
   my $ua = LWP::UserAgent->new(timeout => 30);
   
   # Add retry logic
   my $response = $ua->get($target);
   unless ($response->is_success) {
       $response = $ua->get($target);  # Retry once
   }

*Problem*: SSL certificate verification failures

*Solution*: Configure SSL options
::

   # Accept all certificates (development only)
   $ua->ssl_opts(verify_hostname => 0, SSL_verify_mode => 0);
   
   # Or provide certificate bundle
   $ua->ssl_opts(SSL_ca_file => '/etc/ssl/certs/ca-certificates.crt');

**Perl-Specific Issues:**

*Problem*: ``Global symbol "$variable" requires explicit package name``

*Solution*: Use strict pragma properly
::

   # Declare variables with my
   use strict;
   my $keyword = '';  # Correct
   
   # Or disable strict for quick scripts (not recommended)
   no strict 'vars';

Performance Optimization
------------------------

**HTTP::Daemon Performance:**

.. code-block:: perl

   # Enable connection keep-alive
   my $daemon = HTTP::Daemon->new(
       LocalAddr => '0.0.0.0',
       LocalPort => 31337,
       ReuseAddr => 1,
       Timeout   => 60
   );

**LWP::UserAgent Optimization:**

.. code-block:: perl

   # Reuse UserAgent instance
   my $ua = LWP::UserAgent->new(
       timeout => 10,
       keep_alive => 1,
       max_redirect => 3
   );
   
   # Enable compression
   $ua->default_header('Accept-Encoding' => 'gzip, deflate');

**Memory Management:**

.. code-block:: perl

   # Limit response size
   my $ua = LWP::UserAgent->new(max_size => 1024 * 1024);  # 1MB limit
   
   # Clean up large variables
   undef $body if length($body) > 100000;

**Concurrent Processing:**

.. code-block:: perl

   use threads;
   use Thread::Queue;
   
   my $queue = Thread::Queue->new();
   
   # Worker threads for processing
   for (1..4) {
       threads->create(\&worker_thread);
   }
   
   sub worker_thread {
       while (my $request = $queue->dequeue()) {
           process_request($request);
       }
   }

Real-World Perl Applications
----------------------------

**Web Development:**

- **Catalyst**: Full-featured MVC web framework
- **Mojolicious**: Modern web framework with built-in HTTP server
- **Dancer**: Lightweight web application framework
- **CGI.pm**: Classic web programming module

**System Administration:**

- **Log processing**: Parsing and analyzing log files
- **System monitoring**: Custom monitoring and alerting scripts
- **Automation**: Deployment and configuration management
- **Data migration**: ETL processes and data transformation

**Bioinformatics:**

- **BioPerl**: Comprehensive toolkit for biological data
- **Sequence analysis**: DNA/RNA/protein sequence processing
- **Data parsing**: Converting between biological data formats
- **Pipeline automation**: Workflow management for analysis

**Legacy System Integration:**

- **Text processing**: Parsing legacy data formats
- **Protocol translation**: Converting between data formats
- **Glue code**: Connecting disparate systems
- **Report generation**: Creating formatted reports from data

Further Learning Resources
--------------------------

**Official Documentation:**

- Perl.org: https://www.perl.org/
- Perl Documentation: https://perldoc.perl.org/
- Modern Perl: https://modernperlbooks.com/

**CPAN and Modules:**

- CPAN: https://www.cpan.org/
- MetaCPAN: https://metacpan.org/
- Task::Kensho: Recommended modules for Perl development

**Web Development:**

- Mojolicious: https://mojolicious.org/
- Catalyst: http://www.catalystframework.org/
- Dancer: https://perldancer.org/

**Books:**

- "Learning Perl" by Randal L. Schwartz
- "Intermediate Perl" by Randal L. Schwartz
- "Mastering Perl" by brian d foy
- "Modern Perl" by chromatic

**Community:**

- PerlMonks: https://www.perlmonks.org/
- Perl subreddit: https://www.reddit.com/r/perl/
- Perl conferences: YAPC, Perl Conference

**Testing and Quality:**

- Test::More: Comprehensive testing framework
- Perl::Critic: Code quality analysis
- Devel::Cover: Code coverage analysis
- Perl::Tidy: Code formatting and style

This Perl implementation demonstrates how a mature, text-processing oriented language can elegantly handle web service requirements while leveraging decades of CPAN module development and real-world usage patterns.