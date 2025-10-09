FROM openjdk:17-jdk-slim

WORKDIR /app

COPY WebWords.java .

RUN javac WebWords.java

EXPOSE 31337

CMD ["java", "WebWords"]