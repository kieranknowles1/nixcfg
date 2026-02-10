// @ts-check
import { defineConfig } from 'astro/config';

import icon from 'astro-icon';

// https://astro.build/config
export default defineConfig({
  integrations: [icon()],
  cacheDir: '.cache/astro',
  vite: {
    // This needs to be writable during Nix build
    cacheDir: '.cache/vite'
  }
});
