WebWords - PHP Implementation
============================

This directory contains the PHP implementation of the WebWords service using PHP's built-in HTTP functions with Apache web server.

Docker Overview
===============

Our Dockerfile uses the official PHP Apache image with custom port configuration:

.. code-block:: dockerfile

   FROM php:8.1-apache
   
   COPY index.php /var/www/html/
   
   EXPOSE 80
   
   RUN echo "Listen 31337" >> /etc/apache2/ports.conf && \
       echo "<VirtualHost *:31337>" >> /etc/apache2/sites-available/000-default.conf && \
       echo "    DocumentRoot /var/www/html" >> /etc/apache2/sites-available/000-default.conf && \
       echo "</VirtualHost>" >> /etc/apache2/sites-available/000-default.conf
   
   EXPOSE 31337
   
   CMD ["apache2-foreground"]

**Dockerfile Breakdown:**
- ``FROM php:8.1-apache``: Official PHP 8.1 with Apache web server
- ``COPY index.php /var/www/html/``: Copy PHP script to web root
- ``echo "Listen 31337" >> /etc/apache2/ports.conf``: Configure Apache to listen on port 31337
- ``echo "<VirtualHost *:31337>"...``: Add virtual host configuration for port 31337
- ``CMD ["apache2-foreground"]``: Run Apache in foreground mode

Understanding the Code
======================

This PHP implementation uses PHP's built-in HTTP client functions and Apache's request handling, demonstrating traditional web development patterns.

Main Application (index.php)
----------------------------

**Parameter Extraction:**

.. code-block:: php

   <?php
   $keyword = $_GET['keyword'] ?? '';
   $target = $_GET['target'] ?? '';
   $found = 'false';

Parameter handling:
1. ``$_GET['keyword'] ?? ''``: Extract keyword parameter with null coalescing operator
2. ``$_GET['target'] ?? ''``: Extract target parameter with empty string default
3. ``$found = 'false'``: Initialize result variable

**Input Validation:**

.. code-block:: php

   if (!empty($keyword) && !empty($target)) {

Basic validation to ensure both required parameters are present and non-empty.

**HTTP Context Configuration:**

.. code-block:: php

   $context = stream_context_create([
       'http' => [
           'timeout' => 10
       ]
   ]);

Stream context setup:
- ``stream_context_create()``: Create configuration for HTTP requests
- ``'timeout' => 10``: Set 10-second timeout for HTTP requests
- Context is used with ``file_get_contents()`` for HTTP operations

**HTTP Request and Response Processing:**

.. code-block:: php

   $body = @file_get_contents($target, false, $context);
   
   if ($body !== false && strpos($body, $keyword) !== false) {
       $found = 'true';
   }

HTTP request flow:
1. ``@file_get_contents($target, false, $context)``: Fetch URL contents
2. ``@`` operator suppresses warnings if request fails
3. ``$body !== false``: Check if request succeeded
4. ``strpos($body, $keyword) !== false``: Search for keyword in response
5. ``strpos()`` returns position of substring or false if not found

**Logging and Response:**

.. code-block:: php

   error_log("found=$found, keyword=$keyword, uri=$target");
   
   echo $found;
   ?>

Output handling:
1. ``error_log(...)``: Log request details to Apache error log
2. ``echo $found``: Send "true" or "false" response to client
3. No additional headers or HTTP status codes needed

Building and Running
====================

Step 1: Build the Docker image
------------------------------

.. code-block:: bash

   cd /home/fox/git/webwords/php
   docker build -t webwords-php .

Step 2: Run the container
-------------------------

.. code-block:: bash

   docker run -d -p 31337:31337 --name test-php webwords-php

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

   docker logs test-php

Expected output:
- Apache startup messages
- "found=true, keyword=potato, uri=https://www.remarkbox.com" in error log

Step 5: Clean up
----------------

.. code-block:: bash

   docker stop test-php
   docker rm test-php

Common Issues
=============

Apache configuration errors
---------------------------

If Apache fails to start:

.. code-block:: bash

   # Check Apache configuration
   docker run -it php:8.1-apache bash
   apache2ctl configtest

Common Apache issues:
- Port 31337 already in use
- Invalid virtual host configuration
- Permission issues with web root

PHP file_get_contents failures
------------------------------

If HTTP requests fail:
- ``allow_url_fopen`` must be enabled (default in PHP)
- SSL/HTTPS requests may need additional configuration
- Network timeouts are set to 10 seconds

Missing PHP extensions
---------------------

If you need additional HTTP client features:

.. code-block:: dockerfile

   # Add curl extension for more advanced HTTP handling
   RUN docker-php-ext-install curl

The basic implementation uses built-in PHP functions that work without additional extensions.

Port binding issues
------------------

If the container starts but doesn't respond:
- Check Apache is listening on port 31337: ``netstat -tlnp | grep 31337``
- Verify virtual host configuration
- Check Apache error logs for configuration issues

Memory and performance
---------------------

If you experience performance issues:
- ``file_get_contents()`` loads entire response into memory
- For large responses, consider using curl extension with streaming
- Apache handles multiple concurrent requests automatically

SSL/HTTPS issues
---------------

If HTTPS requests fail:
- PHP includes basic SSL support by default
- For custom SSL configuration, modify the stream context:

.. code-block:: php

   $context = stream_context_create([
       'http' => ['timeout' => 10],
       'ssl' => ['verify_peer' => false]  // For testing only
   ]);

Implementation Notes
===================

This PHP implementation demonstrates:
- **Traditional Web Development**: Classic PHP with Apache web server
- **Built-in HTTP Client**: Using ``file_get_contents()`` with stream context
- **Simple Parameter Handling**: Direct ``$_GET`` superglobal access
- **Error Suppression**: Using ``@`` operator for graceful error handling
- **Apache Integration**: Virtual host configuration for custom ports
- **Logging**: Apache error log integration for request tracking

The code showcases PHP's simplicity for web development with minimal configuration and built-in HTTP capabilities, making it one of the most straightforward WebWords implementations.