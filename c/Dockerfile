FROM alpine:latest

# Install C compiler and libcurl development libraries
RUN apk --no-cache add \
    gcc \
    musl-dev \
    curl-dev \
    make

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