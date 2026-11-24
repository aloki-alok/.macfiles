import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';

const base = '/.macfiles/v/docs';

export default defineConfig({
  site: 'https://aloki-alok.github.io',
  base,
  srcDir: './site',
  trailingSlash: 'always',
  integrations: [
    starlight({
      title: "Alok Ranjan's Mac setup",
      description: 'macOS configuration with Nix, Home Manager and nix-darwin. Setup guides and workflow references by Alok Ranjan.',
      favicon: '/favicon.svg',
      customCss: ['./site/styles.css'],
      credits: false,
      tableOfContents: { minHeadingLevel: 2, maxHeadingLevel: 3 },
      social: [{ icon: 'github', label: 'View source on GitHub', href: 'https://github.com/aloki-alok/.macfiles' }],
      components: {
        SiteTitle: './site/components/SiteTitle.astro',
        Footer: './site/components/Footer.astro',
        ThemeProvider: './site/components/ThemeProvider.astro',
        ThemeSelect: './site/components/ThemeSelect.astro',
      },
      head: [
        { tag: 'meta', attrs: { name: 'author', content: 'Alok Ranjan' } },
        { tag: 'meta', attrs: { name: 'robots', content: 'noindex' } },
        { tag: 'meta', attrs: { property: 'og:image', content: 'https://alokranjan.me/og.png?v=6' } },
        { tag: 'script', attrs: { type: 'application/ld+json' }, content: JSON.stringify({
          '@context': 'https://schema.org',
          '@type': 'Person',
          '@id': 'https://alokranjan.me/#person',
          name: 'Alok Ranjan',
          url: 'https://alokranjan.me/',
          sameAs: ['https://github.com/aloki-alok'],
        }) },
      ],
      sidebar: [
        { label: 'Start here', items: [
          { slug: 'index' },
          { slug: 'setup' },
          { slug: 'structure' },
        ] },
        { label: 'Daily work', items: [
          { slug: 'herdr' },
          { slug: 'terminal' },
          { slug: 'agents' },
        ] },
        { label: 'Keep it working', items: [
          { slug: 'changes' },
          { slug: 'recovery' },
          { slug: 'ideas' },
        ] },
        { label: 'About this site', items: [{ slug: 'handbook' }] },
      ],
    }),
  ],
});
