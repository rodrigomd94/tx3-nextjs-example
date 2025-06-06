import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  /* config options here */
  experimental: {
    turbo: {
      resolveAlias: {
        '@tx3': './tx3/bindings',
      },
    },
  },
  webpack: (config) => {
    // Add alias for @tx3
    config.resolve.alias = {
      ...config.resolve.alias,
      '@tx3': './tx3/bindings',
    };

    // Configure webpack to handle TypeScript files in .tx3 directory
    config.module.rules.push({
      test: /\.ts$/,
      include: /node_modules\/\.tx3/,
      use: [
        {
          loader: 'ts-loader',
          options: {
            transpileOnly: true,
            compilerOptions: {
              module: 'esnext',
              target: 'es2017',
              moduleResolution: 'node',
              esModuleInterop: true,
              allowSyntheticDefaultImports: true,
              skipLibCheck: true,
            },
          },
        },
      ],
    });

    return config;
  },
};

export default nextConfig;
