FROM swift:6.1.3 AS builder

WORKDIR /app
COPY Package.swift .
COPY Sources ./Sources
RUN swift build -c release

FROM swift:6.1.3-noble-slim
RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*
COPY --from=builder /app/.build/release/WebWords /usr/local/bin/webwords

EXPOSE 31337

CMD ["webwords"]