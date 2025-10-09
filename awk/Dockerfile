FROM alpine:latest

RUN apk add --no-cache gawk curl socat ca-certificates

WORKDIR /app
COPY webwords.awk .
COPY request-handler.sh .
RUN chmod +x webwords.awk request-handler.sh

# Create simple HTTP server script
RUN echo '#!/bin/sh' > webwords.sh && \
    echo 'PORT=${PORT:-31337}' >> webwords.sh && \
    echo 'echo "listening on 0.0.0.0:$PORT (AWK text processing)"' >> webwords.sh && \
    echo 'socat TCP-LISTEN:$PORT,reuseaddr,fork EXEC:./request-handler.sh' >> webwords.sh && \
    chmod +x webwords.sh

EXPOSE 31337

CMD ["./webwords.sh"]