#!/bin/bash

# SQLite WebWords request handler
# This script handles HTTP parsing and uses actual SQLite for keyword search

# Function to URL decode
urldecode() {
    local url_encoded="${1//+/ }"
    printf '%b' "${url_encoded//%/\\\\x}"
}

# Parse query parameters
parse_query() {
    local query="$1"
    local keyword=""
    local target=""
    
    IFS='&' read -ra PARAMS <<< "$query"
    for param in "${PARAMS[@]}"; do
        if [[ $param == keyword=* ]]; then
            keyword=$(urldecode "${param#keyword=}")
        elif [[ $param == target=* ]]; then
            target=$(urldecode "${param#target=}")
        fi
    done
    
    echo "$keyword|$target"
}

# Read HTTP request
read -r request_line
while IFS= read -r line; do
    line=${line%$'\r'}
    [[ -z "$line" ]] && break
done

# Parse HTTP request
if [[ $request_line =~ ^GET\ ([^\ ]+)\ HTTP ]]; then
    path_query="${BASH_REMATCH[1]}"
    path="${path_query%%\?*}"
    query="${path_query#*\?}"
    
    if [[ "$path" != "/" ]]; then
        echo -e "HTTP/1.1 404 Not Found\r\nContent-Length: 9\r\nConnection: close\r\n\r\nNot Found"
        exit
    fi
    
    if [[ "$path_query" == "$query" ]]; then
        query=""
    fi
    
    params=$(parse_query "$query")
    keyword="${params%%|*}"
    target="${params#*|}"
    found="false"
    
    if [[ -n "$keyword" && -n "$target" ]]; then
        echo "SQL wrapper: Processing keyword='$keyword', target='$target'" >&2
        
        # Fetch content using curl
        echo "SQL wrapper: Fetching content from $target" >&2
        content=$(curl -s --max-time 10 "$target" 2>/dev/null || echo "")
        
        if [[ -n "$content" ]]; then
            # Initialize SQLite database
            echo "SQL wrapper: Initializing SQLite database..." >&2
            sqlite3 /tmp/webwords.db < /app/webwords.sql 2>/dev/null
            
            # Use actual SQLite for keyword search
            echo "SQL wrapper: Performing SQL-based keyword search..." >&2
            
            # Simple direct SQL approach
            content_length=${#content}
            keyword_length=${#keyword}
            
            # Perform the search using SQLite's INSTR function
            # We'll use a simple test to check if SQLite can find the keyword
            sql_result=$(sqlite3 /tmp/webwords.db "SELECT 'true' WHERE INSTR(lower('${content//\'/\'\'}'), lower('${keyword//\'/\'\'}')) > 0 UNION SELECT 'false' WHERE INSTR(lower('${content//\'/\'\'}'), lower('${keyword//\'/\'\'}')) = 0;" 2>/dev/null | head -1)
            
            # Parse SQL result  
            if [[ -n "$sql_result" ]]; then
                found="$sql_result"
                echo "SQL wrapper: SQL query returned found='$found'" >&2
                echo "SQL wrapper: Content length: $content_length, Keyword length: $keyword_length" >&2
                
                # Additional SQL analysis if keyword was found
                if [[ "$found" == "true" ]]; then
                    echo "SQL wrapper: SQLite successfully found keyword '$keyword' using INSTR() function" >&2
                    
                    # Get the actual position using SQLite
                    position=$(sqlite3 /tmp/webwords.db "SELECT INSTR(lower('${content//\'/\'\'}'), lower('${keyword//\'/\'\'}'));" 2>/dev/null)
                    echo "SQL wrapper: First match position: $position" >&2
                else
                    echo "SQL wrapper: SQLite confirmed keyword '$keyword' not found in content" >&2
                fi
            else
                echo "SQL wrapper: SQL query failed" >&2
                found="false"
            fi
            
            # Clean up database
            rm -f /tmp/webwords.db
        else
            echo "SQL wrapper: Failed to fetch content" >&2
        fi
        
        echo "found=$found, keyword=$keyword, uri=$target (SQLite database processing)" >&2
    fi
    
    echo -e "HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\nContent-Length: ${#found}\r\nConnection: close\r\n\r\n$found"
else
    echo -e "HTTP/1.1 400 Bad Request\r\nContent-Length: 11\r\nConnection: close\r\n\r\nBad Request"
fi