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

# Set NODE_ENV to ensure devDependencies are installed
ENV NODE_ENV=development
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

# Set PATH to include default cargo and tx3 bin directories
ENV PATH="/root/.cargo/bin:/root/.tx3/stable/bin:$PATH"

# Install tx3up and trix (using default paths)
RUN curl --proto '=https' --tlsv1.2 -LsSf https://github.com/tx3-lang/up/releases/latest/download/tx3up-installer.sh | sh && \
    echo "Running tx3up..." && \
    tx3up && \
    echo "Checking for trix in $HOME/.tx3/stable/bin..." && \
    ls -la $HOME/.tx3/stable/bin && \
    echo "Running 'which trix'..." && \
    which trix || echo "trix not found in PATH after install (dev stage)"

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

# Set PATH to include default cargo and tx3 bin directories (consistent with dev stage)
ENV PATH="/root/.cargo/bin:/root/.tx3/stable/bin:$PATH"

# Install tx3up and trix for production builds (using default paths)
RUN curl --proto '=https' --tlsv1.2 -LsSf https://github.com/tx3-lang/up/releases/latest/download/tx3up-installer.sh | sh && \
    echo "Running tx3up..." && \
    tx3up && \
    echo "Checking for trix in $HOME/.tx3/stable/bin..." && \
    ls -la $HOME/.tx3/stable/bin && \
    echo "Running 'which trix'..." && \
    which trix || echo "trix not found in PATH after install (runner stage)"

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

# Set environment to production for runtime
ENV NODE_ENV=production

# Prune devDependencies for a smaller production image
RUN pnpm prune --prod

# Start the production server
CMD ["pnpm", "start"]
