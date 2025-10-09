FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    nasm \
    binutils \
    socat \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY webwords.asm .
COPY request-handler.sh .

# Assemble the Assembly program
RUN nasm -f elf64 webwords.asm -o webwords.o && \
    ld webwords.o -o webwords && \
    chmod +x webwords request-handler.sh

# Create simple HTTP server script
RUN echo '#!/bin/bash' > webwords.sh && \
    echo 'PORT=${PORT:-31337}' >> webwords.sh && \
    echo 'echo "listening on 0.0.0.0:$PORT (Assembly string processing)"' >> webwords.sh && \
    echo 'socat TCP-LISTEN:$PORT,reuseaddr,fork EXEC:./request-handler.sh' >> webwords.sh && \
    chmod +x webwords.sh

EXPOSE 31337

CMD ["./webwords.sh"]