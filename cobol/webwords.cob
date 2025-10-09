       IDENTIFICATION DIVISION.
       PROGRAM-ID. WEBWORDS.
       AUTHOR. COBOL-WEBWORDS-SYSTEM.
       DATE-WRITTEN. 2025-10-09.
       
      *> COBOL WebWords String Processing Implementation
      *> Demonstrates COBOL's business-oriented string handling capabilities
       
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT KEYWORD-INPUT-FILE ASSIGN TO "/tmp/cobol_keyword.txt"
           ORGANIZATION IS SEQUENTIAL
           ACCESS MODE IS SEQUENTIAL.
           
           SELECT CONTENT-INPUT-FILE ASSIGN TO "/tmp/cobol_content.txt"
           ORGANIZATION IS SEQUENTIAL
           ACCESS MODE IS SEQUENTIAL.
           
           SELECT RESULT-OUTPUT-FILE ASSIGN TO "/tmp/cobol_result.txt"
           ORGANIZATION IS SEQUENTIAL
           ACCESS MODE IS SEQUENTIAL.
       
       DATA DIVISION.
       FILE SECTION.
       FD KEYWORD-INPUT-FILE.
       01 KEYWORD-INPUT-RECORD PIC X(256).
       
       FD CONTENT-INPUT-FILE.
       01 CONTENT-INPUT-RECORD PIC X(1024).
       
       FD RESULT-OUTPUT-FILE.
       01 RESULT-OUTPUT-RECORD PIC X(10).
       
       WORKING-STORAGE SECTION.
      *> Input data fields
       01 WS-SEARCH-KEYWORD PIC X(256).
       01 WS-CONTENT-TEXT PIC X(65536).
       01 WS-CONTENT-LENGTH PIC 9(8) COMP.
       01 WS-KEYWORD-LENGTH PIC 9(8) COMP.
       
      *> COBOL business logic fields  
       01 WS-SEARCH-RESULT PIC X(5) VALUE "false".
       01 WS-MATCH-COUNTER PIC 9(8) COMP VALUE ZERO.
       01 WS-POSITION-FOUND PIC 9(8) COMP VALUE ZERO.
       01 WS-SEARCH-POSITION PIC 9(8) COMP VALUE 1.
       
      *> String processing work areas
       01 WS-UPPERCASE-KEYWORD PIC X(256).
       01 WS-UPPERCASE-CONTENT PIC X(65536).
       01 WS-TEMP-CONTENT PIC X(65536).
       01 WS-CONTENT-SEGMENT PIC X(1024).
       
      *> Business analysis fields
       01 WS-TOTAL-CHARS PIC 9(8) COMP VALUE ZERO.
       01 WS-TOTAL-WORDS PIC 9(8) COMP VALUE ZERO.
       01 WS-MATCH-DENSITY PIC 9(3)V9(4) COMP-3 VALUE ZERO.
       
      *> File processing indicators
       01 WS-EOF-KEYWORD PIC X VALUE 'N'.
       01 WS-EOF-CONTENT PIC X VALUE 'N'.
       01 WS-FILE-STATUS PIC XX.
       
      *> Display messages for logging
       01 WS-START-MSG PIC X(60) VALUE 
           "COBOL: Starting business-style string processing...".
       01 WS-FOUND-MSG PIC X(80) VALUE
           "COBOL: Keyword FOUND using COBOL string processing verbs!".
       01 WS-NOT-FOUND-MSG PIC X(70) VALUE
           "COBOL: Keyword NOT FOUND after COBOL business analysis".
       
       PROCEDURE DIVISION.
       
      *> Main business process
       0000-MAIN-PROCESS.
           DISPLAY WS-START-MSG UPON STDERR.
           PERFORM 1000-READ-INPUT-DATA.
           PERFORM 2000-PROCESS-STRING-SEARCH.
           PERFORM 3000-WRITE-RESULT.
           PERFORM 9000-BUSINESS-ANALYSIS-REPORT.
           STOP RUN.
       
      *> Read input files using COBOL file handling
       1000-READ-INPUT-DATA.
           PERFORM 1100-READ-KEYWORD-FILE.
           PERFORM 1200-READ-CONTENT-FILE.
           
       1100-READ-KEYWORD-FILE.
           OPEN INPUT KEYWORD-INPUT-FILE.
           READ KEYWORD-INPUT-FILE INTO WS-SEARCH-KEYWORD
               AT END MOVE 'Y' TO WS-EOF-KEYWORD.
           CLOSE KEYWORD-INPUT-FILE.
           
      *> Remove newline characters from keyword
           INSPECT WS-SEARCH-KEYWORD REPLACING ALL X'0A' BY SPACE.
           INSPECT WS-SEARCH-KEYWORD REPLACING ALL X'0D' BY SPACE.
           
      *> Calculate keyword length using COBOL INSPECT  
           MOVE ZERO TO WS-KEYWORD-LENGTH.
           INSPECT WS-SEARCH-KEYWORD TALLYING WS-KEYWORD-LENGTH
               FOR CHARACTERS BEFORE INITIAL SPACE.
           
       1200-READ-CONTENT-FILE.
           MOVE SPACES TO WS-CONTENT-TEXT.
           MOVE ZERO TO WS-CONTENT-LENGTH.
           
           OPEN INPUT CONTENT-INPUT-FILE.
           READ CONTENT-INPUT-FILE INTO WS-CONTENT-TEXT
               AT END MOVE 'Y' TO WS-EOF-CONTENT.
           CLOSE CONTENT-INPUT-FILE.
           
      *> Remove newlines from content and calculate length
           INSPECT WS-CONTENT-TEXT REPLACING ALL X'0A' BY SPACE.
           INSPECT WS-CONTENT-TEXT REPLACING ALL X'0D' BY SPACE.
           
      *> Count actual content length
           INSPECT WS-CONTENT-TEXT TALLYING WS-CONTENT-LENGTH
               FOR CHARACTERS BEFORE INITIAL LOW-VALUE.
               
       2000-PROCESS-STRING-SEARCH.
      *> Convert to uppercase for case-insensitive search using INSPECT
           MOVE WS-SEARCH-KEYWORD TO WS-UPPERCASE-KEYWORD.
           MOVE WS-CONTENT-TEXT TO WS-UPPERCASE-CONTENT.
           
           INSPECT WS-UPPERCASE-KEYWORD CONVERTING 
               "abcdefghijklmnopqrstuvwxyz" TO
               "ABCDEFGHIJKLMNOPQRSTUVWXYZ".
               
           INSPECT WS-UPPERCASE-CONTENT CONVERTING
               "abcdefghijklmnopqrstuvwxyz" TO  
               "ABCDEFGHIJKLMNOPQRSTUVWXYZ".
           
      *> Perform COBOL string search using INSPECT verb
           INSPECT WS-UPPERCASE-CONTENT TALLYING WS-MATCH-COUNTER
               FOR ALL WS-UPPERCASE-KEYWORD(1:WS-KEYWORD-LENGTH).
           
      *> Business logic: determine result
           IF WS-MATCH-COUNTER > ZERO THEN
               MOVE "true" TO WS-SEARCH-RESULT
               DISPLAY WS-FOUND-MSG UPON STDERR
           ELSE
               MOVE "false" TO WS-SEARCH-RESULT  
               DISPLAY WS-NOT-FOUND-MSG UPON STDERR
           END-IF.
           
       3000-WRITE-RESULT.
           OPEN OUTPUT RESULT-OUTPUT-FILE.
           MOVE WS-SEARCH-RESULT TO RESULT-OUTPUT-RECORD.
           WRITE RESULT-OUTPUT-RECORD.
           CLOSE RESULT-OUTPUT-FILE.
           
       9000-BUSINESS-ANALYSIS-REPORT.
      *> COBOL business reporting - calculate metrics
           IF WS-CONTENT-LENGTH > ZERO THEN
               COMPUTE WS-MATCH-DENSITY = 
                   (WS-MATCH-COUNTER * 100) / WS-CONTENT-LENGTH
           END-IF.
           
      *> Count words using COBOL INSPECT
           INSPECT WS-CONTENT-TEXT TALLYING WS-TOTAL-WORDS
               FOR ALL SPACE.
           ADD 1 TO WS-TOTAL-WORDS.
           
      *> Display business analysis using COBOL formatting
           DISPLAY "COBOL Business Analysis Report:" UPON STDERR.
           DISPLAY "  Document Statistics:" UPON STDERR.
           DISPLAY "    Total Characters: " WS-CONTENT-LENGTH 
               UPON STDERR.
           DISPLAY "    Total Words: " WS-TOTAL-WORDS UPON STDERR.
           DISPLAY "    Keyword Length: " WS-KEYWORD-LENGTH 
               UPON STDERR.
           DISPLAY "  Search Results:" UPON STDERR.
           DISPLAY "    Search Keyword: " 
               WS-SEARCH-KEYWORD(1:WS-KEYWORD-LENGTH) UPON STDERR.
           DISPLAY "    Matches Found: " WS-MATCH-COUNTER UPON STDERR.
           DISPLAY "    Match Density: " WS-MATCH-DENSITY "%" 
               UPON STDERR.
           DISPLAY "    Final Result: " WS-SEARCH-RESULT UPON STDERR.
           DISPLAY "COBOL: Business processing complete" UPON STDERR.