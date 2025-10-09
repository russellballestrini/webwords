#!/bin/bash

# Assembly WebWords request handler
# This script handles HTTP parsing and uses actual Assembly for string processing

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
        echo "Assembly wrapper: Processing keyword='$keyword', target='$target'" >&2
        
        # Fetch content using curl
        echo "Assembly wrapper: Fetching content from $target" >&2
        content=$(curl -s --max-time 10 "$target" 2>/dev/null || echo "")
        
        if [[ -n "$content" ]]; then
            # Write inputs for Assembly program
            echo "$keyword" > /tmp/asm_keyword.txt
            echo "$content" > /tmp/asm_content.txt
            
            # Call actual Assembly program for string processing
            echo "Assembly wrapper: Calling Assembly for low-level string processing..." >&2
            /app/webwords 2>/dev/null
            
            # Read result from Assembly
            if [[ -f /tmp/asm_result.txt ]]; then
                found=$(cat /tmp/asm_result.txt)
                echo "Assembly wrapper: Assembly returned result='$found'" >&2
            else
                echo "Assembly wrapper: No result file from Assembly" >&2
                found="false"
            fi
            
            # Clean up temporary files
            rm -f /tmp/asm_keyword.txt /tmp/asm_content.txt /tmp/asm_result.txt
        else
            echo "Assembly wrapper: Failed to fetch content" >&2
        fi
        
        echo "found=$found, keyword=$keyword, uri=$target (Assembly string processing)" >&2
    fi
    
    echo -e "HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\nContent-Length: ${#found}\r\nConnection: close\r\n\r\n$found"
else
    echo -e "HTTP/1.1 400 Bad Request\r\nContent-Length: 11\r\nConnection: close\r\n\r\nBad Request"
fi