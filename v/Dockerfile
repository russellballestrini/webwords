FROM thevlang/vlang:latest as builder

WORKDIR /app
COPY v.mod webwords.v ./
RUN v -prod webwords.v

FROM alpine:latest
RUN apk add --no-cache ca-certificates
COPY --from=builder /app/webwords /usr/local/bin/webwords

EXPOSE 31337

CMD ["webwords"]