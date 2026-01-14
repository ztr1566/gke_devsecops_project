# Stage 1: Build the application
FROM maven:3.9.6-eclipse-temurin-17 AS builder
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

# Stage 2: Create the final lightweight image
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
RUN addgroup -S demo && adduser -S demo -G demo
USER demo
COPY --from=builder /app/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]