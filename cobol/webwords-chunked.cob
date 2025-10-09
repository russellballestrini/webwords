       IDENTIFICATION DIVISION.
       PROGRAM-ID. WEBWORDS-CHUNKED.
       AUTHOR. COBOL-WEBWORDS-SYSTEM.
       DATE-WRITTEN. 2025-10-09.
       
      *> COBOL WebWords Chunked Processing Implementation
      *> Demonstrates COBOL's record-oriented processing capabilities
       
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
       01 WS-KEYWORD-LENGTH PIC 9(8) COMP.
       
      *> COBOL chunked processing fields  
       01 WS-SEARCH-RESULT PIC X(5) VALUE "false".
       01 WS-TOTAL-MATCH-COUNTER PIC 9(8) COMP VALUE ZERO.
       01 WS-CHUNK-MATCH-COUNTER PIC 9(8) COMP VALUE ZERO.
       01 WS-CHUNKS-PROCESSED PIC 9(8) COMP VALUE ZERO.
       01 WS-TOTAL-CHARS-PROCESSED PIC 9(8) COMP VALUE ZERO.
       
      *> String processing work areas
       01 WS-UPPERCASE-KEYWORD PIC X(256).
       01 WS-UPPERCASE-CHUNK PIC X(1024).
       01 WS-CURRENT-CHUNK PIC X(1024).
       
      *> File processing indicators
       01 WS-EOF-KEYWORD PIC X VALUE 'N'.
       01 WS-EOF-CONTENT PIC X VALUE 'N'.
       
       PROCEDURE DIVISION.
       
      *> Main chunked processing procedure
       0000-MAIN-PROCESS.
           DISPLAY "COBOL: Starting chunked business processing..." 
               UPON STDERR.
           PERFORM 1000-READ-KEYWORD-DATA.
           PERFORM 2000-PROCESS-CONTENT-CHUNKS.
           PERFORM 3000-WRITE-FINAL-RESULT.
           PERFORM 9000-BUSINESS-ANALYSIS-REPORT.
           STOP RUN.
       
      *> Read search keyword
       1000-READ-KEYWORD-DATA.
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
           
      *> Convert keyword to uppercase for case-insensitive search
           MOVE WS-SEARCH-KEYWORD TO WS-UPPERCASE-KEYWORD.
           INSPECT WS-UPPERCASE-KEYWORD CONVERTING
               "abcdefghijklmnopqrstuvwxyz" TO
               "ABCDEFGHIJKLMNOPQRSTUVWXYZ".
               
           DISPLAY "COBOL: Keyword loaded for chunked search: " 
               WS-SEARCH-KEYWORD(1:WS-KEYWORD-LENGTH) UPON STDERR.
               
      *> Process content file chunk by chunk - authentic COBOL approach
       2000-PROCESS-CONTENT-CHUNKS.
           OPEN INPUT CONTENT-INPUT-FILE.
           
           PERFORM UNTIL WS-EOF-CONTENT = 'Y'
               READ CONTENT-INPUT-FILE INTO WS-CURRENT-CHUNK
                   AT END MOVE 'Y' TO WS-EOF-CONTENT
                   NOT AT END PERFORM 2100-SEARCH-CURRENT-CHUNK
               END-READ
           END-PERFORM.
           
           CLOSE CONTENT-INPUT-FILE.
           
      *> Search within current chunk using COBOL string processing
       2100-SEARCH-CURRENT-CHUNK.
           ADD 1 TO WS-CHUNKS-PROCESSED.
           MOVE ZERO TO WS-CHUNK-MATCH-COUNTER.
           
      *> Clean chunk data (remove newlines)
           INSPECT WS-CURRENT-CHUNK REPLACING ALL X'0A' BY SPACE.
           INSPECT WS-CURRENT-CHUNK REPLACING ALL X'0D' BY SPACE.
           
      *> Convert chunk to uppercase for case-insensitive search
           MOVE WS-CURRENT-CHUNK TO WS-UPPERCASE-CHUNK.
           INSPECT WS-UPPERCASE-CHUNK CONVERTING
               "abcdefghijklmnopqrstuvwxyz" TO
               "ABCDEFGHIJKLMNOPQRSTUVWXYZ".
           
      *> Perform COBOL string search using INSPECT verb on this chunk
           INSPECT WS-UPPERCASE-CHUNK TALLYING WS-CHUNK-MATCH-COUNTER
               FOR ALL WS-UPPERCASE-KEYWORD(1:WS-KEYWORD-LENGTH).
           
      *> Accumulate matches across all chunks
           ADD WS-CHUNK-MATCH-COUNTER TO WS-TOTAL-MATCH-COUNTER.
           
      *> Track total characters processed
           ADD LENGTH OF WS-CURRENT-CHUNK TO WS-TOTAL-CHARS-PROCESSED.
           
      *> Log chunk processing results
           IF WS-CHUNK-MATCH-COUNTER > ZERO THEN
               DISPLAY "COBOL: Chunk #" WS-CHUNKS-PROCESSED 
                   " - Found " WS-CHUNK-MATCH-COUNTER " matches" 
                   UPON STDERR
           END-IF.
           
      *> Generate final result based on all processed chunks
       3000-WRITE-FINAL-RESULT.
           IF WS-TOTAL-MATCH-COUNTER > ZERO THEN
               MOVE "true" TO WS-SEARCH-RESULT
               DISPLAY "COBOL: KEYWORD FOUND using chunked processing!" 
                   UPON STDERR
           ELSE
               MOVE "false" TO WS-SEARCH-RESULT
               DISPLAY "COBOL: Keyword NOT FOUND after chunked analysis" 
                   UPON STDERR
           END-IF.
           
           OPEN OUTPUT RESULT-OUTPUT-FILE.
           MOVE WS-SEARCH-RESULT TO RESULT-OUTPUT-RECORD.
           WRITE RESULT-OUTPUT-RECORD.
           CLOSE RESULT-OUTPUT-FILE.
           
      *> Business analysis report for chunked processing
       9000-BUSINESS-ANALYSIS-REPORT.
           DISPLAY "COBOL Chunked Processing Analysis Report" UPON STDERR.
           DISPLAY "  Processing Statistics" UPON STDERR.
           DISPLAY "    Total Chunks Processed: " WS-CHUNKS-PROCESSED 
               UPON STDERR.
           DISPLAY "    Total Characters: " WS-TOTAL-CHARS-PROCESSED 
               UPON STDERR.
           DISPLAY "    Search Keyword: " 
               WS-SEARCH-KEYWORD(1:WS-KEYWORD-LENGTH) UPON STDERR.
           DISPLAY "    Keyword Length: " WS-KEYWORD-LENGTH UPON STDERR.
           DISPLAY "  Search Results Across All Chunks" UPON STDERR.
           DISPLAY "    Total Matches Found: " WS-TOTAL-MATCH-COUNTER 
               UPON STDERR.
           DISPLAY "    Final Result: " WS-SEARCH-RESULT UPON STDERR.
           DISPLAY "COBOL: Chunked business processing complete" 
               UPON STDERR.