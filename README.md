# Asclepius — Tendon Load Tracker (PWA)

A single-file web app (EWMA-based ACWR) wrapped as a **PWA** so it installs on your phone like a native app — fullscreen icon, works offline — 100% free, no App Store needed.

## Files
- `index.html` — the whole app
- `manifest.webmanifest` — makes it installable (name, icon, fullscreen mode)
- `sw.js` — service worker = offline support
- `icons/` — app icons

## Run it on your computer
```bash
python -m http.server 4173
# open http://localhost:4173
```

## Deploy free (so your phone can install it)
1. Put this folder in a **GitHub** repo (upload via github.com, no git knowledge needed).
2. Go to **vercel.com** → sign in with GitHub → **Add New Project** → pick the repo → **Deploy** (no settings needed).
3. Open the `https://your-app.vercel.app` URL on your phone.

### Install on your phone
- **Android (Chrome):** open the URL → tap ⋮ → **Add to Home screen** / **Install app**.
- **iPhone (Safari):** open the URL → Share button → **Add to Home Screen**.

The icon appears on your home screen, opens fullscreen with no browser bars, and keeps working offline. Data is stored per-device in the browser.
