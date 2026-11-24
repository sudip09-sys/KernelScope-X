# Website deployment and maintenance

KernelScope X provides three static website entry points:

- [Homepage](https://sudip09-sys.github.io/KernelScope-X/) — `index.html`
- [Process/scheduling browser demo](https://sudip09-sys.github.io/KernelScope-X/demo.html) — `demo.html`
- [Memory Intelligence Lab](https://sudip09-sys.github.io/KernelScope-X/memory-lab.html) — `memory-lab.html`

These browser experiences use **illustrative / simulated data**. The actual Windows telemetry runs in the native desktop application.

## Branch organization

| Branch | Content | Use |
|---|---|---|
| `main` | C++/Qt app, docs, tests, plus root HTML entry points and static files under `assets/website/` | Main project/source-of-truth |
| `gh-pages` | Website-only branch, with HTML/CSS/JS at branch root | A clean GitHub Pages publishing branch |

The two branches have different static asset layouts **on purpose**:

- `main/index.html` references `assets/website/site.css` and `assets/website/site.js`.
- `main/memory-lab.html` references `assets/website/memory-lab.css` and `assets/website/memory-lab.js`.
- `gh-pages/index.html` references root `site.css` and `site.js`; `gh-pages/memory-lab.html` similarly references root memory-lab assets.
- `demo.html` bundles its own styles/script.

All three existing public URLs are preserved. **Do not delete the root HTML files on `main` or the site files on `gh-pages` until you confirm which branch is configured in GitHub Pages Settings.**

## Updating the website

1. Edit and test the version on `main`.
2. Copy the corresponding site changes to `gh-pages`, adjusting stylesheet and script paths for the branch's flat file layout.
3. Check GitHub **Settings → Pages** to identify the active publishing branch and `/ (root)` folder.
4. Verify the three public URLs after the GitHub Pages deployment completes.
5. Keep native source files (`app/`, `src/`, `tests/`) on `main`; they are not needed in `gh-pages`.

## Notes for a professor demo

The web process tree, CPU history and lab results are simulations. Open the Windows Qt application to demonstrate real process enumeration and CPU/RAM figures. Never present website example metrics as live host measurements.
