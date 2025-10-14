# Pin to specific Alpine version (checked 2025-10-14: alpine:3.20 is latest stable)
FROM alpine:3.20

# Install C++ compiler and download cpp-httplib header
RUN apk --no-cache add g++ make wget ca-certificates openssl-dev

WORKDIR /app

# Download cpp-httplib header-only library
RUN wget -O httplib.h https://raw.githubusercontent.com/yhirose/cpp-httplib/v0.18.3/httplib.h

COPY webwords.cpp .
COPY Makefile .

# Compile the application
RUN make

EXPOSE 31337

CMD ["./webwords"]
