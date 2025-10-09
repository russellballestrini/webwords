FROM ubuntu:22.04 as builder

RUN apt-get update && apt-get install -y wget build-essential clang && \
    wget -O odin.tar.gz https://github.com/odin-lang/Odin/releases/download/dev-2025-10/odin-linux-amd64-dev-2025-10-05.tar.gz && \
    tar -xf odin.tar.gz && \
    mv odin-linux-amd64-nightly+2025-10-05 /opt/odin && \
    ln -s /opt/odin/odin /usr/local/bin/odin

ENV ODIN_ROOT=/opt/odin

WORKDIR /app
COPY webwords.odin .
RUN odin build webwords.odin -file -out:webwords

FROM ubuntu:22.04
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*
COPY --from=builder /app/webwords /usr/local/bin/webwords

EXPOSE 31337

CMD ["webwords"]