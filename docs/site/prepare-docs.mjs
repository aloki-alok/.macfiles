import { mkdir, readdir, readFile, rm, writeFile } from 'node:fs/promises';

const source = new URL('../src/', import.meta.url);
const destination = new URL('../.generated/docs/', import.meta.url);
const base = '/.macfiles/v/docs/';

await rm(destination, { recursive: true, force: true });
await mkdir(destination, { recursive: true });

for (const name of (await readdir(source)).filter(name => name.endsWith('.md') && name !== 'SUMMARY.md')) {
  const text = await readFile(new URL(name, source), 'utf8');
  const heading = text.match(/^# (.+)$/m);
  if (!heading) throw new Error(`${name} needs a page title`);
  const title = heading[1];
  const afterTitle = text.slice(heading.index + heading[0].length).trimStart();
  const description = afterTitle.split('\n\n')[0].replace(/[`*]/g, '').replace(/\[([^\]]+)\]\([^)]+\)/g, '$1');
  const content = text.replace(heading[0], '').replace(/^```text\n[\s\S]*?```\n+/, '');
  const links = content.replace(/\]\((\w+)\.md(#[^)]*)?\)/g, (_, file, hash = '') => `](${base}${file === 'index' ? '' : `${file}/`}${hash})`);
  const frontmatter = [
    '---',
    `title: ${JSON.stringify(title)}`,
    `description: ${JSON.stringify(description)}`,
    `editUrl: ${JSON.stringify(`https://github.com/aloki-alok/.macfiles/edit/main/docs/src/${name}`)}`,
    '---',
    '',
  ].join('\n');
  await writeFile(new URL(name, destination), frontmatter + links.trim() + '\n');
}

await writeFile(new URL('404.md', destination), '---\ntitle: Page not found\ndescription: Find the setup guide or return to the Mac handbook.\npagefind: false\n---\n\nThis page has moved or does not exist. [Return to the handbook](/.macfiles/v/docs/) or search for a topic.\n');
