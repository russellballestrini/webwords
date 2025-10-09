#!/bin/bash

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
        printf "HTTP/1.1 404 Not Found\r\nContent-Length: 9\r\nConnection: close\r\n\r\nNot Found"
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
        echo "MATLAB wrapper: Processing keyword='$keyword', target='$target'" >&2
        
        # Fetch content using curl
        echo "MATLAB wrapper: Fetching content from $target" >&2
        content=$(curl -s --max-time 10 "$target" 2>/dev/null || echo "")
        
        if [[ -n "$content" ]]; then
            # Write inputs for MATLAB
            echo "$keyword" > /tmp/keyword.txt
            echo "$content" > /tmp/content.txt
            
            # Call actual MATLAB/Octave for keyword search
            echo "MATLAB wrapper: Calling Octave for processing..." >&2
            octave --silent /app/webwords.m 2>/dev/null
            
            # Read result from MATLAB
            if [[ -f /tmp/matlab_result.txt ]]; then
                found=$(cat /tmp/matlab_result.txt)
                echo "MATLAB wrapper: MATLAB returned result='$found'" >&2
            else
                echo "MATLAB wrapper: No result file from MATLAB" >&2
                found="false"
            fi
            
            # Clean up temporary files
            rm -f /tmp/keyword.txt /tmp/content.txt /tmp/matlab_result.txt
        else
            echo "MATLAB wrapper: Failed to fetch content" >&2
        fi
        
        echo "found=$found, keyword=$keyword, uri=$target (MATLAB processing)" >&2
    fi
    
    echo -e "HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\nContent-Length: ${#found}\r\nConnection: close\r\n\r\n$found"
else
    printf "HTTP/1.1 400 Bad Request\r\nContent-Length: 11\r\nConnection: close\r\n\r\nBad Request"
fi