FROM openjdk:11-jdk-slim as builder

# Install SBT
RUN apt-get update && apt-get install -y curl gnupg2 && \
    curl -L "https://github.com/sbt/sbt/releases/download/v1.7.1/sbt-1.7.1.tgz" | tar -xz -C /opt && \
    ln -s /opt/sbt/bin/sbt /usr/local/bin/sbt

WORKDIR /app
COPY build.sbt .
COPY project ./project
COPY src ./src
RUN sbt clean compile stage

FROM openjdk:11-jre-slim

WORKDIR /app
COPY --from=builder /app/target/universal/stage .

EXPOSE 31337

CMD ["bin/webwords"]