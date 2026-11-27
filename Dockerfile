# ---- Build stage ----
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /build
COPY app/pom.xml .
RUN mvn -B -q dependency:go-offline
COPY app/src ./src
RUN mvn -B -q package -DskipTests

# ---- Runtime stage: slim JRE, non-root user ----
FROM eclipse-temurin:17-jre-alpine
RUN addgroup -S app && adduser -S -G app -u 10001 app
WORKDIR /app
COPY --from=build /build/target/app.jar app.jar
USER 10001
EXPOSE 8080
ENTRYPOINT ["java", "-XX:MaxRAMPercentage=75", "-jar", "/app/app.jar"]
