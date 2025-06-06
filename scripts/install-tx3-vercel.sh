#!/bin/bash
set -e

echo "🚀 Installing TX3 tools for Vercel deployment..."

# Set up environment
export HOME=${HOME:-/vercel}
export CARGO_HOME="$HOME/.cargo"
export TX3_HOME="$HOME/.tx3"

# Create necessary directories
mkdir -p "$CARGO_HOME/bin"
mkdir -p "$TX3_HOME/stable/bin"

# Update PATH
export PATH="$CARGO_HOME/bin:$TX3_HOME/stable/bin:$PATH"

echo "📁 Home directory: $HOME"
echo "📁 Cargo home: $CARGO_HOME"
echo "📁 TX3 home: $TX3_HOME"

# Install tx3up
echo "📦 Downloading tx3up installer..."
curl --proto '=https' --tlsv1.2 -LsSf https://github.com/tx3-lang/up/releases/latest/download/tx3up-installer.sh | sh

# Source cargo environment if it exists
if [ -f "$CARGO_HOME/env" ]; then
    echo "🔧 Sourcing cargo environment..."
    source "$CARGO_HOME/env"
fi

# Verify tx3up installation
if [ -f "$CARGO_HOME/bin/tx3up" ]; then
    echo "✅ tx3up installed successfully"
    chmod +x "$CARGO_HOME/bin/tx3up"
else
    echo "❌ tx3up installation failed"
    exit 1
fi

# Install TX3 tools
echo "🔧 Installing TX3 tools..."
"$CARGO_HOME/bin/tx3up"

# Verify trix installation
if [ -f "$TX3_HOME/stable/bin/trix" ]; then
    echo "✅ trix installed successfully at $TX3_HOME/stable/bin/trix"
    chmod +x "$TX3_HOME/stable/bin/trix"
elif [ -f "$CARGO_HOME/bin/trix" ]; then
    echo "✅ trix installed successfully at $CARGO_HOME/bin/trix"
    chmod +x "$CARGO_HOME/bin/trix"
else
    echo "❌ trix installation failed"
    echo "🔍 Searching for trix..."
    find "$HOME" -name "trix" -type f 2>/dev/null || echo "No trix binary found"
    exit 1
fi

echo "🎉 TX3 tools installation completed!"
echo "📍 PATH: $PATH"
echo "🔍 trix location: $(which trix || echo 'not in PATH')"
