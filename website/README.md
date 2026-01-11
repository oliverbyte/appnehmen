# Appnehmen Website

This directory contains the Jekyll-based informational website for Appnehmen.

## Development

To run the website locally:

```bash
cd website
bundle install
bundle exec jekyll serve
```

The website will be available at `http://localhost:4000/appnehmen/info/`

## Deployment

The website is automatically deployed to GitHub Pages via GitHub Actions when changes are pushed to the main branch.

- **App URL**: https://oliverbyte.github.io/appnehmen/
- **Website URL**: https://oliverbyte.github.io/appnehmen/info/

## Structure

- `_config.yml` - Jekyll configuration
- `_layouts/` - HTML layouts
- `assets/` - CSS, images, and other assets
- `index.md` - Main landing page
- `Gemfile` - Ruby dependencies

## SEO

The website includes:
- Jekyll SEO Tag plugin
- Sitemap generation
- RSS feed
- Open Graph and Twitter Card meta tags
- German language optimization
