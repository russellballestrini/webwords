FROM alpine:latest

RUN apk add --no-cache lua5.3 lua5.3-socket lua5.3-dev luarocks5.3 build-base openssl-dev ca-certificates
RUN luarocks-5.3 install luasocket
RUN luarocks-5.3 install luasec

WORKDIR /app
COPY app.lua .

EXPOSE 31337

CMD ["lua5.3", "app.lua"]