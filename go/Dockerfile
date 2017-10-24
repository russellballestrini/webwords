FROM alpine:3.5

ENTRYPOINT ["/bin/webwords"]

EXPOSE 8888

COPY . /go/src/webwords

RUN apk --no-cache add -t build-deps build-base go git \
    && apk --no-cache add ca-certificates \
    && cd /go/src/webwords \
    && export GOPATH=/go \
    && git config --global http.https://gopkg.in.followRedirects true \
    && go get \
    && go build -o /bin/webwords \
    && rm -rf /go \
    && apk del --purge build-deps
