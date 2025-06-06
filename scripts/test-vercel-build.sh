#!/bin/bash
set -e

echo "🧪 Testing Vercel build configuration locally..."

# Clean up any existing TX3 installations for testing
echo "🧹 Cleaning up existing TX3 installations..."
rm -rf ~/.tx3 ~/.cargo/bin/tx3up ~/.cargo/bin/trix 2>/dev/null || true

# Test the installation script
echo "🔧 Testing TX3 installation script..."
bash scripts/install-tx3-vercel.sh

# Test binding generation
echo "📦 Testing binding generation..."
node scripts/generate-tx3.mjs

# Check if bindings were generated
if [ -d "node_modules/.tx3" ]; then
    echo "✅ TX3 bindings generated successfully!"
    echo "📁 Generated files:"
    ls -la node_modules/.tx3/
else
    echo "❌ TX3 bindings were not generated"
    exit 1
fi

# Test Next.js build
echo "🏗️ Testing Next.js build..."
pnpm build

echo "🎉 Vercel build test completed successfully!"
echo "💡 Your project is ready for Vercel deployment"
