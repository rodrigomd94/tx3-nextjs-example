# Use the official Node.js image as base
FROM node:20-slim AS base

# Install dependencies only when needed
FROM base AS deps
RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    xz-utils \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install pnpm
RUN npm install -g pnpm

# Copy package files
COPY package.json pnpm-lock.yaml* ./

# Install dependencies
RUN pnpm install --frozen-lockfile

# Development image
FROM base AS dev
RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    bash \
    xz-utils \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install pnpm
RUN npm install -g pnpm

# Install tx3up and trix
RUN curl --proto '=https' --tlsv1.2 -LsSf https://github.com/tx3-lang/up/releases/latest/download/tx3up-installer.sh | sh && \
    source $HOME/.cargo/env && \
    tx3up
# Add cargo and tx3 tools to PATH
ENV PATH="/root/.cargo/bin:/root/.tx3/bin:$PATH"

# Copy node_modules from deps stage
COPY --from=deps /app/node_modules ./node_modules

# Copy source code
COPY . .

# Use Docker-specific trix configuration
RUN cp tx3/trix.docker.toml tx3/trix.toml

# Create the output directory for tx3 bindings
RUN mkdir -p node_modules/.tx3

# Set environment to development
ENV NODE_ENV=development

# Start the development server
CMD ["pnpm", "dev"]

# Production image
FROM base AS runner
RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    xz-utils \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install pnpm
RUN npm install -g pnpm

# Install tx3up and trix for production builds
RUN curl --proto '=https' --tlsv1.2 -LsSf https://github.com/tx3-lang/up/releases/latest/download/tx3up-installer.sh | sh && \
    /root/.tx3/bin/tx3up
# Add tx3 tools to PATH
ENV PATH="/root/.tx3/bin:$PATH"

# Copy node_modules from deps stage
COPY --from=deps /app/node_modules ./node_modules

# Copy source code
COPY . .

# Use Docker-specific trix configuration
RUN cp tx3/trix.docker.toml tx3/trix.toml

# Create the output directory for tx3 bindings
RUN mkdir -p node_modules/.tx3

# Build the application
RUN pnpm build

# Set environment to production
ENV NODE_ENV=production

# Start the production server
CMD ["pnpm", "start"]
