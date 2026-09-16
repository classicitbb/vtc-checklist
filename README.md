# VTC Remote Venue Checklist PWA

This is a GitHub Pages-ready Progressive Web App.

## What it does

- Works as an installable PWA.
- Saves checklist progress locally on each user's device/browser using `localStorage`.
- Caches the app for offline use using a service worker.
- Allows users to move between Thursday, Saturday, and Lord's Day checklists.
- Shows progress per category and per day.
- Automatically collapses completed categories.
- Shows the run sheet for each day with Barbados times in bold and New York times on the right.
- Shows a live "next up" strip with a countdown to the next scheduled item.

## Event dates and times

All times below are Barbados (AST, UTC-4). New York times are calculated in the
browser from the same instant, so they stay correct across EST/EDT.

| Day | Date | Meetings |
| --- | --- | --- |
| Thursday | 17 September 2026 | 11:00 AM Meeting 1 - 1:30 PM Meeting 2 |
| Saturday | 19 September 2026 | 11:00 AM Meeting 1 - 1:30 PM Meeting 2 |
| Lord's Day | 20 September 2026 | 12:30 PM Meeting |

Run sheet for Thursday and Saturday:

| Time | Item |
| --- | --- |
| 8:30 AM | Sound checkers join Zoom |
| 8:30 AM | VTCs arrive at venue and complete checklists |
| 9:00 AM | VTCs join Zoom and sound checking begins |
| 9:30 AM | Hall open |
| 9:45 AM | Sound checking complete and main session open |
| 10:15 AM | Meeting 1: Seated and settled |
| 11:00 AM | Meeting 1: Commences (be ready for meeting to start early) |
| 1:00 PM | Meeting 2: Seated and settled |
| 1:30 PM | Meeting 2: Commences (be ready for meeting to start early) |

Run sheet for Lord's Day:

| Time | Item |
| --- | --- |
| 10:00 AM | Sound checkers join Zoom |
| 10:00 AM | VTCs arrive at venue and complete checklists |
| 10:30 AM | VTCs join Zoom and sound checking begins |
| 11:00 AM | Hall open |
| 11:15 AM | Sound checking complete and main session open |
| 11:45 AM | Meeting 1: Seated and settled |
| 12:30 PM | Meeting 1: Commences (be ready for meeting to start early) |

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

Edit `index.html`:

- Checklist items: the `COMMON` and `DAILY` arrays.
- Dates and meeting times: the `EVENT_DAYS` array.
- Run sheet items: the `TWO_MEETING_RUN` array and the `SCHEDULES` object.
- Time zones: the `LOCAL_*` and `HOST_TZ` constants at the top of the script.

Run sheet and meeting times are written as Barbados wall clock in 24-hour form,
for example `'13:30'`.

After major edits, change the cache name in `service-worker.js`, for example from:

```js
const CACHE_NAME = 'vtc-checklist-pwa-v1';
```

to:

```js
const CACHE_NAME = 'vtc-checklist-pwa-v2';
```

This forces devices to pick up the new version.
