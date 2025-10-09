WebWords - Python Implementation
=================================

This directory contains the Python implementation of the WebWords service using the Pyramid web framework.

Docker Overview
===============

Our Dockerfile uses Alpine Linux with Python 3 and pip for package management:

.. code-block:: dockerfile

   FROM alpine:latest
   RUN apk --no-cache add python3 py3-pip ca-certificates
   COPY requirements.txt /tmp/requirements.txt
   RUN pip3 install -r /tmp/requirements.txt
   COPY main.py /app/main.py
   WORKDIR /app
   EXPOSE 31337
   CMD ["python3", "main.py"]

The approach installs Python 3, pip, and SSL certificates, then installs our dependencies and runs the main application.

Understanding the Code
======================

This implementation uses the Pyramid web framework to create an HTTP server that checks if a keyword exists in a target URL.

Line-by-Line Code Explanation
-----------------------------

.. code-block:: python

   #!/usr/bin/env python3

This shebang line tells the system to use Python 3 to execute this script.

.. code-block:: python

   from wsgiref.simple_server import make_server
   from pyramid.config import Configurator
   from pyramid.response import Response
   import requests

These imports bring in the required modules:
- ``wsgiref.simple_server``: WSGI HTTP server from Python standard library
- ``pyramid.config.Configurator``: Pyramid framework configuration
- ``pyramid.response.Response``: HTTP response object
- ``requests``: HTTP client library for fetching URLs

.. code-block:: python

   def home(request):

This defines our main request handler function that processes incoming HTTP requests.

.. code-block:: python

   target  = request.params.get(u'target', None)
   keyword = request.params.get(u'keyword', None)

Extract query parameters from the URL. The ``u''`` prefix indicates Unicode strings (Python 2/3 compatibility).

.. code-block:: python

   found = u'false'
   print(target, keyword)

Initialize the result variable and log the parameters for debugging.

.. code-block:: python

   if target and keyword:
       resp = requests.get(target, allow_redirects=True)
       if keyword in resp.text:
           found = u'true'

If both parameters are provided:
1. Make an HTTP GET request to the target URL
2. Check if the keyword exists in the response text
3. Set result to 'true' if found

.. code-block:: python

   return Response(found)

Return the result as an HTTP response.

.. code-block:: python

   if __name__ == '__main__':
       with Configurator() as config:
           config.add_route('home', '/')
           config.add_view(home, route_name='home')
           app = config.make_wsgi_app()

This main block:
1. Creates a Pyramid configurator
2. Adds a route for the root path ('/')
3. Associates our home function with that route
4. Creates a WSGI application

.. code-block:: python

   server = make_server('0.0.0.0', 31337, app)
   print("listening on 0.0.0.0:31337")
   server.serve_forever()

Start the HTTP server:
1. Bind to all interfaces (0.0.0.0) on port 31337
2. Print startup message
3. Run the server indefinitely

Building and Running
====================

Step 1: Build the Docker image
------------------------------

.. code-block:: bash

   cd /home/fox/git/webwords/python
   docker build -t webwords-python .

Step 2: Run the container
-------------------------

.. code-block:: bash

   docker run -d -p 31337:31337 --name test-python webwords-python

Step 3: Test the service
------------------------

.. code-block:: bash

   # Test positive case (should return "true")
   curl "http://localhost:31337/?keyword=potato&target=https://www.remarkbox.com"

   # Test negative case (should return "false") 
   curl "http://localhost:31337/?keyword=lemon&target=https://www.remarkbox.com"

Step 4: Clean up
----------------

.. code-block:: bash

   docker stop test-python
   docker rm test-python

Common Issues
=============

Docker build fails with package errors
--------------------------------------

The Dockerfile uses Alpine package names. If you see package installation errors, verify the package names are correct for Alpine Linux.

Python import errors
--------------------

Ensure all dependencies in requirements.txt are installed. The main dependencies are:
- pyramid
- requests

Service doesn't respond
----------------------

Check that the container is running and the port is mapped correctly:

.. code-block:: bash

   docker ps
   docker logs test-python