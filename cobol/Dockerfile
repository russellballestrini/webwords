FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y \
    gnucobol4 \
    socat \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY webwords.cob .
COPY request-handler.sh .

# Compile COBOL program
RUN cobc -x -o webwords webwords.cob

# Make scripts executable
RUN chmod +x webwords request-handler.sh

# Create simple HTTP server script
RUN echo '#!/bin/bash' > webwords.sh && \
    echo 'PORT=${PORT:-31337}' >> webwords.sh && \
    echo 'echo "listening on 0.0.0.0:$PORT (COBOL business processing)"' >> webwords.sh && \
    echo 'socat TCP-LISTEN:$PORT,reuseaddr,fork EXEC:./request-handler.sh' >> webwords.sh && \
    chmod +x webwords.sh

EXPOSE 31337

CMD ["./webwords.sh"]