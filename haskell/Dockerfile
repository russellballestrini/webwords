FROM haskell:9.2 as builder

WORKDIR /app
COPY webwords.cabal .
RUN cabal update && cabal build --only-dependencies

COPY Main.hs .
RUN cabal build
RUN cabal install --install-method=copy --installdir=/app

FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*
COPY --from=builder /app/webwords /usr/local/bin/webwords

EXPOSE 31337

CMD ["webwords"]