# VTC Remote Venue Checklist PWA

This is a GitHub Pages-ready Progressive Web App.

## What it does

- Works as an installable PWA.
- Saves checklist progress locally on each device using `localStorage`.
- Shares check-offs between devices through a shared board (see below).
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

Ticks are shared through a **board**. Every device pointed at the same board
works from the same checklist: a tick on one phone shows on the others.

Two kinds of board are understood, and neither loads an SDK:

| Board | How it is recognised | Updates |
| --- | --- | --- |
| Supabase | a `*.supabase.co` address, a `key=` on the address, or a `/rest/v1` path | polled every 4 seconds |
| Firebase Realtime Database | anything else | pushed instantly over the REST event stream |

`SYNC_DEFAULT` in `index.html` is set to the Supabase project
`dzsalnvmlvjoatryhqfz`. It still needs that project's **publishable (anon)
key** before it can talk to it, which is the one piece not in this repository.

### Setting up the Supabase board

1. In the Supabase dashboard open **SQL Editor** and run [`supabase.sql`](supabase.sql).
   It creates the `vtc_checks` table, turns on row level security, and adds the
   two functions the app writes through.
2. Open **Project Settings > API** and copy the **anon / publishable** key.
3. Either paste the key into `SUPABASE_KEY` in `index.html`, or put it on the
   address and hand that to each device:

   ```
   https://your-pages-site/?sync=https://dzsalnvmlvjoatryhqfz.supabase.co%3Fkey%3DYOUR_ANON_KEY
   ```

   The simplest route on a phone is to tap the status chip beside the buttons
   and paste `https://dzsalnvmlvjoatryhqfz.supabase.co?key=YOUR_ANON_KEY`.

The key is designed to be shipped in client apps: it is the row level security
policies, not secrecy, that decide what it can do. Here it can read the board
and call the two functions. It cannot insert, update or delete rows directly,
so it cannot be used to write anything the app would not write. It does,
however, reach every table in that project, so use a project whose other tables
have row level security enabled.

Change `BOARD_ID` to start a fresh board, for example for the next occasion.

### Using a Firebase Realtime Database instead

Point `SYNC_DEFAULT` (or `?sync=`) at a database path such as
`https://your-project-default-rtdb.firebaseio.com/boards/vtc-sep2026`, and
restrict the rules to that one path:

```json
{
  "rules": {
    "boards": {
      "vtc-sep2026-CHANGE-THIS": { ".read": true, ".write": true }
    }
  }
}
```

Updates then arrive instantly rather than every few seconds. Anyone with that
address can read and change ticks, so treat it like a shared password.

### What is stored

Only tick state: `{v:0|1, t:<epoch ms>}` per checklist item, keyed by
`<day>/<category>/<item index>`. No checklist wording, names or notes leave the
device.

### How it behaves

- **Newest tick wins.** Every write carries a timestamp and older writes are
  discarded, on the server for Supabase and on the client for Firebase.
- **Offline is fine.** Ticks are saved locally and queued; the chip reads
  `Shared · offline · N waiting` and flushes on reconnect. Each queued tick is
  checked against the board before it is sent, so it cannot overwrite a change
  someone else made in the meantime.
- **A quiet connection is treated as a dropped one.** Queued writes are retried
  on a timer and a silent stream is reopened, because a phone moving between
  Wi-Fi and mobile data often leaves a connection open but dead.
- **Reset clears the board.** With sharing on, "Reset this day" wipes that day
  for everyone and says so before it does.
- **The chip shows the state**: `This device only`, `Board needs a key`,
  `Shared · connecting…`, `Shared · live`, or `Shared · offline`. Tapping it
  sets, changes or clears the board address on that device; clearing it is
  remembered, so the device stays off sharing.

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
- Shared board: the `SYNC_DEFAULT`, `SUPABASE_KEY` and `BOARD_ID` constants.

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
