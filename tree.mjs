// Save as tree.mjs and run: node tree.mjs

import fs from 'fs/promises';
import path from 'path';
import url from 'url';

const __dirname = path.dirname(url.fileURLToPath(import.meta.url));
const EXCLUDES = new Set(['node_modules', '.git', '.dart_tool', 'dist', 'build', 'coverage', 'logs', 'tmp', '.cache', '.vscode', '.idea', 'ios', 'android', '.DS_Store']);

const outputLines = [];

async function printTree(dir, prefix = '') {
  const items = await fs.readdir(dir);
  for (let i = 0; i < items.length; i++) {
    const item = items[i];
    if (EXCLUDES.has(item)) continue;

    const isLast = i === items.length - 1;
    const pointer = isLast ? '└── ' : '├── ';
    const fullPath = path.join(dir, item);
    const stat = await fs.stat(fullPath);

    outputLines.push(prefix + pointer + item);
    if (stat.isDirectory()) {
      await printTree(fullPath, prefix + (isLast ? '    ' : '│   '));
    }
  }
}

await printTree(__dirname);
await fs.writeFile('tree.txt', outputLines.join('\n'), 'utf8');

console.log('Directory tree written to tree.txt');
