#!/bin/sh

# AWK WebWords request handler
# This script handles HTTP parsing and uses actual AWK for text processing

# Function to URL decode (sh-compatible)
urldecode() {
    # Simple URL decode for basic cases
    echo "$1" | sed 's/+/ /g; s/%20/ /g; s/%3A/:/g; s/%2F/\//g; s/%3F/?/g'
}

# Parse query parameters (sh-compatible)
parse_query() {
    query="$1"
    keyword=""
    target=""
    
    # Split by & and process each parameter
    echo "$query" | tr '&' '\n' | while read param; do
        case "$param" in
            keyword=*)
                k=$(echo "$param" | sed 's/keyword=//')
                k=$(urldecode "$k")
                echo "KEYWORD:$k" >> /tmp/params.tmp
                ;;
            target=*)
                t=$(echo "$param" | sed 's/target=//')
                t=$(urldecode "$t")
                echo "TARGET:$t" >> /tmp/params.tmp
                ;;
        esac
    done
    
    # Read back the results
    keyword=""
    target=""
    if [ -f /tmp/params.tmp ]; then
        while read line; do
            case "$line" in
                KEYWORD:*) keyword=$(echo "$line" | sed 's/KEYWORD://') ;;
                TARGET:*) target=$(echo "$line" | sed 's/TARGET://') ;;
            esac
        done < /tmp/params.tmp
        rm -f /tmp/params.tmp
    fi
    
    echo "$keyword|$target"
}

# Read HTTP request
read request_line
while IFS= read line; do
    line=$(echo "$line" | tr -d '\r')
    [ -z "$line" ] && break
done

# Parse HTTP request (sh-compatible)
if echo "$request_line" | grep -q "^GET"; then
    path_query=$(echo "$request_line" | sed 's/GET \([^ ]*\) HTTP.*/\1/')
    path=$(echo "$path_query" | sed 's/?.*$//')
    query=$(echo "$path_query" | sed 's/^[^?]*?//')
    
    if [ "$path" != "/" ]; then
        printf "HTTP/1.1 404 Not Found\r\nContent-Length: 9\r\nConnection: close\r\n\r\nNot Found"
        exit
    fi
    
    if [ "$path_query" = "$query" ]; then
        query=""
    fi
    
    params=$(parse_query "$query")
    keyword=$(echo "$params" | cut -d'|' -f1)
    target=$(echo "$params" | cut -d'|' -f2)
    found="false"
    
    if [ -n "$keyword" ] && [ -n "$target" ]; then
        echo "AWK wrapper: Processing keyword='$keyword', target='$target'" >&2
        
        # Fetch content using curl
        echo "AWK wrapper: Fetching content from $target" >&2
        content=$(curl -s --max-time 10 "$target" 2>/dev/null || echo "")
        
        if [ -n "$content" ]; then
            # Write inputs for AWK
            echo "$keyword" > /tmp/awk_keyword.txt
            echo "$content" > /tmp/awk_content.txt
            
            # Call actual AWK script for text processing
            echo "AWK wrapper: Calling AWK for advanced text processing..." >&2
            gawk -f /app/webwords.awk 2>/dev/null
            
            # Read result from AWK
            if [ -f /tmp/awk_result.txt ]; then
                found=$(cat /tmp/awk_result.txt)
                echo "AWK wrapper: AWK returned result='$found'" >&2
            else
                echo "AWK wrapper: No result file from AWK" >&2
                found="false"
            fi
            
            # Clean up temporary files
            rm -f /tmp/awk_keyword.txt /tmp/awk_content.txt /tmp/awk_result.txt
        else
            echo "AWK wrapper: Failed to fetch content" >&2
        fi
        
        echo "found=$found, keyword=$keyword, uri=$target (AWK text processing)" >&2
    fi
    
    printf "HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\nContent-Length: %d\r\nConnection: close\r\n\r\n%s" ${#found} "$found"
else
    printf "HTTP/1.1 400 Bad Request\r\nContent-Length: 11\r\nConnection: close\r\n\r\nBad Request"
fi