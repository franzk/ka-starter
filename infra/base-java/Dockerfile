# This Dockerfile is used to create a base image for Java applications
# example: 
# FROM ka-base-java:latest
# COPY target/myapp.jar /app.jar
# ENTRYPOINT ["java", "-jar", "/app.jar"]

FROM eclipse-temurin:25-jdk

# Install necessary utilities
RUN apt-get update && apt-get install -y \
    ca-certificates curl \
    && rm -rf /var/lib/apt/lists/*