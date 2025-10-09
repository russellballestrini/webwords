FROM golang:1.19-alpine AS builder

WORKDIR /app
COPY go.mod .
COPY main.go .

RUN go build -o webwords main.go

FROM alpine:latest

RUN apk add --no-cache ca-certificates

COPY --from=builder /app/webwords /usr/local/bin/webwords

EXPOSE 31337

CMD ["webwords"]