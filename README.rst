MVD - Minimal Viable Docker
###########################

This repo holds shows how to build the same minimal web app in many different programming languages.

It also shows you how you can build and run a docker image of the application from scratch.

The program is a simple web application that accepts two query parameters:

target:
 The URI `target` that you want to search.

keyword:
 The `keyword` you want to search for.

The application returns an HTTP 200 response either way and the string `true` or `false` depending on if the keyword is found in the remote web page body.


go
========

To build the docker image:

.. code-block:: bash

 cd go
 docker build -t webwords-go .

To run a test container from the new image:

.. code-block:: bash

 docker run -d -p 8888 webwords-go

python
========

To build the docker image:

.. code-block:: bash

 cd python
 docker build -t webwords-python .

To run a test container from the new image:

.. code-block:: bash

 docker run -d -p 8888 webwords-python


Debugging
=========

Are you like me? Do your programs rarely compile or work properly the first time?

Just like with programming, building docker images rarely work on the first shot.

To debug you need to get the failed docker containers id:

.. code-block:: bash
 docker ps --all

Once you have the id, you can run the following to see the error:

.. code-block:: bash
 docker logs <container-id>

Debug the issue and fix your `Dockerfile` and retry the build until you have it working.

You can delete old attempts by running:

.. code-block:: bash

 docker rm <container-id>
