FROM alpine:latest

ENTRYPOINT ["/bin/webwords"]

EXPOSE 8888

COPY . /go/src/webwords

RUN apk --no-cache add -t build-deps build-base go git \
    && apk --no-cache add ca-certificates \
    && cd /go/src/webwords \
    && export GOPATH=/go \
    && git config --global http.https://gopkg.in.followRedirects true \
    && go get \
    # optionally symbol/debug tables for smaller image.
    # && go build  -ldflags="-s -w" -o /bin/webwords \
    && go build -o /bin/webwords \
    && rm -rf /go \
    && apk del --purge build-deps \
    && rm -rf /var/cache/apk/*
