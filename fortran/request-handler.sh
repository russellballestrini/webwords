#!/bin/bash

# Fortran WebWords request handler
# This script handles HTTP parsing and uses actual Fortran for scientific string analysis

# Function to URL decode
urldecode() {
    local url_encoded="${1//+/ }"
    printf '%b' "${url_encoded//%/\\x}"
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
        echo "FORTRAN wrapper: Processing keyword='$keyword', target='$target'" >&2
        
        # Fetch content using curl
        echo "FORTRAN wrapper: Fetching content from $target" >&2
        content=$(curl -s --max-time 10 "$target" 2>/dev/null || echo "")
        
        if [[ -n "$content" ]]; then
            # Write inputs for Fortran program
            echo "$keyword" > /tmp/fortran_keyword.txt
            echo "$content" > /tmp/fortran_content.txt
            
            # Call actual Fortran program for scientific string analysis
            echo "FORTRAN wrapper: Calling Fortran for scientific string analysis..." >&2
            /app/webwords 2>/dev/null
            
            # Read result from Fortran
            if [[ -f /tmp/fortran_result.txt ]]; then
                found=$(cat /tmp/fortran_result.txt | tr -d ' ')
                echo "FORTRAN wrapper: Fortran returned result='$found'" >&2
            else
                echo "FORTRAN wrapper: No result file from Fortran" >&2
                found="false"
            fi
            
            # Clean up temporary files
            rm -f /tmp/fortran_keyword.txt /tmp/fortran_content.txt /tmp/fortran_result.txt
        else
            echo "FORTRAN wrapper: Failed to fetch content" >&2
        fi
        
        echo "found=$found, keyword=$keyword, uri=$target (Fortran scientific processing)" >&2
    fi
    
    echo -e "HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\nContent-Length: ${#found}\r\nConnection: close\r\n\r\n$found"
else
    echo -e "HTTP/1.1 400 Bad Request\r\nContent-Length: 11\r\nConnection: close\r\n\r\nBad Request"
fi