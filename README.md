# VTC Remote Venue Checklist PWA

This is a GitHub Pages-ready Progressive Web App.

## What it does

- Works as an installable PWA.
- Saves checklist progress locally on each user's device/browser using `localStorage`.
- Caches the app for offline use using a service worker.
- Allows users to move between Friday, Saturday, and Lord's Day checklists.
- Shows progress per category and per day.
- Automatically collapses completed categories.

## Important limitation

GitHub Pages is static hosting. It does not provide a shared database.

Each VTC/user will have their own checklist progress on their own device. Multiple users can use the app at the same time, but their progress will not sync with each other.

For shared team progress, add Firebase, Supabase, Airtable, Google Sheets API, or another backend.

## Deploy to GitHub Pages

1. Create a GitHub repository, for example `vtc-checklist-pwa`.
2. Upload these files to the root of the repository:
   - `index.html`
   - `manifest.json`
   - `service-worker.js`
   - `icons/icon-192.png`
   - `icons/icon-512.png`
3. In GitHub, go to **Settings > Pages**.
4. Set source to **Deploy from a branch**.
5. Select branch `main` and folder `/root`.
6. Save.
7. Open the GitHub Pages URL on the device.
8. On Android/Chrome, choose **Install app** or **Add to Home screen**.

## Updating the checklist

Edit `index.html`. The checklist data is inside the `COMMON` and `DAILY` JavaScript arrays.

After major edits, change the cache name in `service-worker.js`, for example from:

```js
const CACHE_NAME = 'vtc-checklist-pwa-v1';
```

to:

```js
const CACHE_NAME = 'vtc-checklist-pwa-v2';
```

This forces devices to pick up the new version.
