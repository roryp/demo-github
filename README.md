# demo-github

A simple static website built with plain HTML and CSS. No build step, no dependencies.

## Files

- `index.html` — single-page layout (nav, hero, About, Services cards, Contact form).
- `styles.css` — styling with a gradient hero, responsive card grid, and a 600px mobile breakpoint.

## Run locally

The MCP browser blocks `file://`, so serve the folder over HTTP:

```powershell
# From the repo root
python -m http.server 18765 --bind 127.0.0.1
```

Then open <http://127.0.0.1:18765/index.html>.

Any static server works (`npx serve`, `http-server`, etc.) — pick a port that isn't reserved by Windows (`8765` failed with `WinError 10013` on this machine; `18765` worked).

## Test with the Playwright MCP tool

Smoke tests run directly against the local server using the Playwright MCP browser tools — no test files are committed.

Steps:

1. **Start the server** (see above). Keep it running in a separate shell.
2. **Navigate the browser:**
   ```js
   browser_navigate({ url: "http://127.0.0.1:18765/index.html" })
   ```
3. **Verify load + no console errors** with `browser_console_messages` (a `favicon.ico` 404 is expected and cosmetic).
4. **Verify hero + nav + cards** via `browser_snapshot` and `browser_evaluate`:
   ```js
   () => ({
     cards: document.querySelectorAll('.card').length,
     navHrefs: [...document.querySelectorAll('.nav-links a')].map(a => a.getAttribute('href')),
   })
   ```
   Expected: `cards: 3`, hrefs `['#home','#about','#services','#contact']`.
5. **Check in-page navigation:** click Home / About / Services / Contact and the hero "Learn More" button, then confirm `location.hash` updates.
6. **Exercise the contact form:**
   - `browser_fill_form` with Name, Email, Message.
   - Click Send; the page fires `alert('Thanks! (demo form)')`.
   - Respond with `browser_handle_dialog({ accept: true })`.
   - Reset and click Send with empty fields; confirm no alert fires (HTML5 `required` blocks it).
7. **Responsive check:**
   - `browser_resize({ width: 1280, height: 800 })` → `browser_take_screenshot({ filename: 'desktop-1280.png', fullPage: true })`.
   - `browser_resize({ width: 375, height: 800 })` → `browser_take_screenshot({ filename: 'mobile-375.png', fullPage: true })`.
   - At 375px the 600px breakpoint shrinks the hero H1 (40px → 28px) and stacks cards in a single column.
8. **Cleanup:** `browser_close()` and stop the Python server.

Screenshots from a reference run are included at the repo root (`desktop-1280.png`, `mobile-375.png`).
