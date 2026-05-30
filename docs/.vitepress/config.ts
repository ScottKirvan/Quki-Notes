import { defineConfig } from 'vitepress'

export default defineConfig({
  title: 'QuKi-Notes',
  description: 'Capture and toss ephemeral notes.',
  base: '/quki-notes/',
  themeConfig: {
    nav: [
      { text: 'User Guide', link: '/user-guide/getting-started' },
    ],
    sidebar: [
      {
        text: 'User Guide',
        items: [
          { text: 'Getting Started', link: '/user-guide/getting-started' },
        ],
      },
    ],
  },
})
