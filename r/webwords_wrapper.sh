#!/bin/bash

# WebWords R wrapper script  
# This script handles HTTP parsing and calls R with file-based communication

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
        echo "R wrapper: Processing keyword='$keyword', target='$target'" >&2
        
        # Fetch content using curl
        echo "R wrapper: Fetching content from $target" >&2
        content=$(curl -s --max-time 10 "$target" 2>/dev/null || echo "")
        
        if [[ -n "$content" ]]; then
            # Write inputs for R
            echo "$keyword" > /tmp/keyword.txt
            echo "$content" > /tmp/content.txt
            
            # Call actual R script for statistical analysis
            echo "R wrapper: Calling R for statistical processing..." >&2
            Rscript /app/app.R 2>/dev/null
            
            # Read result from R
            if [[ -f /tmp/r_result.txt ]]; then
                found=$(cat /tmp/r_result.txt)
                echo "R wrapper: R returned result='$found'" >&2
            else
                echo "R wrapper: No result file from R" >&2
                found="false"
            fi
            
            # Clean up temporary files
            rm -f /tmp/keyword.txt /tmp/content.txt /tmp/r_result.txt
        else
            echo "R wrapper: Failed to fetch content" >&2
        fi
        
        echo "found=$found, keyword=$keyword, uri=$target (R statistical processing)" >&2
    fi
    
    echo -e "HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\nContent-Length: ${#found}\r\nConnection: close\r\n\r\n$found"
else
    echo -e "HTTP/1.1 400 Bad Request\r\nContent-Length: 11\r\nConnection: close\r\n\r\nBad Request"
fi