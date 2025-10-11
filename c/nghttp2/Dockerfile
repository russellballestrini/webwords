FROM alpine:latest

# Install build dependencies and nghttp2
RUN apk --no-cache add \
    gcc \
    musl-dev \
    make \
    pkgconfig \
    nghttp2-dev \
    openssl-dev \
    zlib-dev \
    curl

# Set working directory
WORKDIR /app

# Copy source code
COPY webwords.c .
COPY Makefile .

# Compile the application
RUN make

# Expose port 31337
EXPOSE 31337

# Run the webwords server
CMD ["./webwords"]