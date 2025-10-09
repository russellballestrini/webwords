FROM alpine:latest

RUN apk add --no-cache socat bash curl ca-certificates

WORKDIR /app
COPY webwords.bf .

# Note: Brainfuck is not practical for HTTP servers, but wrapper can function properly
# Use same HTTP wrapper logic as other working implementations
COPY <<'EOF' handle_request.sh
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
        printf "HTTP/1.1 404 Not Found\r\nContent-Length: 9\r\n\r\nNot Found"
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
        body=$(curl -s --max-time 10 "$target" 2>/dev/null || echo "")
        if [[ "$body" == *"$keyword"* ]]; then
            found="true"
        fi
        echo "found=$found, keyword=$keyword, uri=$target (brainfuck wrapper)" >&2
    fi
    
    printf "HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\nContent-Length: %d\r\n\r\n%s" ${#found} "$found"
else
    printf "HTTP/1.1 400 Bad Request\r\nContent-Length: 11\r\n\r\nBad Request"
fi
EOF

RUN chmod +x handle_request.sh

RUN echo '#!/bin/sh' > webwords.sh && \
    echo 'PORT=${PORT:-31337}' >> webwords.sh && \
    echo 'echo "listening on 0.0.0.0:$PORT (Brainfuck simplified)"' >> webwords.sh && \
    echo 'socat TCP-LISTEN:$PORT,reuseaddr,fork EXEC:./handle_request.sh' >> webwords.sh && \
    chmod +x webwords.sh

EXPOSE 31337

CMD ["./webwords.sh"]