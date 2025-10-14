FROM alpine:3.20

RUN apk add --no-cache bash curl socat ca-certificates

WORKDIR /app
COPY webwords.sh .
RUN chmod +x webwords.sh

EXPOSE 31337

CMD ["./webwords.sh"]