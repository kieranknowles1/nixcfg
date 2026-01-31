# Astro

Reusable Astro components, layouts, error pages, and stylesheets. Derive a
project's root layout from `astro/layouts/LayoutBase.astro` to get started. This
layout:

- Allows for the inclusion of [Google Fonts](https://fonts.google.com) by name.
- Sets all text to use Arial by default.
- Provides the `sr-only` CSS class that makes text visible only to screen
  readers.

The following optional files are included and may be copied as-is:

- `pages/404.astro` - Basic 404 page that inherits the default layout and links
  to the homepage.
- `public/_headers` - Cache all assets for 7 days if using Cloudflare Pages.
  Browsers will revalidate the requested `*.html` file.

## Components

- `Video` - Embed a YouTube video. Styled with the `video` CSS class.
