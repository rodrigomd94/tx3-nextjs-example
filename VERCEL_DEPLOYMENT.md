# Vercel Deployment Guide for TX3 + Next.js

This guide explains how to deploy your TX3 + Next.js application to Vercel with automatic TX3 tool installation and binding generation.

## 🚀 Quick Deployment

1. **Push your code to a Git repository** (GitHub, GitLab, or Bitbucket)
2. **Connect to Vercel:**
   - Go to [vercel.com](https://vercel.com)
   - Import your repository
   - Vercel will automatically detect the `vercel.json` configuration
3. **Deploy:** The build will automatically handle TX3 setup

## 🔧 How It Works

The Vercel build process:

1. **Install Dependencies:** `pnpm install`
2. **Install TX3 Tools:** Runs `scripts/install-tx3-vercel.sh` which:
   - Downloads and installs `tx3up`
   - Installs `trix`, `dolos`, and other TX3 tools
   - Sets up proper PATH configuration
3. **Generate Bindings:** Runs `pnpm build` which:
   - Executes `pnpm tx3:generate` (calls `scripts/generate-tx3.mjs`)
   - Runs `trix bindgen` to generate TypeScript bindings from `tx3/main.tx3`
   - Builds the Next.js application

## 📁 Generated Files

During build, the following happens:
- TX3 tools are installed to `$HOME/.tx3/stable/bin/` and `$HOME/.cargo/bin/`
- TypeScript bindings are generated to `node_modules/.tx3/`
- Next.js webpack configuration handles the `@tx3` alias for imports

## 🛠️ Configuration Files

### `vercel.json`
```json
{
  "buildCommand": "bash scripts/install-tx3-vercel.sh && pnpm build",
  "installCommand": "pnpm install",
  "framework": "nextjs"
}
```

### `scripts/install-tx3-vercel.sh`
- Robust installation script for Vercel environment
- Handles different home directory locations
- Verifies installation success
- Sets up proper PATH configuration

### `scripts/generate-tx3.mjs`
- Updated to work in Vercel environment
- Checks multiple possible locations for `trix` binary
- Includes Vercel-specific paths (`/vercel/.tx3/`, `/vercel/.cargo/`)

## 🔍 Troubleshooting

### Build Fails with "trix command not found"

1. **Check build logs** in Vercel dashboard for detailed error messages
2. **Verify installation script** ran successfully - look for:
   ```
   🚀 Installing TX3 tools for Vercel deployment...
   ✅ trix installed successfully
   🎉 TX3 tools installation completed!
   ```

### Architecture Issues

The installation script supports both x86_64 and aarch64 architectures. If you see architecture errors:
- Check the build logs for detected architecture
- Ensure TX3 tools support your target architecture

### Build Timeout

If builds timeout during TX3 installation:
1. **Contact Vercel support** to increase build timeout
2. **Use fallback approach** (see below)

## 🔄 Fallback: Pre-generated Bindings

If automatic installation fails, you can pre-generate bindings locally:

### Step 1: Generate Bindings Locally
```bash
# Ensure you have TX3 tools installed locally
tx3up

# Generate bindings
pnpm tx3:generate
```

### Step 2: Commit Generated Bindings
```bash
# Modify .gitignore to include TX3 bindings
echo "!/node_modules/.tx3" >> .gitignore

# Add and commit
git add node_modules/.tx3
git commit -m "Add pre-generated TX3 bindings for Vercel"
```

### Step 3: Update Vercel Configuration
```json
{
  "buildCommand": "next build",
  "installCommand": "pnpm install",
  "framework": "nextjs"
}
```

## 🌍 Environment Variables

No additional environment variables are required. The installation script automatically:
- Sets up `CARGO_HOME` and `TX3_HOME`
- Configures `PATH` to include TX3 tools
- Sources cargo environment

## 📊 Build Performance

Typical build times:
- **TX3 Installation:** 2-3 minutes
- **Binding Generation:** 10-30 seconds
- **Next.js Build:** 1-2 minutes
- **Total:** 3-6 minutes

## 🔗 Related Files

- `vercel.json` - Vercel deployment configuration
- `scripts/install-tx3-vercel.sh` - TX3 installation script
- `scripts/generate-tx3.mjs` - Binding generation script
- `tx3/trix.toml` - TX3 project configuration
- `next.config.ts` - Next.js configuration with TX3 webpack setup

## 🆘 Support

If you encounter issues:
1. Check Vercel build logs for detailed error messages
2. Verify your `tx3/main.tx3` file is valid
3. Test binding generation locally with `pnpm tx3:generate`
4. Contact Vercel support for platform-specific issues

The deployment is now configured to work seamlessly with Vercel's build environment!
