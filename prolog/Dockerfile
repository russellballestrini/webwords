FROM swipl:latest

WORKDIR /app
COPY webwords.pl .

# Install curl for HTTP requests
RUN apt-get update && apt-get install -y curl ca-certificates && rm -rf /var/lib/apt/lists/*

EXPOSE 31337

CMD ["swipl", "-s", "webwords.pl", "-g", "main", "-t", "halt"]