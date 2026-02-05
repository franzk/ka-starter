FROM node:24-slim

# Install pnpm
RUN corepack enable && corepack prepare pnpm@latest --activate

WORKDIR /app

# Copy package.json and pnpm-lock.yaml first to leverage Docker cache
COPY package.json pnpm-lock.yaml ./

# Install dependencies
RUN pnpm install --frozen-lockfile

# Copy the rest of the application code
COPY . .

EXPOSE 1025

CMD ["pnpm", "start"]