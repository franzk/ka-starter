# === Dockerfile for FRONT (Vue.js + Nginx) ===

FROM node:24-slim AS build
WORKDIR /app

# Install pnpm
RUN corepack enable && corepack prepare pnpm@latest --activate

# Install dependencies
COPY package*.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile

# Copy source files and build the application
COPY . .
RUN pnpm run build

# Use Nginx to serve the built application
FROM nginx:1.27-alpine-slim

# On installe envsubst (souvent déjà présent dans alpine-slim, mais par sécurité)
RUN apk add --no-cache gettext

# Copy built files from the build stage
COPY --from=build /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Le dossier de travail pour Nginx
WORKDIR /usr/share/nginx/html

EXPOSE 80
ENTRYPOINT ["/entrypoint.sh"]
