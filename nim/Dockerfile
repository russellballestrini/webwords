FROM nimlang/nim:2.0.2-alpine as builder

WORKDIR /app
COPY webwords.nimble .
RUN nimble install -y --depsOnly

COPY src ./src
RUN nimble build -y -d:ssl

FROM alpine:latest
RUN apk add --no-cache ca-certificates
COPY --from=builder /app/webwords /usr/local/bin/webwords

EXPOSE 31337

CMD ["webwords"]