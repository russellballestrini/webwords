FROM clojure:openjdk-11-lein as builder

WORKDIR /app
COPY project.clj .
RUN lein deps

COPY src ./src
RUN lein uberjar

FROM openjdk:11-jre-slim

WORKDIR /app
COPY --from=builder /app/target/uberjar/webwords-*-standalone.jar webwords.jar

EXPOSE 31337

CMD ["java", "-jar", "webwords.jar"]