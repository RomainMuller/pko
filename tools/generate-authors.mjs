import * as console from 'console';
import { promises as fs } from 'fs';
import { resolve } from 'path';
import * as process from 'process';
import { fileURLToPath } from 'url';

export async function main(source, target) {
  source = resolve(process.cwd(), source);
  target = resolve(process.cwd(), target);

  const byName = (l, r) => l.name.localeCompare(r.name);

  const data = JSON.parse(await fs.readFile(source, { encoding: 'utf-8' }));
  const result = [];
  for (const contributor of data.contributors.sort(byName)) {
    result.push(`# Contributions: ${contributor.contributions.join(', ')}`);
    result.push(`${contributor.name} (${contributor.profile})`);
  }
  await fs.writeFile(target, result.join('\n') + '\n', { encoding: 'utf-8' });
}

const [_, script, source, target, ...rest] = process.argv;
if (resolve(script) === resolve(fileURLToPath(import.meta.url))) {
  if (rest.length !== 0) {
    console.error('Too many arguments procided!');
    console.error(`Usage: ${script} <source> <target>`)
    process.exit(-1);
  }

  await main(source, target);
}
