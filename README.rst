webwords: a minimal viable web app with docker in as many languages as possible
#################################################################################

**The companion** `webwords blog post <http://russell.ballestrini.net/webwords-is-a-minimal-viable-web-app-with-docker-in-as-many-languages-as-possible/>`_ **lives here.**

This project shows how to code the same minimal web app called ``webwords`` in as many different programming languages as possible.
It also provides guides for building and running ``webwords`` as a docker image.

.. contents::

what is webwords
================

A simple web application whose spec accepts the following two query parameters —

keyword:
 The ``keyword`` you want to search for.

target:
 The URI ``target`` that you want to search.

The application always returns an ``HTTP 200`` response with the string ``true`` or ``false`` depending on if the keyword is found in the ``target`` web page body.

For example, to see if the word ``potato`` exists on Remarkbox, put the following in a browser:

.. code-block:: txt

 http://127.0.0.1:31337/?keyword=potato&target=https://www.remarkbox.com

Spoiler:
 potato does exist on Remarkbox, : )

Note:
 You will need to replace the port of ``31337`` with the actual port from the ``docker ps`` output.


why is webwords
===============

What is a Programming Kata?
----------------------------

WebWords started as a programming **kata** (型) to practice writing code in different programming languages. 

A **kata** is a Japanese word meaning "form" or "way of doing," traditionally used in martial arts to describe choreographed patterns of movements practiced alone to perfect technique. In programming, a **kata** is a coding exercise designed to improve programming skills through repetitive practice.

Programming katas involve:

- **Repetition**: Solving the same problem multiple times to build muscle memory
- **Different approaches**: Implementing the same solution in various languages or paradigms
- **Focus on technique**: Emphasizing clean code, best practices, and language idioms
- **Learning through doing**: Hands-on practice rather than theoretical study

WebWords serves as an excellent programming kata because:

1. **Simple specification**: Easy to understand and implement in any language
2. **Real-world functionality**: Demonstrates HTTP server/client programming
3. **Cross-language comparison**: Shows how different languages approach the same problem
4. **Docker integration**: Provides consistent deployment across all implementations

Each port of webwords should behave identically to make comparing and functional testing simple.

**why did you choose this programming problem?**

I think the spec of webwords is small enough for people new to any language to digest but complete in that it does something useful and demonstrates two common tasks: running an HTTP server and using an HTTP client.

Also, I needed a way to verify if a user had possession of a domain name for the `comment service <https://www.remarkbox.com>`_ I'm building and chose to code this verification program as a micro service, first with Python and later with Go. The tiny end result was webwords. 

Shortly after, during a company hackathon at `Remind <http://engineering.remind.com/>`_ I used webwords to learn how to build Docker images for various languages and formalized the idea into a single project. 

**What's next?**

Webwords is for tinkering. If you want to add a version or touch up an existing version, send a PR.
Maybe a future fork will show a guide for adding a cache layer or teach how to add logging or gather metrics.


all 42 programming languages
=============================

Implementation Categories
=========================

**Native HTTP Server Implementations (33 languages):**

These languages implement actual HTTP servers using native language capabilities or proper web frameworks:

- C++, C#, Clojure, Crystal, Dart, Deno, Elixir, Erlang, F#, Go, Haskell, Java, JavaScript, Julia, Kotlin, Lua, Nim, OCaml, Odin, Perl, PHP, PowerShell, Prolog, Python, Ruby, Rust, Scala, Swift, TCL, V, VB.NET, Zig

**Wrapper-Based "Cheater" Implementations (9 languages):**

These languages use bash/shell wrappers with socat for HTTP handling, but differ in how they process the actual keyword search:

**Full Bash Implementations (4 languages):**
These use bash for both HTTP handling AND keyword searching:

- **Bash** - Uses native bash with socat (actually reasonable for bash); bash string matching  
- **Brainfuck** - Esoteric language with only 8 commands, HTTP impossible; uses bash string matching
- **COBOL** - Legacy business language, complex network programming; uses bash string matching
- **Fortran** - Scientific computing language, limited networking libraries; uses bash string matching

**Language-Specific Processing (5 languages):**
These use bash for HTTP but the target language for actual keyword search logic:

- **Assembly** - Bash fetches content, **Assembly performs low-level string search** using byte-level operations, registers, and syscalls
- **AWK** - Bash fetches content, **AWK performs advanced text analysis** using `index()`, `split()`, and line-by-line processing
- **MATLAB** - Bash fetches content, **Octave performs keyword search** using `strfind()` function with mathematical analysis
- **R** - Bash fetches content, **R performs statistical text analysis** using `gregexpr()` with pattern matching and statistics  
- **SQL** - Bash fetches content, **SQLite performs database search** using `INSTR()` function with proper SQL queries

**How They "Cheat":**

- **HTTP Infrastructure**: All 9 use bash + socat instead of implementing HTTP servers in the target language
- **Keyword Processing**: 4 languages use bash string matching; 5 languages use their native capabilities
- **Justification**: Implementing HTTP servers in Assembly, AWK, Brainfuck, COBOL, Fortran would be impractical
- **Hybrid Approach**: Assembly, AWK, MATLAB, R, and SQL demonstrate using each language for what it does best while bash handles networking

**Architecture Pattern:**
```
HTTP Request → Bash (socat) → Target Language Processing → Bash (HTTP response)
```

The "cheating" is in the HTTP infrastructure, but Assembly, AWK, MATLAB, R, and SQL implementations showcase genuine language-specific text processing capabilities.

Quick Start Guide
=================

**Try your first WebWords implementation with Python:**

This project includes a Makefile that simplifies building and testing. Let's start with Python as an example:

.. code-block:: bash

 # Build the Python implementation
 make build-python
 
 # Start the Python server (runs on port 31337)
 make serve-python
 
 # Test it works (should return "true")
 curl "http://localhost:31337/?keyword=potato&target=https://www.remarkbox.com"
 
 # Test negative case (should return "false") 
 curl "http://localhost:31337/?keyword=lemon&target=https://www.remarkbox.com"
 
 # Stop and cleanup when done
 make clean-python

**Alternative manual approach:**

.. code-block:: bash

 # Build manually
 cd python
 docker build -t webwords-python .
 
 # Run manually on a different port (e.g., 8080)
 docker run -d -p 8080:31337 --name my-webwords webwords-python
 curl "http://localhost:8080/?keyword=potato&target=https://www.remarkbox.com"
 
 # Cleanup manually
 docker stop my-webwords && docker rm my-webwords

**Ready to explore more languages?**

.. code-block:: bash

 # See all available commands
 make help
 
 # Build and test other languages (e.g., Go, JavaScript, Rust)
 make build-go && make serve-go
 make build-js && make serve-js
 
 # When you're ready, test all implementations
 make test-all

Makefile Commands Reference
===========================

The project includes a comprehensive Makefile with targets for building, testing, and managing all language implementations:

**Build Commands:**

.. code-block:: bash

 make build-all         # Build all Docker images in parallel
 make build-<language>  # Build specific language (e.g., make build-python)

**Testing Commands:**

.. code-block:: bash

 make test-all                    # Test all implementations (all CPU cores)
 make test-all-conservative       # Test with half CPU cores (safer)
 make test-all-single            # Test one at a time (safest)
 make test-all-custom JOBS=4     # Test with custom concurrency
 make functional-test-<language> # Test specific language

**Development Workflow:**

.. code-block:: bash

 make serve-<language>     # Run container on port 31337
 make functional-test      # Test any running implementation on port 31337
 make clean-<language>     # Stop and cleanup containers

**System Information:**

.. code-block:: bash

 make help                 # Show all available targets
 make system-info          # Show system capabilities for testing
 make status              # Show running WebWords containers

**Using Different Ports:**

The testing system automatically handles port conflicts by using random ports (32000-33000 range) during concurrent testing. For manual testing on different ports:

.. code-block:: bash

 # Run on custom port (replace 31337 with your desired port)
 docker run -d -p 8080:31337 --name test-python webwords-python
 curl "http://localhost:8080/?keyword=potato&target=https://www.remarkbox.com"

Individual Language Instructions
===============================

go
--

To build the docker image:

.. code-block:: bash

 cd go
 docker build -t webwords-go .

To run a test container from the new image:

.. code-block:: bash

 docker run -d -p 31337:31337 webwords-go

python
------

To build the docker image:

.. code-block:: bash

 cd python
 docker build -t webwords-python .

To run a test container from the new image:

.. code-block:: bash

 docker run -d -p 31337:31337 webwords-python


ruby
----

To build the docker image:

.. code-block:: bash

 cd ruby
 docker build -t webwords-ruby .

To run a test container from the new image:

.. code-block:: bash

 docker run -d -p 31337:31337 webwords-ruby


javascript
----------

To build the docker image:

.. code-block:: bash

 cd js
 docker build -t webwords-js .

To run a test container from the new image:

.. code-block:: bash

 docker run -d -p 31337:31337 webwords-js

csharp
------

To build the docker image:

.. code-block:: bash

 cd csharp
 docker build -t webwords-csharp .

To run a test container from the new image:

.. code-block:: bash

 docker run -d -p 31337:31337 webwords-csharp

java
----

To build the docker image:

.. code-block:: bash

 cd java
 docker build -t webwords-java .

To run a test container from the new image:

.. code-block:: bash

 docker run -d -p 31337:31337 webwords-java

php
---

To build the docker image:

.. code-block:: bash

 cd php
 docker build -t webwords-php .

To run a test container from the new image:

.. code-block:: bash

 docker run -d -p 31337:31337 webwords-php

rust
----

To build the docker image:

.. code-block:: bash

 cd rust
 docker build -t webwords-rust .

To run a test container from the new image:

.. code-block:: bash

 docker run -d -p 31337:31337 webwords-rust

cpp
---

To build the docker image:

.. code-block:: bash

 cd cpp
 docker build -t webwords-cpp .

To run a test container from the new image:

.. code-block:: bash

 docker run -d -p 31337:31337 webwords-cpp

c
-

To build the docker image:

.. code-block:: bash

 cd c
 docker build -t webwords-c .

To run a test container from the new image:

.. code-block:: bash

 docker run -d -p 31337:31337 webwords-c

kotlin
------

To build the docker image:

.. code-block:: bash

 cd kotlin
 docker build -t webwords-kotlin .

To run a test container from the new image:

.. code-block:: bash

 docker run -d -p 31337:31337 webwords-kotlin

swift
-----

To build the docker image:

.. code-block:: bash

 cd swift
 docker build -t webwords-swift .

To run a test container from the new image:

.. code-block:: bash

 docker run -d -p 31337:31337 webwords-swift

scala
-----

To build the docker image:

.. code-block:: bash

 cd scala
 docker build -t webwords-scala .

To run a test container from the new image:

.. code-block:: bash

 docker run -d -p 31337:31337 webwords-scala

perl
----

To build the docker image:

.. code-block:: bash

 cd perl
 docker build -t webwords-perl .

To run a test container from the new image:

.. code-block:: bash

 docker run -d -p 31337:31337 webwords-perl

lua
---

To build the docker image:

.. code-block:: bash

 cd lua
 docker build -t webwords-lua .

To run a test container from the new image:

.. code-block:: bash

 docker run -d -p 31337:31337 webwords-lua

elixir
------

To build the docker image:

.. code-block:: bash

 cd elixir
 docker build -t webwords-elixir .

To run a test container from the new image:

.. code-block:: bash

 docker run -d -p 31337:31337 webwords-elixir

dart
----

To build the docker image:

.. code-block:: bash

 cd dart
 docker build -t webwords-dart .

To run a test container from the new image:

.. code-block:: bash

 docker run -d -p 31337:31337 webwords-dart

r
-

To build the docker image:

.. code-block:: bash

 cd r
 docker build -t webwords-r .

To run a test container from the new image:

.. code-block:: bash

 docker run -d -p 31337:31337 webwords-r

haskell
-------

To build the docker image:

.. code-block:: bash

 cd haskell
 docker build -t webwords-haskell .

To run a test container from the new image:

.. code-block:: bash

 docker run -d -p 31337:31337 webwords-haskell

ocaml
-----

To build the docker image:

.. code-block:: bash

 cd ocaml
 docker build -t webwords-ocaml .

To run a test container from the new image:

.. code-block:: bash

 docker run -d -p 31337:31337 webwords-ocaml

fsharp
------

To build the docker image:

.. code-block:: bash

 cd fsharp
 docker build -t webwords-fsharp .

To run a test container from the new image:

.. code-block:: bash

 docker run -d -p 31337:31337 webwords-fsharp

clojure
-------

To build the docker image:

.. code-block:: bash

 cd clojure
 docker build -t webwords-clojure .

To run a test container from the new image:

.. code-block:: bash

 docker run -d -p 31337:31337 webwords-clojure

crystal
-------

To build the docker image:

.. code-block:: bash

 cd crystal
 docker build -t webwords-crystal .

To run a test container from the new image:

.. code-block:: bash

 docker run -d -p 31337:31337 webwords-crystal

nim
---

To build the docker image:

.. code-block:: bash

 cd nim
 docker build -t webwords-nim .

To run a test container from the new image:

.. code-block:: bash

 docker run -d -p 31337:31337 webwords-nim

erlang
------

To build the docker image:

.. code-block:: bash

 cd erlang
 docker build -t webwords-erlang .

To run a test container from the new image:

.. code-block:: bash

 docker run -d -p 31337:31337 webwords-erlang

julia
-----

To build the docker image:

.. code-block:: bash

 cd julia
 docker build -t webwords-julia .

To run a test container from the new image:

.. code-block:: bash

 docker run -d -p 31337:31337 webwords-julia

deno
----

To build the docker image:

.. code-block:: bash

 cd deno
 docker build -t webwords-deno .

To run a test container from the new image:

.. code-block:: bash

 docker run -d -p 31337:31337 webwords-deno

zig
---

To build the docker image:

.. code-block:: bash

 cd zig
 docker build -t webwords-zig .

To run a test container from the new image:

.. code-block:: bash

 docker run -d -p 31337:31337 webwords-zig

v
-

To build the docker image:

.. code-block:: bash

 cd v
 docker build -t webwords-v .

To run a test container from the new image:

.. code-block:: bash

 docker run -d -p 31337:31337 webwords-v

odin
----

To build the docker image:

.. code-block:: bash

 cd odin
 docker build -t webwords-odin .

To run a test container from the new image:

.. code-block:: bash

 docker run -d -p 31337:31337 webwords-odin

bash
----

To build the docker image:

.. code-block:: bash

 cd bash
 docker build -t webwords-bash .

To run a test container from the new image:

.. code-block:: bash

 docker run -d -p 31337:31337 webwords-bash

cobol
-----

To build the docker image:

.. code-block:: bash

 cd cobol
 docker build -t webwords-cobol .

To run a test container from the new image:

.. code-block:: bash

 docker run -d -p 31337:31337 webwords-cobol

fortran
-------

To build the docker image:

.. code-block:: bash

 cd fortran
 docker build -t webwords-fortran .

To run a test container from the new image:

.. code-block:: bash

 docker run -d -p 31337:31337 webwords-fortran

assembly
--------

To build the docker image:

.. code-block:: bash

 cd assembly
 docker build -t webwords-assembly .

To run a test container from the new image:

.. code-block:: bash

 docker run -d -p 31337:31337 webwords-assembly

prolog
------

To build the docker image:

.. code-block:: bash

 cd prolog
 docker build -t webwords-prolog .

To run a test container from the new image:

.. code-block:: bash

 docker run -d -p 31337:31337 webwords-prolog

matlab
------

To build the docker image:

.. code-block:: bash

 cd matlab
 docker build -t webwords-matlab .

To run a test container from the new image:

.. code-block:: bash

 docker run -d -p 31337:31337 webwords-matlab

powershell
----------

To build the docker image:

.. code-block:: bash

 cd powershell
 docker build -t webwords-powershell .

To run a test container from the new image:

.. code-block:: bash

 docker run -d -p 31337:31337 webwords-powershell

brainfuck
---------

To build the docker image:

.. code-block:: bash

 cd brainfuck
 docker build -t webwords-brainfuck .

To run a test container from the new image:

.. code-block:: bash

 docker run -d -p 31337:31337 webwords-brainfuck

sql
---

To build the docker image:

.. code-block:: bash

 cd sql
 docker build -t webwords-sql .

To run a test container from the new image:

.. code-block:: bash

 docker run -d -p 31337:31337 webwords-sql

vbnet
-----

To build the docker image:

.. code-block:: bash

 cd vbnet
 docker build -t webwords-vbnet .

To run a test container from the new image:

.. code-block:: bash

 docker run -d -p 31337:31337 webwords-vbnet

tcl
---

To build the docker image:

.. code-block:: bash

 cd tcl
 docker build -t webwords-tcl .

To run a test container from the new image:

.. code-block:: bash

 docker run -d -p 31337:31337 webwords-tcl

awk
---

To build the docker image:

.. code-block:: bash

 cd awk
 docker build -t webwords-awk .

To run a test container from the new image:

.. code-block:: bash

 docker run -d -p 31337:31337 webwords-awk

Testing All Languages
=====================

The project includes automated testing tools to verify all implementations work correctly:

.. code-block:: bash

 # Test all languages concurrently (uses all CPU cores)
 make test-all
 
 # Test with custom concurrency
 make test-all-custom JOBS=4
 
 # Test conservatively (half CPU cores)
 make test-all-conservative
 
 # Test single-threaded (safest)
 make test-all-single
 
 # Show system info for optimal testing
 make system-info

Concurrent Testing with Random Ports
====================================

The ``test-all.sh`` script automatically handles concurrent testing by assigning random ports to avoid conflicts. All containers listen on port 31337 internally, but get unique external ports (32000-33000 range).

**Manual concurrent testing:**

.. code-block:: bash

 # Generate random port and test
 RANDOM_PORT=$((32000 + RANDOM % 1000))
 docker run -d -p $RANDOM_PORT:31337 --name test-lang-$RANDOM_PORT webwords-lang
 curl "http://localhost:$RANDOM_PORT/?keyword=potato&target=https://www.remarkbox.com"
 docker stop test-lang-$RANDOM_PORT && docker rm test-lang-$RANDOM_PORT

debugging
=========

If you're anything like me, your programs rarely compile or work properly on the first try.
Just like with programming, a docker image will rarely build correct the first time so you will need to learn how to debug.

To debug, get the failed docker container's id:

.. code-block:: bash

 docker ps --all

Once you have the id, you can run the following to see the error:

.. code-block:: bash

 docker logs <container-id>

Debug the issue, fix your ``Dockerfile``, and retry the build process until you have it working.

You can delete old attempts by running:

.. code-block:: bash

 docker rm <container-id>
 
You may shell into a container like this:

.. code-block:: bash

 docker exec -i -t <container-id> /bin/sh    