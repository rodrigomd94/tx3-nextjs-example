// scripts/generate-tx3.js
import { execSync } from 'child_process';
import { globSync } from 'glob';
import path from 'path';
import fs from 'fs';
// load environment variables from .env file
import dotenv from 'dotenv';
dotenv.config({ path: path.resolve(process.cwd(), '.env') });


function generateBindings() {
  // Create output directory if it doesn't exist
  const outputDir = path.resolve(process.cwd(), 'node_modules/.tx3');
  fs.mkdirSync(outputDir, { recursive: true });
  
  // Run trix bindgen from within the tx3 directory
  const tx3Dir = path.resolve(process.cwd(), 'tx3');
  execSync('trix bindgen', { 
    stdio: 'inherit',
    cwd: tx3Dir
  });
}

generateBindings();
