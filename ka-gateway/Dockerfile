# Stage 1: Build
FROM gradle:9.2.1-jdk25-alpine AS build
WORKDIR /app

COPY --chown=gradle:gradle . .
RUN gradle build --no-daemon -x test

# ==========================
# Stage 2: Runtime
# On utilise directement l'image officielle Temurin (Alpine pour la légèreté)
FROM eclipse-temurin:25-jdk-alpine
WORKDIR /app

# On installe curl ici uniquement si c'est nécessaire (ex: pour un healthcheck)
RUN apk add --no-cache curl

# On récupère le JAR du stage précédent
COPY --from=build /app/build/libs/*.jar ./app.jar

EXPOSE 5080

ENTRYPOINT ["java", "-jar", "app.jar"]