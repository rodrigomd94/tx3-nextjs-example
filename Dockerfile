# Use the official Node.js image as base
FROM node:20-slim AS base

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    xz-utils \
    bash \
    && rm -rf /var/lib/apt/lists/*

# Install pnpm globally
RUN npm install -g pnpm

WORKDIR /app

# Development image
FROM base AS dev

# Set PATH to include default cargo and tx3 bin directories
ENV PATH="/root/.cargo/bin:/root/.tx3/stable/bin:$PATH"

# Install tx3up and trix
RUN curl --proto '=https' --tlsv1.2 -LsSf https://github.com/tx3-lang/up/releases/latest/download/tx3up-installer.sh | sh && \
    tx3up && \
    which trix || echo "trix not found in PATH after install"

# Copy package files
COPY package.json pnpm-lock.yaml* ./

# Install all dependencies (including dev dependencies for development)
RUN pnpm install --frozen-lockfile

# Copy source code and environment file
COPY . .

# Use Docker-specific trix configuration
RUN cp tx3/trix.docker.toml tx3/trix.toml

# Create the output directory for tx3 bindings
RUN mkdir -p node_modules/.tx3

# Set environment to development
ENV NODE_ENV=development

# Expose port
EXPOSE 3000

# Start the development server
CMD ["pnpm", "dev"]

# Production dependencies stage
FROM base AS prod-deps

# Copy package files
COPY package.json pnpm-lock.yaml* ./

# Install only production dependencies
RUN pnpm install --frozen-lockfile --prod

# Production build stage
FROM base AS builder

# Copy package files
COPY package.json pnpm-lock.yaml* ./

# Install all dependencies (needed for build)
RUN pnpm install --frozen-lockfile

# Copy source code and environment file
COPY . .

# Use Docker-specific trix configuration
RUN cp tx3/trix.docker.toml tx3/trix.toml

# Create the output directory for tx3 bindings
RUN mkdir -p node_modules/.tx3

# Set PATH to include default cargo and tx3 bin directories
ENV PATH="/root/.cargo/bin:/root/.tx3/stable/bin:$PATH"

# Install tx3up and trix for build
RUN curl --proto '=https' --tlsv1.2 -LsSf https://github.com/tx3-lang/up/releases/latest/download/tx3up-installer.sh | sh && \
    tx3up

# Build the application
RUN pnpm build

# Production runtime stage
FROM base AS runner

# Set PATH to include default cargo and tx3 bin directories
ENV PATH="/root/.cargo/bin:/root/.tx3/stable/bin:$PATH"

# Install tx3up and trix for runtime
RUN curl --proto '=https' --tlsv1.2 -LsSf https://github.com/tx3-lang/up/releases/latest/download/tx3up-installer.sh | sh && \
    tx3up

# Copy package.json for runtime
COPY package.json ./

# Copy production dependencies
COPY --from=prod-deps /app/node_modules ./node_modules

# Copy built application
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public

# Copy environment file
COPY --from=builder /app/.env ./.env

# Copy tx3 configuration and bindings
COPY --from=builder /app/tx3 ./tx3
COPY --from=builder /app/node_modules/.tx3 ./node_modules/.tx3

# Set environment to production
ENV NODE_ENV=production

# Expose port
EXPOSE 3000

# Start the production server
CMD ["pnpm", "start"]
