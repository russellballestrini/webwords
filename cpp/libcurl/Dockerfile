FROM alpine:3.20

RUN apk --no-cache add \
    g++ \
    make \
    curl-dev \
    libmicrohttpd-dev

WORKDIR /app
COPY webwords.cpp .
COPY Makefile .

RUN make

EXPOSE 31337

CMD ["./webwords"]