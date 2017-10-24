webwords - minimal viable docker
################################

This repo shows how to code the same minimal web app called ``webwords`` in many different programming languages.

It also provides a guides for building and running `webwords` as a docker image from scratch.

.. contents::

what is webwords
================

The ``webwords`` spec is a simple web application that accepts two query parameters:

target:
 The URI ``target`` that you want to search.

keyword:
 The ``keyword`` you want to search for.

The application always returns an ``HTTP 200`` response and the string ``true`` or ``false`` depending on if the keyword is found in the ``target`` web page body.

Once you have the application running inside docker, run this command to get the exposed port:

.. code-block:: bash

 docker ps

Finally you will be able to see if a ``keyword`` exists on a ``target`` in a browser like this:

.. code-block:: http

 http://127.0.0.1:32779/?target=https://www.remarkbox.com&keyword=potato3

Note: You will need to replace the port of ``32779`` with the port from the ``docker ps`` output.


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


debugging
=========

Are you like me? Do your programs rarely compile or work properly the first time?

Just like with programming, docker images rarely build corrently on the first shot. To debug you need to get the failed docker containers id:

.. code-block:: bash
 docker ps --all

Once you have the id, you can run the following to see the error:

.. code-block:: bash
 docker logs <container-id>

Debug the issue and fix your ``Dockerfile`` and retry the build until you have it working.

You can delete old attempts by running:

.. code-block:: bash

 docker rm <container-id>
