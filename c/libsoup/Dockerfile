FROM alpine:3.20

# Install C compiler and libsoup development libraries
RUN apk --no-cache add \
    gcc \
    musl-dev \
    libsoup-dev \
    glib-dev \
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