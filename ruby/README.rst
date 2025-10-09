WebWords - Ruby Implementation
=============================

This directory contains the Ruby implementation of the WebWords service using a minimal Rails application with Rack and the HTTP gem.

Docker Overview
===============

Our Dockerfile uses Ruby Alpine with Rails framework and necessary build tools:

.. code-block:: dockerfile

   FROM ruby:3.4.6-alpine
   
   EXPOSE 31337
   
   RUN apk update && apk --update add build-base yaml-dev
   
   ADD config.ru /app/
   ADD Gemfile /app/
   
   RUN cd /app && bundle install --without development test
   
   ADD . /app
   
   ENV RAILS_ENV production
   WORKDIR /app
   
   CMD ["rackup", "-p", "31337", "-o", "0.0.0.0"]

**Dockerfile Breakdown:**
- ``FROM ruby:3.4.6-alpine``: Ruby 3.4.6 on lightweight Alpine Linux
- ``RUN apk --update add build-base yaml-dev``: Install compilation tools and YAML development headers
- ``ADD Gemfile /app/``: Copy dependency manifest first for layer caching
- ``RUN bundle install --without development test``: Install production gems only
- ``ENV RAILS_ENV production``: Set Rails environment for production optimizations
- ``CMD ["rackup", "-p", "31337", "-o", "0.0.0.0"]``: Start Rack server on port 31337

Understanding the Code
======================

This Ruby implementation uses a minimal Rails application with Rack web server, demonstrating Ruby's web development capabilities with minimal framework overhead.

Dependencies (Gemfile)
----------------------

.. code-block:: ruby

   source 'https://rubygems.org'
   
   gem "rails"
   gem "tzinfo-data"
   gem "http"
   gem "puma"

- ``rails``: Web application framework for Ruby
- ``tzinfo-data``: Timezone data for cross-platform compatibility
- ``http``: Simple HTTP client library for making requests
- ``puma``: High-performance web server (for production deployment)

Rack Configuration (config.ru)
------------------------------

**Framework Setup:**

.. code-block:: ruby

   require 'action_controller/railtie'
   require "http"
   
   class HelloWorld < Rails::Application
     routes.append do
       root to: 'hello#world'
     end

Application initialization:
1. ``require 'action_controller/railtie'``: Load minimal Rails controller framework
2. ``require "http"``: Load HTTP client gem
3. ``class HelloWorld < Rails::Application``: Define minimal Rails application
4. ``root to: 'hello#world'``: Route root path to HelloController#world action

**Application Configuration:**

.. code-block:: ruby

   config.secret_key_base = SecureRandom.hex(30)
   config.eager_load = false
   config.logger = Logger.new(STDOUT)

Configuration setup:
- ``secret_key_base``: Required Rails security token (generated randomly)
- ``eager_load = false``: Disable eager loading for faster startup in development
- ``logger = Logger.new(STDOUT)``: Configure logging to stdout for Docker

**Controller Implementation:**

.. code-block:: ruby

   class HelloController < ActionController::Base
     def world
       keyword = params[:keyword]
       target = params[:target]
       if HTTP.get(target).to_s.include? keyword
         render plain: 'true'
       else
         render plain: 'false'
       end
     end
   end

Request handling:
1. ``class HelloController < ActionController::Base``: Inherit from Rails base controller
2. ``params[:keyword]``: Extract keyword parameter from request
3. ``params[:target]``: Extract target URL parameter
4. ``HTTP.get(target).to_s``: Make HTTP GET request and convert response to string
5. ``.include? keyword``: Check if response contains the keyword
6. ``render plain: 'true'``: Send plain text response

**Application Startup:**

.. code-block:: ruby

   HelloWorld.initialize!
   
   run HelloWorld

Rack server setup:
1. ``HelloWorld.initialize!``: Initialize the Rails application
2. ``run HelloWorld``: Start the Rack-compatible application

Building and Running
====================

Step 1: Build the Docker image
------------------------------

.. code-block:: bash

   cd /home/fox/git/webwords/ruby
   docker build -t webwords-ruby .

Step 2: Run the container
-------------------------

.. code-block:: bash

   docker run -d -p 31337:31337 --name test-ruby webwords-ruby

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

   docker logs test-ruby

Expected output:
- Rails application startup messages
- Request logs showing HTTP processing

Step 5: Clean up
----------------

.. code-block:: bash

   docker stop test-ruby
   docker rm test-ruby

Common Issues
=============

Ruby gem installation failures
------------------------------

If bundle install fails during Docker build:

.. code-block:: bash

   # Check Ruby and Bundler versions
   docker run -it ruby:3.4.6-alpine sh
   ruby -v
   bundle -v

Common gem issues:
- Missing system dependencies (build-base, yaml-dev)
- Network connectivity during gem downloads
- Gem version conflicts

Rails secret key errors
-----------------------

If you see "Missing secret_key_base" errors:
- The implementation generates a random secret with ``SecureRandom.hex(30)``
- This is sufficient for the WebWords service
- In production, use a persistent secret key

HTTP gem network issues
----------------------

If HTTP requests fail:
- The HTTP gem handles SSL/HTTPS automatically
- No additional SSL configuration needed
- Built-in timeout and error handling

Port binding issues
------------------

If the server fails to start on port 31337:
- Rack server binds to all interfaces with ``-o 0.0.0.0``
- Check no other containers are using port 31337
- Verify rackup command syntax in Dockerfile

Memory and performance
---------------------

If you experience performance issues:
- Rails eager loading is disabled for faster startup
- HTTP gem is lightweight compared to alternatives
- Consider using Puma server for production (already included in Gemfile)

Missing system dependencies
--------------------------

If you see compilation errors:
- ``build-base``: Contains gcc, make, and other build tools
- ``yaml-dev``: Required for YAML processing in Rails
- These are installed in the Dockerfile

Implementation Notes
===================

This Ruby implementation demonstrates:
- **Minimal Rails Application**: Using only ActionController without full Rails stack
- **Rack Web Server**: Standard Ruby web server interface
- **HTTP Gem**: Simple, clean HTTP client library
- **Convention over Configuration**: Rails routing and parameter handling
- **Gem Ecosystem**: Leveraging RubyGems for dependency management
- **Alpine Linux Optimization**: Minimal container size with necessary build tools

The code showcases Ruby's expressiveness and Rails' convention-driven development, creating a fully functional web service with minimal code while maintaining Ruby's readability and Rails' structure.