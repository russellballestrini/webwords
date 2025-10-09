WebWords - R Implementation
===========================

This directory contains the R implementation of the WebWords service, demonstrating statistical computing and data analysis concepts.

What is Programming?
====================

Programming is the process of creating instructions for computers to follow. Think of it like writing a detailed recipe - you provide step-by-step instructions that the computer follows exactly. Just as a recipe tells you how to cook a meal, a computer program tells the computer how to solve problems or perform tasks.

Programming languages are different ways of writing these instructions. Some languages are good for web applications, others for mobile apps, and some (like R) are specially designed for statistical computing and data analysis.

What is R?
==========

R is a programming language and environment designed specifically for statistical computing, data analysis, and graphics. Unlike general programming languages, R is built around statistical concepts and data manipulation.

Key characteristics of R:

- **Statistical Focus**: Built specifically for data analysis and statistical computing
- **Interactive Environment**: You can type commands and see results immediately
- **Vectorized Operations**: Work with entire datasets efficiently
- **Rich Ecosystem**: Thousands of packages for specialized analysis (CRAN repository)
- **Visualization**: Excellent tools for creating graphs, plots, and data visualizations
- **Open Source**: Free and community-driven development

Real-world R applications:
- Pharmaceutical companies use it for clinical trial analysis
- Financial firms use it for risk modeling and quantitative analysis  
- Academic researchers use it for statistical research and publication
- Government agencies use it for survey analysis and policy research
- Marketing companies use it for customer analytics and A/B testing
- Biotech companies use it for genomics and bioinformatics analysis

What is Statistical Computing?
==============================

Statistical computing involves using computers to analyze data, identify patterns, and make predictions based on mathematical and statistical methods. This includes:

- **Descriptive Statistics**: Summarizing data with means, medians, standard deviations
- **Inferential Statistics**: Making predictions about populations from samples
- **Data Visualization**: Creating charts and graphs to understand data patterns
- **Machine Learning**: Teaching computers to identify patterns in data
- **Hypothesis Testing**: Determining if observed differences are statistically significant

R excels at these tasks because it provides:
- Built-in statistical functions (mean, median, correlation, regression, etc.)
- Data structures optimized for statistical analysis (vectors, data frames, matrices)
- Comprehensive statistical test implementations
- Advanced visualization capabilities

What are Statistical Computing Environments?
============================================

A statistical computing environment is the software infrastructure needed to analyze data and perform statistical operations. Think of it like a fully-equipped laboratory:

- **Just as a lab needs**: Microscopes, measuring instruments, computers, analysis software
- **An R environment needs**: R interpreter, statistical libraries, data structures, visualization tools

R Environment Components:
- **R Interpreter**: The core software that runs R code and manages computations
- **Base R**: Fundamental functions for data manipulation and basic statistics
- **Package System**: Thousands of specialized libraries via CRAN (Comprehensive R Archive Network)
- **Data Structures**: Vectors, matrices, data frames, and lists for organizing data
- **Graphics Engine**: System for creating plots, charts, and visualizations
- **Memory Management**: Efficient handling of large datasets

Our Docker Implementation Approach:
Since R traditionally runs interactively, our implementation uses:
- **Rscript**: Command-line execution mode for running R scripts
- **Shell wrapper**: Handles HTTP requests and passes parameters to R
- **Environment variables**: Bridge between HTTP parameters and R script
- **System integration**: R calls external programs (curl) for web requests

Docker Overview
===============

Docker is a tool that packages applications into containers - think of containers as lightweight, portable virtual machines that include everything needed to run an application.

Why use Docker for R?
- **Environment Consistency**: Ensures R packages and dependencies work the same everywhere
- **Reproducibility**: Statistical analyses produce identical results across systems
- **Package Management**: Includes all required R packages and system libraries
- **Isolation**: Prevents conflicts with other software on the host system
- **Collaboration**: Other researchers can run your exact R environment

Our Dockerfile Breakdown
========================

Let's examine each line of our Dockerfile and understand what it does:

.. code-block:: dockerfile

   FROM r-base:4.3.0

**Line 1 - Base Image Selection**:
This tells Docker to start with the official R base image version 4.3.0. This image includes:
- Complete R interpreter and runtime
- Base R packages and statistical functions
- Rscript command-line interface
- Debian Linux foundation with R-specific optimizations

.. code-block:: dockerfile

   RUN apt-get update && apt-get install -y \
       curl \
       socat \
       && rm -rf /var/lib/apt/lists/*

**Lines 4-7 - Installing System Tools**:
- ``apt-get update``: Downloads the latest package list from Debian repositories
- ``curl``: Tool for downloading web content (for fetching target URLs)
- ``socat``: Network tool for handling HTTP connections (simple web server functionality)
- ``rm -rf /var/lib/apt/lists/*``: Cleans up package cache to keep container small

These tools complement R's statistical capabilities with web connectivity.

.. code-block:: dockerfile

   WORKDIR /app
   COPY app.R .
   COPY webwords_wrapper.sh .
   RUN chmod +x webwords_wrapper.sh

**Lines 9-12 - Setting up Application Files**:
- ``WORKDIR /app``: Creates and switches to the /app directory (like cd /app)
- ``COPY app.R .``: Copy our R script into the container
- ``COPY webwords_wrapper.sh .``: Copy our shell wrapper script
- ``chmod +x``: Makes the shell script executable (like a program you can run)

.. code-block:: dockerfile

   EXPOSE 31337
   CMD ["socat", "TCP-LISTEN:31337,reuseaddr,fork", "EXEC:/app/webwords_wrapper.sh"]

**Lines 14-17 - Server Configuration**:
- ``EXPOSE 31337``: Tells Docker our application listens on port 31337
- ``CMD``: Specifies which program to run when the container starts
- ``socat``: Creates a simple HTTP server that calls our wrapper script
- ``TCP-LISTEN:31337``: Listen for connections on port 31337
- ``EXEC:/app/webwords_wrapper.sh``: Run our wrapper script for each request

Understanding the Code
======================

What is an HTTP Server?
-----------------------

An HTTP server is a program that waits for requests from web browsers and responds with information. Think of it like a research library:

- **Client (Browser)**: Researcher looking for specific information
- **HTTP Request**: The research question ("Does this dataset contain potato references?")
- **Server (Our Program)**: Library that searches through data and provides answers
- **HTTP Response**: The research findings delivered to the researcher

Our HTTP server listens on port 31337 and responds to requests like:
``http://localhost:31337/?keyword=potato&target=https://example.com``

Line-by-Line Code Explanation
-----------------------------

**R Script (app.R)**:

.. code-block:: r

   # Simple R WebWords Implementation
   # Uses socat HTTP wrapper with environment variables for parameter passing

**Lines 1-2 - Comments**:
- ``#``: R comment symbol (explains what the code does)
- Describes the implementation approach using environment variables

.. code-block:: r

   keyword <- ""
   target <- ""

**Lines 5-6 - Variable Initialization**:
- ``<-``: R assignment operator (different from = in other languages)
- ``""``: Empty string initialization
- Variables store the search keyword and target URL

.. code-block:: r

   if (nchar(Sys.getenv("KEYWORD")) > 0) {
     keyword <- Sys.getenv("KEYWORD")
   }

**Lines 9-11 - Environment Variable Reading**:
- ``Sys.getenv()``: R function to read environment variables
- ``nchar()``: R function that counts characters in a string
- ``> 0``: Check if the environment variable has content
- This reads the keyword parameter passed from the HTTP wrapper

.. code-block:: r

   if (keyword != "" && target != "") {
     tryCatch({
       # Error-safe code here
     }, error = function(e) {
       # Handle errors silently  
     })
   }

**Lines 18-45 - Main Logic with Error Handling**:
- ``!=``: "Not equal to" comparison operator
- ``&&``: Logical AND operator (both conditions must be true)
- ``tryCatch()``: R's error handling function (like try/catch in other languages)
- ``error = function(e)``: Define what to do if an error occurs

.. code-block:: r

   temp_file <- "/tmp/webwords_response.html"
   result <- system2("curl", c("-s", "-m", "10", "-o", temp_file, target), stdout = FALSE, stderr = FALSE)

**Lines 21-29 - URL Fetching**:
- ``<-``: Assignment of file path to variable
- ``system2()``: R function to run external programs
- ``"curl"``: The external program to run (web content fetcher)
- ``c()``: R function to create a vector (list) of arguments
- ``"-s"``: Silent mode (no progress output)
- ``"-m", "10"``: Maximum 10 seconds timeout
- ``"-o", temp_file``: Output to specified file
- ``stdout = FALSE``: Don't capture program output

.. code-block:: r

   if (file.exists(temp_file) && file.info(temp_file)$size > 0) {
     body <- paste(readLines(temp_file, warn = FALSE), collapse = "\n")
     if (grepl(keyword, body, fixed = TRUE)) {
       found <- "true"
     }
   }

**Lines 32-38 - File Processing and Search**:
- ``file.exists()``: R function to check if a file exists
- ``file.info()$size``: Get file size information
- ``readLines()``: R function to read all lines from a file
- ``paste()``: R function to combine strings
- ``collapse = "\n"``: Join lines with newline characters
- ``grepl()``: R function for pattern matching (grep + logical result)
- ``fixed = TRUE``: Treat search term as literal text (not regular expression)

**Shell Wrapper (webwords_wrapper.sh)**:

.. code-block:: bash

   while IFS= read -r line; do
       if [[ $line =~ ^GET ]]; then
           # Process HTTP request
           break
       fi
   done

**Lines 6-24 - HTTP Request Parsing**:
- ``while``: Shell loop that continues until condition is false
- ``read -r line``: Read one line of input
- ``[[ $line =~ ^GET ]]``: Check if line starts with "GET" (HTTP request)
- ``break``: Exit the loop when we find the GET request line

.. code-block:: bash

   export KEYWORD="$keyword"
   export TARGET="$target"
   result=$(Rscript /app/app.R)

**Lines 27-31 - R Script Execution**:
- ``export``: Make variables available to child processes
- ``$()``: Shell command substitution (capture program output)
- ``Rscript``: Command-line R interpreter
- This passes the extracted parameters to R and captures its output

Key Programming Concepts
========================

Variables in R
--------------

R variables can hold different types of data:

.. code-block:: r

   text_data <- "potato"              # Character (string)
   number_data <- 42                  # Numeric
   logical_data <- TRUE               # Boolean (TRUE/FALSE)
   vector_data <- c(1, 2, 3, 4)       # Vector (list of numbers)
   dataframe_data <- data.frame(      # Data frame (like a spreadsheet)
     name = c("Alice", "Bob"),
     age = c(30, 25)
   )

R uses ``<-`` for assignment, which visually shows the direction of assignment.

Vectors and Vectorization
-------------------------

R's fundamental data structure is the vector - a collection of elements of the same type:

.. code-block:: r

   numbers <- c(1, 2, 3, 4, 5)        # Numeric vector
   names <- c("Alice", "Bob", "Carol") # Character vector
   
   # Vectorized operations work on entire vectors at once
   doubled <- numbers * 2              # c(2, 4, 6, 8, 10)
   lengths <- nchar(names)             # c(5, 3, 5)

This is much more efficient than processing elements one by one.

Data Frames
-----------

Data frames are R's equivalent of spreadsheets or database tables:

.. code-block:: r

   survey_data <- data.frame(
     participant = c("P001", "P002", "P003"),
     age = c(25, 30, 35),
     score = c(85, 92, 78)
   )
   
   # Access columns
   survey_data$age                     # Get age column
   survey_data[1, ]                    # Get first row
   survey_data[, "score"]              # Get score column

Functions in R
--------------

R has thousands of built-in functions for statistical analysis:

.. code-block:: r

   data <- c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
   
   # Descriptive statistics
   mean(data)                          # 5.5
   median(data)                        # 5.5
   sd(data)                           # Standard deviation
   var(data)                          # Variance
   summary(data)                      # Min, Q1, Median, Mean, Q3, Max

Error Handling
--------------

R provides structured error handling for robust programs:

.. code-block:: r

   result <- tryCatch({
     # Code that might fail
     risky_calculation()
   }, error = function(e) {
     # Handle the error
     message("Error occurred: ", e$message)
     return(default_value)
   }, warning = function(w) {
     # Handle warnings
     message("Warning: ", w$message)
   })

Building and Running (Complete Beginner Guide)
==============================================

Step 1: Open Terminal/Command Prompt
------------------------------------

**Windows**: 
- Press Windows key + R
- Type "cmd" and press Enter
- A black window appears - this is your command prompt

**Mac**:
- Press Cmd + Space
- Type "terminal" and press Enter  
- A terminal window opens

**Linux**:
- Press Ctrl + Alt + T
- Terminal window opens

Step 2: Navigate to the Code
----------------------------

Type the following command and press Enter:

.. code-block:: bash

   cd /home/fox/git/webwords/r

This changes your current directory to where the R code is located. Think of it like navigating to a specific folder.

If you get "No such file or directory", the code might be in a different location. Ask where the webwords project is stored.

Step 3: Build with Docker
-------------------------

Type this command and press Enter:

.. code-block:: bash

   docker build -t webwords-r .

**What this does**:
- ``docker build``: Tells Docker to create a container image
- ``-t webwords-r``: Names the image "webwords-r"  
- ``.``: Use the current directory (which contains our Dockerfile)

**What you'll see**:
- Docker downloads R base image (includes complete R environment)
- Installs system tools (curl, socat)
- Copies our R script and wrapper into the container
- Sets up the statistical computing environment

This may take 3-7 minutes the first time due to R's comprehensive statistical library.

Step 4: Run the Container
------------------------

Type this command:

.. code-block:: bash

   docker run -d -p 31337:31337 --name test-r webwords-r

**What this does**:
- ``docker run``: Starts a container from our image
- ``-d``: Run in background (detached mode)
- ``-p 31337:31337``: Connect port 31337 inside container to port 31337 on your computer
- ``--name test-r``: Give the container a friendly name
- ``webwords-r``: Use the image we just built

Step 5: Test the R Statistical Service
--------------------------------------

**Test 1 - Positive Case** (should find "potato"):

.. code-block:: bash

   curl "http://localhost:31337/?keyword=potato&target=https://www.remarkbox.com"

Expected result: ``true``

**Test 2 - Negative Case** (should not find "lemon"):

.. code-block:: bash

   curl "http://localhost:31337/?keyword=lemon&target=https://www.remarkbox.com"

Expected result: ``false``

Step 6: View R Processing Logs
------------------------------

To see any R output or error messages:

.. code-block:: bash

   docker logs test-r

You should see minimal output since R runs quietly in our implementation.

Step 7: Interactive R Testing (Optional)
----------------------------------------

To run R commands interactively inside the container:

.. code-block:: bash

   docker exec -it test-r R

This opens an R prompt where you can try statistical commands:

.. code-block:: r

   # Try some R commands
   data <- c(1, 2, 3, 4, 5)
   mean(data)
   summary(data)
   quit()

Type ``quit()`` to exit the R prompt.

Step 8: Clean Up
----------------

When you're done testing:

.. code-block:: bash

   docker stop test-r
   docker rm test-r

This stops and removes the test container.

Understanding What the Program Does
===================================

When you visit ``http://localhost:31337/?keyword=potato&target=https://www.remarkbox.com``:

**Step 1**: Your browser sends an HTTP request to our R service
**Step 2**: The socat server receives the request and calls webwords_wrapper.sh
**Step 3**: The shell script parses the HTTP request to extract "potato" and "https://www.remarkbox.com"
**Step 4**: The wrapper sets environment variables and calls Rscript with our app.R
**Step 5**: R reads the environment variables using Sys.getenv()
**Step 6**: R calls the external curl program to download the target webpage
**Step 7**: R reads the downloaded content and uses grepl() for pattern matching
**Step 8**: R returns "true" or "false" based on whether the keyword was found
**Step 9**: The shell wrapper formats this as an HTTP response and sends it back

**R-Specific Features**:
- Statistical computing environment for data analysis
- Vectorized string operations for efficient text processing
- Comprehensive error handling with tryCatch()
- Integration with external tools through system2()
- Environment variable processing for parameter passing

What Happens When It Runs
=========================

**Statistical Computing Environment Initialization**:
1. Docker starts R interpreter with complete statistical library
2. R loads base packages for data manipulation and analysis
3. Memory management system initializes for handling data structures
4. Our wrapper script prepares to receive HTTP requests
5. socat begins listening on port 31337 for incoming connections

**Request Processing Flow**:
1. HTTP request arrives with keyword and target URL parameters
2. Shell script parses HTTP request using regular expressions
3. Parameters are URL-decoded and set as environment variables
4. Rscript is called to execute our R analysis script
5. R reads parameters using Sys.getenv() function
6. External curl program fetches URL content with timeout protection
7. R processes the content using statistical text analysis functions
8. Pattern matching determines if keyword exists in the content
9. Result is returned through the statistical computing pipeline

**Statistical Computing in Action**:
- Text processing using R's character manipulation functions
- File I/O operations for handling downloaded content
- Error handling through R's exception management system
- Vector operations for efficient data processing

Common Problems and Solutions
============================

Problem: "docker: command not found"
-----------------------------------

**Cause**: Docker is not installed on your system.

**Solution**: 
1. Visit https://docker.com/get-started
2. Download Docker Desktop for your operating system
3. Follow the installation instructions
4. Restart your computer
5. Try the docker command again

Problem: "Permission denied" when running Docker
-----------------------------------------------

**Cause**: Your user account doesn't have permission to use Docker.

**Linux Solution**:

.. code-block:: bash

   sudo usermod -aG docker $USER
   newgrp docker

**Windows/Mac Solution**: 
Make sure Docker Desktop is running and you're logged in.

Problem: "Port 31337 is already in use"
--------------------------------------

**Cause**: Another application or container is using port 31337.

**Solution 1** - Find and stop the conflicting process:

.. code-block:: bash

   docker ps | grep 31337
   docker stop <container-name>

**Solution 2** - Use a different port:

.. code-block:: bash

   docker run -d -p 32337:31337 --name test-r webwords-r
   curl "http://localhost:32337/?keyword=potato&target=https://www.remarkbox.com"

Problem: Container starts but doesn't respond
--------------------------------------------

**Cause**: R script might have encountered an execution error.

**Diagnosis**:

.. code-block:: bash

   docker logs test-r

**Look for**: Any R error messages or warnings

**Common Issues**:
- R package loading problems
- File permission issues
- Memory allocation errors

**Solution**: Check the logs for specific error messages and restart:

.. code-block:: bash

   docker restart test-r

Problem: "curl: command not found"
---------------------------------

**Cause**: curl is not installed on your system.

**Linux Solution**:

.. code-block:: bash

   sudo apt-get install curl

**Mac Solution**:

.. code-block:: bash

   brew install curl

**Windows Solution**: 
Use PowerShell instead of Command Prompt, or install curl from https://curl.se/

Problem: R Script Execution Errors
----------------------------------

**Symptoms**: Container runs but always returns "false" regardless of input

**Cause**: R script encountered an error that was silently handled

**Diagnosis**:

.. code-block:: bash

   docker exec -it test-r /bin/bash
   cd /app
   export KEYWORD="potato"
   export TARGET="https://www.remarkbox.com"
   Rscript app.R

**Look for**: R error messages or warnings

**Solution**: Common R issues include:
- File permission problems (ensure /tmp is writable)
- Missing R packages (our base image should include all needed packages)
- Network connectivity issues (curl should be available)

Statistical Computing Concepts
===============================

What Makes R Special for Data Analysis?
---------------------------------------

**Traditional Programming Languages**:
- Focus on general-purpose computing
- Manual implementation of statistical functions
- Complex syntax for data manipulation

**R Approach**:
- Everything is designed around data analysis
- Built-in statistical functions and tests
- Vectorized operations for efficiency
- Rich data structures for statistical work

**Example Comparison**:

.. code-block:: python

   # Python - manual statistical calculation
   def mean(data):
       return sum(data) / len(data)
   
   def standard_deviation(data):
       avg = mean(data)
       variance = sum((x - avg) ** 2 for x in data) / len(data)
       return variance ** 0.5

.. code-block:: r

   # R - built-in statistical functions
   data_mean <- mean(data)
   data_sd <- sd(data)

Data Structures in R
--------------------

R provides specialized data structures for statistical analysis:

**Vectors** - Basic building blocks:

.. code-block:: r

   numeric_vector <- c(1, 2, 3, 4, 5)
   character_vector <- c("apple", "banana", "cherry")
   logical_vector <- c(TRUE, FALSE, TRUE, FALSE)

**Matrices** - Two-dimensional arrays:

.. code-block:: r

   matrix_data <- matrix(1:12, nrow = 3, ncol = 4)
   correlation_matrix <- cor(dataset)

**Data Frames** - Like spreadsheets:

.. code-block:: r

   patient_data <- data.frame(
     patient_id = 1:100,
     age = rnorm(100, mean = 45, sd = 15),
     treatment = sample(c("A", "B"), 100, replace = TRUE)
   )

**Lists** - Containers for mixed data types:

.. code-block:: r

   analysis_results <- list(
     summary_stats = summary(data),
     test_results = t.test(group1, group2),
     plot_data = plot_object
   )

Statistical Functions
--------------------

R includes comprehensive statistical capabilities:

**Descriptive Statistics**:

.. code-block:: r

   data <- rnorm(1000, mean = 100, sd = 15)  # Generate sample data
   
   mean(data)                                # Average
   median(data)                              # Middle value
   sd(data)                                  # Standard deviation
   var(data)                                 # Variance
   quantile(data, c(0.25, 0.75))            # Quartiles
   summary(data)                             # Complete summary

**Hypothesis Testing**:

.. code-block:: r

   # Compare two groups
   group1 <- rnorm(50, mean = 100, sd = 15)
   group2 <- rnorm(50, mean = 105, sd = 15)
   
   t.test(group1, group2)                    # T-test
   wilcox.test(group1, group2)               # Non-parametric test

**Correlation and Regression**:

.. code-block:: r

   # Correlation analysis
   cor(x, y)                                 # Correlation coefficient
   cor.test(x, y)                            # Significance test
   
   # Linear regression
   model <- lm(y ~ x + z)                    # Linear model
   summary(model)                            # Model summary
   predict(model, new_data)                  # Predictions

Runtime Environment Details
===========================

R Package System
----------------

R's strength comes from its extensive package ecosystem:

**Base R**: Core functionality installed by default
- Data manipulation (data.frame operations)
- Basic statistics (mean, sd, cor, lm)
- Graphics (plot, hist, boxplot)
- Programming constructs (functions, loops, conditionals)

**CRAN Packages**: Over 18,000 specialized packages
- **dplyr**: Data manipulation and transformation
- **ggplot2**: Advanced data visualization
- **tidyr**: Data cleaning and reshaping
- **caret**: Machine learning and classification
- **forecast**: Time series analysis

**Package Installation** (in interactive R):

.. code-block:: r

   install.packages("package_name")  # Install from CRAN
   library(package_name)             # Load package for use

Memory Management
----------------

R uses automatic memory management but has unique characteristics:

**Copy-on-Write**: R creates copies of objects when modified
- Efficient for read-only operations
- Can use significant memory for large datasets
- Be aware when working with big data

**Garbage Collection**: Automatic cleanup of unused objects
- R periodically frees memory from deleted objects
- Can manually trigger with gc() function
- Monitor memory usage with object.size()

**Large Dataset Strategies**:
- Use data.table package for efficient large data handling
- Consider sampling for exploratory analysis
- Use databases for datasets larger than RAM

Rscript vs Interactive R
------------------------

Our implementation uses Rscript for command-line execution:

**Interactive R**:
- Start with ``R`` command
- Type commands and see immediate results
- Great for exploration and analysis
- Access to help system with ?function_name

**Rscript**:
- Run R scripts from command line
- Used in our web service implementation
- Non-interactive execution
- Suitable for automated processing

**Example**:

.. code-block:: bash

   # Interactive mode
   R
   > mean(c(1, 2, 3, 4, 5))
   [1] 3
   > quit()
   
   # Script mode
   echo 'cat(mean(c(1, 2, 3, 4, 5)))' > script.R
   Rscript script.R

Further Learning
===============

Next Steps with R and Statistical Computing
-------------------------------------------

1. **Learn Core R Syntax**:
   - Data types and structures
   - Control structures (if, for, while)
   - Function writing and debugging

2. **Explore Statistical Analysis**:
   - Descriptive statistics and data summarization
   - Hypothesis testing (t-tests, chi-square, ANOVA)
   - Correlation and regression analysis

3. **Practice with Real Data**:
   - Import data from CSV, Excel, databases
   - Clean and prepare data for analysis
   - Perform exploratory data analysis

4. **Advanced Topics**:
   - Machine learning with caret and randomForest
   - Data visualization with ggplot2
   - Time series analysis and forecasting
   - Reproducible research with R Markdown

Recommended Resources
--------------------

- **R for Data Science**: Free online book by Hadley Wickham
- **Coursera R Programming**: Johns Hopkins University course
- **RStudio**: Free IDE for R development
- **CRAN Task Views**: Curated lists of packages by topic
- **R-bloggers**: Community blog aggregator
- **Stack Overflow**: Q&A community with strong R presence

Statistical Computing Applications
----------------------------------

- **Academic Research**: Hypothesis testing, publication-quality analysis
- **Business Analytics**: Customer segmentation, market research, forecasting
- **Healthcare**: Clinical trial analysis, epidemiological studies, genomics
- **Finance**: Risk modeling, portfolio optimization, algorithmic trading
- **Government**: Survey analysis, policy research, economic modeling
- **Manufacturing**: Quality control, process optimization, predictive maintenance

This implementation demonstrates how R's statistical computing capabilities can be integrated into web services, showing the bridge between traditional statistical analysis and modern web applications. The combination of R's analytical power with HTTP interfaces opens possibilities for data-driven web services and APIs.