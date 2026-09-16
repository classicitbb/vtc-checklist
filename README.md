# VTC Remote Venue Checklist PWA

This is a GitHub Pages-ready Progressive Web App.

## What it does

- Works as an installable PWA.
- Saves checklist progress locally on each device using `localStorage`.
- Optionally shares check-offs between devices in real time (see below).
- Caches the app for offline use using a service worker.
- Allows users to move between Thursday, Saturday, and Lord's Day checklists.
- Shows progress per category and per day.
- Automatically collapses completed categories.
- Shows the run sheet for each day with Barbados times in bold and New York times on the right.
- Run sheet collapses and expands by tapping its header; the choice is remembered on the device.
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

## Sharing check-offs between devices

Out of the box the app is local to one device. Point it at a Firebase Realtime
Database and every device sharing that address works from the same board: a tick
on one phone appears on the others in about a second.

It uses the database REST API and its server-sent-events stream directly, so
there is no SDK to download and the app still works with no database configured.

### One-time setup

1. Create a free project at <https://console.firebase.google.com>.
2. **Build > Realtime Database > Create Database**. Pick a location and start in
   locked mode.
3. Open the **Rules** tab and allow just the one board, using a long random
   segment as the shared key:

   ```json
   {
     "rules": {
       "boards": {
         "vtc-sep2026-CHANGE-THIS-TO-SOMETHING-RANDOM": {
           ".read": true,
           ".write": true
         }
       }
     }
   }
   ```

4. The board address is the database URL plus that path, for example
   `https://your-project-default-rtdb.firebaseio.com/boards/vtc-sep2026-xxxx`.
5. Open the app once on each device with the address attached:

   ```
   https://your-pages-site/?sync=https://your-project-default-rtdb.firebaseio.com/boards/vtc-sep2026-xxxx
   ```

   The device remembers it, so later visits (and the installed PWA) stay on that
   board. `?sync=` with nothing after it puts a device back to local only.

Alternatively set `SYNC_DEFAULT` in `index.html` so every install shares
automatically. Note this repository is public, so anyone reading it would then
have the board address. Sending the `?sync=` link privately to the VTC team
keeps the address off the public site.

### What is stored

Only tick state: `{v:0|1, t:<epoch ms>}` per checklist item, under
`<day>/<category>/<item index>`. No checklist wording, names or notes leave the
device, and the checklist itself still lives in `index.html`.

### How it behaves

- **Newest tick wins.** Each write carries a timestamp; older writes never
  overwrite newer ones, including a write queued while a device was offline.
- **Offline is fine.** Ticks are saved locally and queued. The chip by the
  buttons reads `Shared · offline · N waiting`, then flushes on reconnect.
  Before a queued tick is sent it is checked against the board, so it cannot
  clobber a change someone else made in the meantime.
- **A quiet connection is treated as a dropped one.** Queued writes are retried
  on a timer and the stream is reopened if it goes silent, because a phone
  moving between Wi-Fi and mobile data often leaves a connection open but dead.
- **Reset clears the board.** With sharing on, "Reset this day" wipes that day
  for everyone and says so before it does.
- **The chip shows the state**: `This device only`, `Shared · connecting…`,
  `Shared · live`, or `Shared · offline`.

Anyone with the board address can read and change ticks, so treat it like a
shared password. For per-user accounts instead, the same code shape works with
Firebase Auth or Supabase, with more setup.

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
- Shared board address: the `SYNC_DEFAULT` constant.

Run sheet and meeting times are written as Barbados wall clock in 24-hour form,
for example `'13:30'`.

After major edits, change the cache name in `service-worker.js`, for example from:

```js
const CACHE_NAME = 'vtc-checklist-pwa-v2';
```

to:

```js
const CACHE_NAME = 'vtc-checklist-pwa-v3';
```

This forces devices to pick up the new version.
