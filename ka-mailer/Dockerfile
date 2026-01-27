FROM gradle:9.2.1-jdk25-alpine AS build
WORKDIR /app

COPY --chown=gradle:gradle . .
RUN gradle build --no-daemon -x test

# ==========================
FROM ka-base-java:latest
WORKDIR /app

# Copy the built JAR file from the build stage
COPY --from=build /app/build/libs/*.jar ./app.jar

EXPOSE 5030

ENTRYPOINT ["java", "-jar", "app.jar"]