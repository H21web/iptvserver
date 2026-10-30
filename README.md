# JioTV Go on Voroa (Mumbai)

A thin deployment wrapper for [JioTV Go](https://github.com/rabilrbl/jiotv_go)
(CC BY 4.0, by rabilrbl). This bundle holds **no JioTV code and no
credentials** — it only starts the upstream server on Voroa's `$PORT`.

Why Voroa for this one: Voroa web services run in **Mumbai (IN)**.
The AlwaysData server failed playback with HTTP 451 because Jio saw
a French IP. A Mumbai IP is what the geo-check wants — but that is
still **unproven until the first channel actually plays** on Voroa.
This pack is a test, not a promise.

## What you get

- Web interface at your Voroa URL: channel list + web player
- IPTV playlist: `https://<your-service>.getvoroa.com/playlist.m3u`
  - Quality: `?q=low`, `?q=medium`, or `?q=high`
  - Language filter: `?l=Malayalam,English`
  - Use it in TiviMate / VLC / any IPTV player
- EPG: `https://<your-service>.getvoroa.com/epg.xml.gz`

## Deploy

1. Put these 2 files (`Dockerfile`, `start.sh`) in a **new, private**
   GitHub repo. Keep it private — see "Keep it private" below.
2. Voroa dashboard → New Web Service → connect that repo.
3. **Choose Docker as the runtime when you create the service.**
   Voroa does not switch to Docker on its own, and the runtime
   cannot be changed afterwards — if you pick the wrong runtime,
   delete the service and create it again.
4. Pick a size to start:
   - **Nano — ₹0/month, 0.1 CPU, 512 MB RAM** — free, no card.
     Good enough for this test.
   - Nano Plus — ₹149/month + 18% GST, 0.5 CPU, 512 MB.
   - Starter — ₹298/month + 18% GST, 1 CPU, 1 GB.
   (Prices checked 2026-10-30 on getvoroa.com/web-services, excl. GST.
   The workspace plan is billed separately from the service size —
   check the pricing page at checkout.)
5. Set this environment variable on the service:
   - `JIOTV_DISABLE_TS_HANDLER=true`
   - Why: with the TS handler ON, every video byte flows through
     Voroa and counts against your bandwidth. The free workspace
     only includes 5 GB/month — a few hours of TV would eat that.
     With it OFF, the manifest still goes through Voroa (Mumbai IP,
     so the geo-check passes), but video segments go straight from
     Jio's CDN to your browser (you are in India, so that leg passes
     too), and Voroa's bandwidth stays tiny.
   - Trade-off: this only works while *you* watch from India. A
     viewer outside India would get blocked on the segments.
     If a DRM channel fails with this ON, tell me — that channel
     may need the TS handler back on.
6. Deploy, wait for the live URL, open it.
7. **Log in on that site itself** with your own Jio number + OTP,
   using JioTV Go's own login page.
   - Do NOT paste your Jio number, OTP, SSO token, or any token
     into chat, into this repo, or into Voroa env vars.
   - If the login page does not appear, wait for the free service
     to wake up (first load after idle can be slow) and reload.
8. **The test that matters:** play a free channel (DD National,
   Aaj Tak, DD News). If it plays, the Mumbai geo-fix worked.
   If it still shows the player error, check whether the stream
   endpoint returns 451 again — that would mean Voroa's egress IP
   is not passing Jio's check either, and we stop here.

## Keep it private — important

Once you are logged in, **anyone with your Voroa URL can stream
on your Jio account** — there is no extra password in front of the
playlist. So:

- Do NOT post the Voroa URL or the playlist URL in your movie
  group, a public channel, or anywhere public.
- This is for your own personal use on your own Jio account.
  Do not resell it, share it, or use it to redistribute channels.
- If the URL ever leaks, log out on the site (or redeploy) and
  start fresh.

## Caveats — read before you rely on it

- **Voroa free sleeps when idle.** A free web service stops after
  no requests and starts again on the next one. First load after
  sleep is slow. Free workspace: 750 instance-hours/month shared
  across services, 5 GB bandwidth.
- **Filesystem is wiped on every deploy.** Voroa's own docs list
  persistent disks as "Soon" — so a redeploy can wipe the stored
  Jio login and you will have to log in again with OTP. Do not
  redeploy casually once it is working.
- **Bandwidth with the TS handler ON is the trap.** That is why
  step 5 sets it OFF. If you ever turn it back ON, watch the
  workspace bandwidth page — 5 GB free, then ₹8/GB extra.
- **Jio can change its API at any time.** If channels suddenly
  stop, it is usually an upstream/API change, not this bundle —
  check the upstream repo for an update first.
- **Not live-tested on Voroa by me.** I checked Voroa's current
  web-services page (Mumbai, Docker runtime, `$PORT`, sizes and
  free limits above) and built this wrapper from the upstream
  v3 code, but I have no Jio account and no Voroa deploy to test
  against. The first successful channel play on your URL is the
  real test.
- Defaults are kept as upstream ships them, except the one change
  in step 5: DRM stays on and URL encryption stays on. Do not
  turn those off.

## Files

- `Dockerfile` — starts from `ghcr.io/rabilrbl/jiotv_go:latest`
- `start.sh` — bridges Voroa's `$PORT` to jiotv_go's `--port` flag
  (jiotv_go does NOT read `$PORT` itself, and `--public` makes it
  listen on all interfaces, which is what a container host needs)
