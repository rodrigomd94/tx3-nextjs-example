# Next.js with TX3 and Dolos Devnet Example

This project demonstrates how to integrate [TX3](https://tx3.dev) (via `trix`) with a [Next.js](https://nextjs.org/) application. It utilizes a local Cardano development network (devnet) powered by [Dolos](https://github.com/txpipe/dolos) to simulate a blockchain environment.

The `trix` tool is used for code generation (`trix bindgen`), creating TypeScript bindings from TX3 definitions, which are then used within the Next.js application.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Running Without Docker](#running-without-docker)
  - [1. Install TX3 Tools (trix, dolos)](#1-install-tx3-tools-trix-dolos)
  - [2. Set Up and Run the Dolos Devnet](#2-set-up-and-run-the-dolos-devnet)
  - [3. Run the Next.js Application](#3-run-the-nextjs-application)
- [Running With Docker](#running-with-docker)
  - [1. Build and Run with Docker Compose](#1-build-and-run-with-docker-compose)
- [Code Generation with `trix bindgen`](#code-generation-with-trix-bindgen)

## Prerequisites

Before you begin, ensure you have the following installed:

- [Node.js](https://nodejs.org/) (v18 or later recommended)
- [pnpm](https://pnpm.io/installation)
- [Rust and Cargo](https://www.rust-lang.org/tools/install) (primarily for `tx3up` to build its components)

## Running Without Docker

Follow these steps to run the application locally without using Docker.

### 1. Install TX3 Tools (trix, dolos)

If you haven't already, install `trix`, `dolos`, and other TX3 tools using `tx3up`:

```bash
# Install tx3up (if you don't have it)
curl --proto '=https' --tlsv1.2 -LsSf https://github.com/tx3-lang/up/releases/latest/download/tx3up-installer.sh | sh

# Install/Update trix, dolos, and other tx3 tools
tx3up
```
This command will download and install the necessary binaries, including `trix` and `dolos`.
Ensure that `$HOME/.cargo/bin` and `$HOME/.tx3/stable/bin` (or the equivalent for your OS) are in your system's `PATH`. The `tx3up` installer usually handles this for Cargo, and TX3 tools are installed into `$HOME/.tx3/stable/bin`.

### 2. Set Up and Run the Dolos Devnet

This project includes a configuration for Dolos. To run the devnet:

```bash
# Navigate to the devnet configuration directory
cd devnet

# Run Dolos with the provided configuration
dolos daemon --config dolos.toml
```
This will start a local Cardano devnet. Keep this terminal window open. The `dolos.toml` file in the `devnet` directory specifies the network parameters, including the path to genesis files.

While the devnet is running, you can explore its state in a new terminal:
```bash
cd devnet
trix explore
```
This will launch the `trix explore` TUI, allowing you to inspect blocks, transactions, and other devnet details.

### 3. Run the Next.js Application

With the Dolos devnet running, open another new terminal window and navigate back to the project root directory.

First, install the project dependencies:
```bash
pnpm install
```

Then, run the development server:
```bash
pnpm dev
```
This command will:
1. Execute `scripts/generate-tx3.mjs`, which runs `trix bindgen` to generate TypeScript code from the TX3 definitions in `tx3/main.tx3`.
2. Start the Next.js development server.

Open [http://localhost:3000](http://localhost:3000) with your browser to see the result.

## Running With Docker

This project includes a `Dockerfile` and `docker-compose.yml` to simplify setup and ensure a consistent environment.

### 1. Build and Run with Docker Compose

From the project root directory, run:
```bash
docker compose up --build
```
This command will:
1. Build the Docker image for the application, which includes installing `trix`, `dolos`, and project dependencies.
2. Start two services:
    - `dolos`: Runs the Dolos devnet.
    - `app`: Runs the Next.js application. `trix bindgen` is executed as part of the startup process.

The Next.js application will be available at [http://localhost:3000](http://localhost:3000).

To stop the services, press `Ctrl+C` in the terminal where `docker compose up` is running, and then you can run:
```bash
docker compose down
```

## Code Generation with `trix bindgen`

The core of the TX3 integration is the `trix bindgen` command. This command reads TX3 schema files (in this project, `tx3/main.tx3`) and generates corresponding TypeScript (or other language) bindings.

In this example:
- The `tx3/main.tx3` file defines the data structures and transactions.
- The `tx3/trix.toml` file configures `trix`, specifying the input TX3 files and the output directory for the generated code (e.g., `app/tx3-generated`).
- The `scripts/generate-tx3.mjs` script is responsible for invoking `trix bindgen` before the application starts. This ensures that the TypeScript bindings are up-to-date with the TX3 definitions.
- The generated TypeScript files are then imported and used within the Next.js components (e.g., `app/test-tx3/page.tsx`).

When running the application with `pnpm dev`, changes to files within the `tx3` directory (e.g., `tx3/main.tx3`) will automatically trigger a regeneration of the TypeScript bindings. This is handled by `nodemon`, which monitors these files and re-runs the `trix bindgen` command as needed. You no longer need to manually restart the development server for these types of changes. For Docker, you would still need to restart the container if `tx3/main.tx3` changes, as the file watching is set up for the local development environment.
