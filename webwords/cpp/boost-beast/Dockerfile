# Pin to specific Alpine version (checked 2025-10-14: alpine:3.20 is latest stable)
FROM alpine:3.20

# Install C++ compiler and Boost libraries
RUN apk --no-cache add \
    g++ \
    make \
    boost1.84-dev

WORKDIR /app

COPY webwords.cpp .
COPY Makefile .

# Compile the application
RUN make

EXPOSE 31337

CMD ["./webwords"]
