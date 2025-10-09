FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    g++ \
    libcurl4-openssl-dev \
    libmicrohttpd-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY main.cpp .

RUN g++ -o webwords main.cpp -lcurl -lmicrohttpd

EXPOSE 31337

CMD ["./webwords"]