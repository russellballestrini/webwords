FROM openjdk:17-jdk-slim as builder

RUN apt-get update && apt-get install -y curl unzip && rm -rf /var/lib/apt/lists/*

# Install Gradle directly instead of using wrapper
RUN curl -L https://services.gradle.org/distributions/gradle-8.0-bin.zip -o gradle.zip && \
    unzip gradle.zip && \
    mv gradle-8.0 /opt/gradle && \
    rm gradle.zip

ENV PATH="/opt/gradle/bin:${PATH}"

WORKDIR /app
COPY build.gradle.kts ./
RUN gradle --version

COPY src ./src  
RUN gradle installDist --no-daemon
RUN ls -la build/install/

FROM openjdk:17-jdk-slim

WORKDIR /app
COPY --from=builder /app/build/install/app /app

EXPOSE 31337

CMD ["./bin/app"]