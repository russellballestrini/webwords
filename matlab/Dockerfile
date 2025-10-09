FROM ubuntu:22.04

# Install Octave (open source MATLAB alternative) and required packages
RUN apt-get update && apt-get install -y \
    octave \
    curl \
    socat \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY webwords.m .
COPY request-handler.sh .

RUN chmod +x request-handler.sh

# Create simple HTTP server script
RUN echo '#!/bin/bash' > webwords.sh && \
    echo 'PORT=${PORT:-31337}' >> webwords.sh && \
    echo 'echo "listening on 0.0.0.0:$PORT (MATLAB/Octave processing)"' >> webwords.sh && \
    echo 'socat TCP-LISTEN:$PORT,reuseaddr,fork EXEC:./request-handler.sh' >> webwords.sh && \
    chmod +x webwords.sh

EXPOSE 31337

CMD ["./webwords.sh"]