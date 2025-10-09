FROM alpine:latest AS builder

RUN apk add --no-cache curl tar xz && \
    curl -L https://ziglang.org/download/0.13.0/zig-linux-x86_64-0.13.0.tar.xz | tar -xJ && \
    mv zig-linux-x86_64-0.13.0 /opt/zig

WORKDIR /app
COPY . .
RUN /opt/zig/zig build -Doptimize=ReleaseSafe

FROM alpine:latest
RUN apk add --no-cache ca-certificates
COPY --from=builder /app/zig-out/bin/webwords /usr/local/bin/webwords

EXPOSE 31337

CMD ["webwords"]