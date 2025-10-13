FROM alpine:latest

# Install build dependencies (simplified - using curl for HTTP client demo)
RUN apk --no-cache add \
    gcc \
    musl-dev \
    curl-dev \
    make

# Set working directory for our app
WORKDIR /app

# Copy source code
COPY webwords.c .
COPY Makefile .

# Build the application
RUN make

# Expose port 31337
EXPOSE 31337

# Run the webwords server
CMD ["./webwords"]