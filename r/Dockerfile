FROM r-base:4.3.0

# Install curl and socat for HTTP/HTTPS requests and connection handling
RUN apt-get update && apt-get install -y \
    curl \
    socat \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY app.R .
COPY webwords_wrapper.sh .
RUN chmod +x webwords_wrapper.sh

EXPOSE 31337

# Create simple HTTP server script
RUN echo '#!/bin/bash' > webwords.sh && \
    echo 'PORT=${PORT:-31337}' >> webwords.sh && \
    echo 'echo "listening on 0.0.0.0:$PORT (R statistical processing)"' >> webwords.sh && \
    echo 'socat TCP-LISTEN:$PORT,reuseaddr,fork EXEC:./webwords_wrapper.sh' >> webwords.sh && \
    chmod +x webwords.sh

CMD ["./webwords.sh"]