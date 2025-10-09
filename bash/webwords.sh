#!/bin/bash

# Function to URL decode
urldecode() {
    local url_encoded="${1//+/ }"
    printf '%b' "${url_encoded//%/\\x}"
}

# Function to parse query parameters
parse_query() {
    local query="$1"
    local keyword=""
    local target=""
    
    # Split query by &
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

# Function to fetch URL content
fetch_url() {
    local url="$1"
    curl -s --max-time 10 "$url" 2>/dev/null || echo ""
}

# Function to handle HTTP request
handle_request() {
    local request_line="$1"
    
    # Parse HTTP request line
    if [[ $request_line =~ ^GET\ ([^\ ]+)\ HTTP ]]; then
        local path_query="${BASH_REMATCH[1]}"
        local path="${path_query%%\?*}"
        local query="${path_query#*\?}"
        
        if [[ "$path" != "/" ]]; then
            echo -e "HTTP/1.1 404 Not Found\r\nContent-Length: 9\r\n\r\nNot Found"
            return
        fi
        
        if [[ "$path_query" == "$query" ]]; then
            query=""
        fi
        
        local params=$(parse_query "$query")
        local keyword="${params%%|*}"
        local target="${params#*|}"
        local found="false"
        
        if [[ -n "$keyword" && -n "$target" ]]; then
            local body=$(fetch_url "$target")
            if [[ "$body" == *"$keyword"* ]]; then
                found="true"
            fi
            echo "found=$found, keyword=$keyword, uri=$target" >&2
        fi
        
        local content_length=${#found}
        echo -e "HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\nContent-Length: $content_length\r\n\r\n$found"
    else
        echo -e "HTTP/1.1 400 Bad Request\r\nContent-Length: 11\r\n\r\nBad Request"
    fi
}

# HTTP request handler script for socat
handle_http() {
    # Read the HTTP request line
    read -r request_line
    echo "Received: [$request_line]" >&2
    
    # Read and discard HTTP headers
    while IFS= read -r line; do
        line=${line%$'\r'}  # Remove carriage return
        [[ -z "$line" ]] && break
    done
    
    # Handle the request and send response
    handle_request "$request_line"
}

# Export the function so socat can use it
export -f handle_http
export -f handle_request
export -f parse_query
export -f urldecode
export -f fetch_url

# Main server loop using socat
echo "listening on 0.0.0.0:31337" >&2

socat TCP-LISTEN:31337,reuseaddr,fork SYSTEM:'bash -c handle_http' 2>/dev/null