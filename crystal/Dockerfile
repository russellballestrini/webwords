FROM crystallang/crystal:1.14.0 as builder

WORKDIR /app
COPY shard.yml ./
RUN shards install

COPY src ./src
RUN crystal build --release --static src/webwords.cr

FROM alpine:latest
RUN apk add --no-cache ca-certificates openssl-dev
ENV SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt
ENV SSL_CERT_DIR=/etc/ssl/certs
COPY --from=builder /app/webwords /usr/local/bin/webwords

EXPOSE 31337

CMD ["webwords"]