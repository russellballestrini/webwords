WebWords - SQL Implementation
=============================

This directory contains the SQL implementation of the WebWords service using PostgreSQL with a socat-based HTTP wrapper.

Docker Overview
---------------

Our Docker implementation combines PostgreSQL database functionality with HTTP server capabilities:

.. code-block:: dockerfile

   FROM postgres:15
   
   # Copy SQL script
   COPY webwords.sql /docker-entrypoint-initdb.d/
   
   # Note: SQL databases don't typically serve HTTP directly
   # This creates an HTTP server wrapper that processes requests
   RUN apt-get update && apt-get install -y socat curl ca-certificates && rm -rf /var/lib/apt/lists/*
   
   # Create HTTP request handler
   RUN echo '#!/bin/bash' > /usr/local/bin/handle_request.sh && \
       [... HTTP handler creation ...]
   
   # Create main server script  
   RUN echo '#!/bin/bash' > /usr/local/bin/webwords.sh && \
       echo 'socat TCP-LISTEN:31337,reuseaddr,fork EXEC:/usr/local/bin/handle_request.sh' >> /usr/local/bin/webwords.sh
   
   EXPOSE 31337
   
   CMD ["/usr/local/bin/webwords.sh"]

The implementation uses a hybrid architecture:

1. **Base Image**: Official PostgreSQL 15 with full SQL capabilities
2. **Database Layer**: PostgreSQL for data storage and SQL processing
3. **HTTP Layer**: socat for TCP connection handling
4. **Request Processing**: Bash scripts for HTTP protocol handling
5. **URL Fetching**: curl for external HTTP requests
6. **SQL Logic**: Stored procedures and functions for business logic

SQL Language Fundamentals
--------------------------

SQL (Structured Query Language) is a declarative language designed for managing and querying relational databases:

**Key Characteristics:**

- **Paradigm**: Declarative programming - describe what you want, not how to get it
- **Age**: Developed in the 1970s, standardized since 1986 (ANSI SQL)
- **Purpose**: Database management, data querying, and data manipulation
- **Execution**: Query optimizer determines the most efficient execution plan
- **Standards**: SQL-92, SQL:1999, SQL:2003, SQL:2008, SQL:2016, SQL:2023
- **Portability**: Standard syntax works across different database systems

**Why SQL for WebWords:**

SQL excels at:

- **Data Management**: Structured storage and retrieval of information
- **Logging and Auditing**: Built-in capabilities for tracking requests
- **Concurrent Access**: ACID properties for reliable multi-user operations
- **Complex Queries**: Powerful querying capabilities for data analysis
- **Stored Procedures**: Server-side logic execution

**SQL vs Other Languages:**

- **Declarative**: ``SELECT * FROM users WHERE age > 18`` vs imperative loops
- **Set-Based**: Operations on entire sets of data simultaneously
- **Optimized**: Database engine automatically optimizes query execution
- **Persistent**: Data survives program termination
- **Transactional**: ACID properties ensure data consistency

**SQL Components:**

- **DDL (Data Definition Language)**: ``CREATE``, ``ALTER``, ``DROP`` - define structure
- **DML (Data Manipulation Language)**: ``SELECT``, ``INSERT``, ``UPDATE``, ``DELETE`` - manipulate data
- **DCL (Data Control Language)**: ``GRANT``, ``REVOKE`` - control access
- **TCL (Transaction Control Language)**: ``COMMIT``, ``ROLLBACK`` - manage transactions

Architecture and Dependencies
-----------------------------

**Hybrid Architecture Explained:**

SQL databases are not designed to serve HTTP directly, so we create a multi-layer solution:

.. code-block:: text

   ┌─────────────────┐
   │  HTTP Client    │ (curl request)
   └─────────┬───────┘
             │
   ┌─────────▼───────┐
   │   socat Server  │ (handles TCP connections)
   └─────────┬───────┘
             │
   ┌─────────▼───────┐
   │  Bash Handler   │ (parses HTTP, processes requests)
   └─────────┬───────┘
             │
   ┌─────────▼───────┐
   │ PostgreSQL DB   │ (data storage & SQL processing)
   └─────────────────┘

**Component Responsibilities:**

1. **socat**: Creates TCP server listening on port 31337
2. **handle_request.sh**: Parses HTTP requests and extracts parameters
3. **curl**: Fetches content from external URLs
4. **PostgreSQL**: Stores request logs and provides SQL processing capabilities
5. **SQL Functions**: Business logic implemented as stored procedures

**Why This Approach:**

- **SQL Strengths**: Data persistence, complex queries, concurrent access
- **Shell Strengths**: System integration, HTTP protocol handling
- **Database Benefits**: ACID transactions, data integrity, audit trails
- **Flexibility**: Can extend with complex SQL analytics and reporting

PostgreSQL Database Schema
---------------------------

**Request Logging Table:**

.. code-block:: sql

   CREATE TABLE IF NOT EXISTS webwords_log (
       id SERIAL PRIMARY KEY,
       keyword VARCHAR(255),
       target_url TEXT,
       found BOOLEAN,
       created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
   );

**Schema Features:**

- **SERIAL PRIMARY KEY**: Auto-incrementing unique identifier
- **VARCHAR(255)**: Variable-length string for keywords (max 255 chars)
- **TEXT**: Unlimited length for URLs
- **BOOLEAN**: True/false for search results
- **TIMESTAMP**: Automatic timestamp for each request

**Data Types Explained:**

- **SERIAL**: Auto-incrementing integer (shorthand for sequence)
- **VARCHAR(n)**: Variable character string with maximum length
- **TEXT**: Variable unlimited length character string
- **BOOLEAN**: Logical true/false values
- **TIMESTAMP**: Date and time with timezone support

SQL Stored Procedures
---------------------

**Main Business Logic Function:**

.. code-block:: sql

   CREATE OR REPLACE FUNCTION check_webwords(
       p_keyword VARCHAR(255),
       p_target TEXT
   ) RETURNS TEXT AS $$
   DECLARE
       v_found BOOLEAN := FALSE;
       v_result TEXT := 'false';
   BEGIN
       -- Parameter validation
       IF p_keyword IS NOT NULL AND p_target IS NOT NULL THEN
           -- Log the request
           INSERT INTO webwords_log (keyword, target_url, found)
           VALUES (p_keyword, p_target, v_found);
           
           -- Output log message
           RAISE NOTICE 'found=%, keyword=%, uri=%', v_result, p_keyword, p_target;
       END IF;
       
       RETURN v_result;
   END;
   $$ LANGUAGE plpgsql;

**PL/pgSQL Features:**

- **DECLARE**: Variable declarations with initialization
- **BEGIN/END**: Block structure for procedural code
- **IF/THEN/END IF**: Conditional logic
- **INSERT**: Data manipulation within functions
- **RAISE NOTICE**: Logging output (equivalent to print/console.log)
- **RETURN**: Function result

**Function Parameters:**

- **p_keyword**: Input parameter for search keyword
- **p_target**: Input parameter for target URL
- **RETURNS TEXT**: Function returns a text string

**Error Handling and Logging:**

.. code-block:: sql

   -- Robust parameter checking
   IF p_keyword IS NULL OR p_target IS NULL THEN
       RAISE WARNING 'Invalid parameters: keyword=%, target=%', p_keyword, p_target;
       RETURN 'false';
   END IF;
   
   -- Exception handling
   BEGIN
       INSERT INTO webwords_log (keyword, target_url, found)
       VALUES (p_keyword, p_target, v_found);
   EXCEPTION
       WHEN OTHERS THEN
           RAISE NOTICE 'Database error: %', SQLERRM;
           RETURN 'error';
   END;

HTTP Request Flow
-----------------

**Complete Request Processing:**

1. **Client Request**: ``GET /?keyword=potato&target=https://example.com``

2. **socat Reception**: TCP server accepts the connection

3. **Shell Parsing**: 
   ::

      # Extract query parameters from HTTP request
      QUERY=$(echo "$REQUEST" | sed "s/GET \/?\([^ ]*\).*/\1/")
      KEYWORD=$(echo "$QUERY" | sed -n "s/.*keyword=\([^&]*\).*/\1/p")
      TARGET=$(echo "$QUERY" | sed -n "s/.*target=\([^&]*\).*/\1/p")

4. **URL Fetching**:
   ::

      BODY=$(curl -s --max-time 10 "$TARGET" 2>/dev/null || echo "")

5. **Keyword Matching**:
   ::

      if echo "$BODY" | grep -q "$KEYWORD"; then
          RESULT="true"
      else
          RESULT="false"
      fi

6. **SQL Integration** (Future Enhancement):
   ::

      # Connect to PostgreSQL and execute SQL function
      psql -d webwords -c "SELECT check_webwords('$KEYWORD', '$TARGET');"

7. **HTTP Response**:
   ::

      HTTP/1.1 200 OK
      Content-Type: text/plain
      Content-Length: 4
      
      true

**Database Logging:**

.. code-block:: sql

   -- Every request is logged to the database
   INSERT INTO webwords_log (keyword, target_url, found)
   VALUES ('potato', 'https://example.com', true);
   
   -- Query recent requests
   SELECT keyword, target_url, found, created_at 
   FROM webwords_log 
   ORDER BY created_at DESC 
   LIMIT 10;

Advanced SQL Features
---------------------

**Views for Endpoint Simulation:**

.. code-block:: sql

   CREATE OR REPLACE VIEW webwords_endpoint AS
   SELECT 
       'GET /?keyword=' || keyword || '&target=' || target_url AS request,
       check_webwords(keyword, target_url) AS response,
       created_at
   FROM webwords_log
   WHERE created_at = (SELECT MAX(created_at) FROM webwords_log);

**Complex Queries for Analytics:**

.. code-block:: sql

   -- Most searched keywords
   SELECT keyword, COUNT(*) as search_count
   FROM webwords_log
   GROUP BY keyword
   ORDER BY search_count DESC;
   
   -- Success rate by domain
   SELECT 
       SUBSTRING(target_url FROM 'https?://([^/]+)') as domain,
       AVG(CASE WHEN found THEN 1.0 ELSE 0.0 END) as success_rate,
       COUNT(*) as total_requests
   FROM webwords_log
   GROUP BY domain
   HAVING COUNT(*) > 5;
   
   -- Hourly request pattern
   SELECT 
       EXTRACT(HOUR FROM created_at) as hour_of_day,
       COUNT(*) as request_count
   FROM webwords_log
   WHERE created_at >= NOW() - INTERVAL '7 days'
   GROUP BY hour_of_day
   ORDER BY hour_of_day;

**Triggers for Automatic Processing:**

.. code-block:: sql

   -- Trigger function for automatic processing
   CREATE OR REPLACE FUNCTION process_new_request()
   RETURNS TRIGGER AS $$
   BEGIN
       -- Automatically process new requests
       IF NEW.found IS NULL THEN
           -- Could trigger external HTTP request here
           NEW.found := (NEW.keyword = 'example');
       END IF;
       
       RETURN NEW;
   END;
   $$ LANGUAGE plpgsql;
   
   -- Create trigger
   CREATE TRIGGER auto_process_request
       BEFORE INSERT ON webwords_log
       FOR EACH ROW
       EXECUTE FUNCTION process_new_request();

Build and Test Process
----------------------

**Building the Application:**

.. code-block:: bash

   # Navigate to SQL directory
   cd /home/fox/git/webwords/sql
   
   # Build Docker image
   docker build -t webwords-sql .
   
   # Run container (PostgreSQL + HTTP server)
   docker run -d -p 31337:31337 -e POSTGRES_PASSWORD=webwords --name sql-server webwords-sql

**Testing the Service:**

.. code-block:: bash

   # Test positive case (keyword found)
   curl "http://localhost:31337/?keyword=potato&target=https://www.remarkbox.com"
   # Expected output: true
   
   # Test negative case (keyword not found)
   curl "http://localhost:31337/?keyword=lemon&target=https://www.remarkbox.com"
   # Expected output: false

**Database Testing:**

.. code-block:: bash

   # Connect to PostgreSQL directly
   docker exec -it sql-server psql -U postgres -d postgres
   
   # Test SQL functions manually
   postgres=# SELECT check_webwords('test', 'http://example.com');
   postgres=# SELECT * FROM webwords_log ORDER BY created_at DESC LIMIT 5;
   postgres=# \q

**Data Analysis Queries:**

.. code-block:: sql

   -- View all logged requests
   SELECT id, keyword, target_url, found, created_at 
   FROM webwords_log 
   ORDER BY created_at DESC;
   
   -- Count requests by keyword
   SELECT keyword, COUNT(*) as count 
   FROM webwords_log 
   GROUP BY keyword 
   ORDER BY count DESC;
   
   -- Success rate statistics
   SELECT 
       COUNT(*) as total_requests,
       SUM(CASE WHEN found THEN 1 ELSE 0 END) as successful_requests,
       ROUND(AVG(CASE WHEN found THEN 1.0 ELSE 0.0 END) * 100, 2) as success_rate_percent
   FROM webwords_log;

**Expected Database Contents:**
::

   id | keyword | target_url                    | found | created_at
   ---+---------+-------------------------------+-------+------------------------
   1  | potato  | https://www.remarkbox.com     | t     | 2024-01-15 10:30:15
   2  | lemon   | https://www.remarkbox.com     | f     | 2024-01-15 10:30:20

Troubleshooting Common Issues
-----------------------------

**PostgreSQL Connection Issues:**

*Problem*: ``FATAL: database "webwords" does not exist``

*Solution*: Create database or use default postgres database
::

   # Create database
   docker exec sql-server createdb -U postgres webwords
   
   # Or connect to default database
   psql -U postgres -d postgres

*Problem*: ``FATAL: password authentication failed``

*Solution*: Set correct PostgreSQL password
::

   # Set password via environment variable
   docker run -e POSTGRES_PASSWORD=mypassword webwords-sql

**SQL Syntax Issues:**

*Problem*: ``ERROR: syntax error at or near "$"`

*Solution*: Check PL/pgSQL function syntax
::

   -- Correct function syntax
   CREATE OR REPLACE FUNCTION my_function()
   RETURNS TEXT AS $$
   BEGIN
       RETURN 'result';
   END;
   $$ LANGUAGE plpgsql;

*Problem*: ``ERROR: function check_webwords() does not exist``

*Solution*: Ensure function is created in correct database
::

   # Connect to correct database
   \c webwords
   
   # List all functions
   \df

**HTTP Server Issues:**

*Problem*: Container starts but HTTP requests fail

*Solution*: Check if socat server is running
::

   # Check processes in container
   docker exec sql-server ps aux | grep socat
   
   # Check if port is listening
   docker exec sql-server netstat -tulpn | grep 31337

*Problem*: SQL functions not executing

*Solution*: Check PostgreSQL logs and function permissions
::

   # View PostgreSQL logs
   docker logs sql-server
   
   # Check function exists and permissions
   docker exec sql-server psql -U postgres -c "\df check_webwords"

Database Performance Optimization
----------------------------------

**Indexing for Performance:**

.. code-block:: sql

   -- Create indexes for common queries
   CREATE INDEX idx_webwords_keyword ON webwords_log(keyword);
   CREATE INDEX idx_webwords_created_at ON webwords_log(created_at);
   CREATE INDEX idx_webwords_target_domain ON webwords_log(SUBSTRING(target_url FROM 'https?://([^/]+)'));

**Query Optimization:**

.. code-block:: sql

   -- Use EXPLAIN to analyze query performance
   EXPLAIN ANALYZE SELECT * FROM webwords_log WHERE keyword = 'potato';
   
   -- Optimize with proper WHERE clauses
   SELECT * FROM webwords_log 
   WHERE created_at >= NOW() - INTERVAL '1 hour'
   AND keyword = 'potato';

**Connection Pooling:**

.. code-block:: sql

   -- Configure connection limits
   ALTER SYSTEM SET max_connections = 100;
   ALTER SYSTEM SET shared_buffers = '256MB';
   SELECT pg_reload_conf();

Real-World SQL Applications
---------------------------

**Web Application Backends:**

- E-commerce order processing
- User authentication and authorization
- Content management systems
- Financial transaction processing

**Analytics and Reporting:**

- Business intelligence dashboards
- Data warehousing and ETL processes
- Real-time analytics and monitoring
- Customer behavior analysis

**Integration Patterns:**

- REST API data layer
- Microservices data persistence
- Event sourcing and CQRS
- Data synchronization between systems

**PostgreSQL Extensions:**

- **PostgREST**: Automatic REST API generation
- **pg_http**: HTTP client for database
- **plv8**: JavaScript stored procedures
- **PostGIS**: Geographic information systems

Further Learning Resources
--------------------------

**SQL Standards and Documentation:**

- PostgreSQL Documentation: https://www.postgresql.org/docs/
- SQL Standard (ISO/IEC 9075): Official SQL specification
- SQL Tutorial: https://www.w3schools.com/sql/

**Advanced PostgreSQL:**

- PL/pgSQL Developer's Guide: https://www.postgresql.org/docs/current/plpgsql.html
- PostgreSQL Performance Tuning: https://wiki.postgresql.org/wiki/Performance_Optimization
- Extensions and Add-ons: https://www.postgresql.org/docs/current/external-extensions.html

**Database Design:**

- Database Design Principles: Normalization, ACID properties
- Entity-Relationship Modeling: Design patterns and best practices
- Index Design: B-tree, Hash, GIN, GiST index types

**SQL in Web Development:**

- Object-Relational Mapping (ORM): SQLAlchemy, Django ORM, Hibernate
- Database Migrations: Version control for database schemas
- Connection Pooling: pgBouncer, connection management
- Database Security: SQL injection prevention, access control

**Community and Tools:**

- Stack Overflow SQL Tag: Active community for Q&A
- DBA Stack Exchange: Database administration focused
- pgAdmin: PostgreSQL administration and development platform
- DataGrip: JetBrains SQL IDE

**Books:**

- "PostgreSQL: Up and Running" by Regina Obe and Leo Hsu
- "SQL Antipatterns" by Bill Karwin
- "Database Design for Mere Mortals" by Michael Hernandez

This SQL implementation demonstrates how traditional database systems can be integrated into modern web service architectures while leveraging SQL's strengths in data management, complex querying, and transaction processing.