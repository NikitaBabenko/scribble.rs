# VibeNest integration candidate

Status: **NOT READY — static preparation only; no deployment or game acceptance yet.**

This COPY-only image adds nginx around the official Scribble.rs v0.9.14 binary.
It does not compile the newer master source retained in this fork. Both images
are pinned by digest in the root Dockerfile. The game image's BuildKit provenance
names upstream commit `000312758ce98ca6280880ea5ab57d28d1215a2e`.

The v0.9.14 binary uses Go 1.25.5. This integration is a mitigation for two
statically reachable advisories, **not an update of the vulnerable Go runtime**:

- [GO-2026-4341](https://pkg.go.dev/vuln/GO-2026-4341): all HTTP routes share an
  8 KiB body limit, 2 KiB request-line/per-header limit, bounded connections and
  request rate. Request buffering is enabled. There is no unguarded route.
- [GO-2026-6609](https://pkg.go.dev/vuln/GO-2026-6609): nginx removes `Range` and
  `If-Range` before all upstream requests, including embedded static resources.

The game binds only to `127.0.0.1:8081`, forced by the entry script even if old
PORT/NETWORK_ADDRESS environment values exist. Only nginx listens on port 8080.
The global connection limit is 16 (including upgraded WebSockets); eight players
per room is a configuration ceiling, not measured capacity. HTTP limits do not
limit WebSocket frames after upgrade, nor total room creation or drawing history.
The app's default WebSocket payload limit is 16 MiB. This candidate is intended
for small games among known participants, not a proven abuse-resistant public
service. Free-tier resource measurements and guard validation remain outstanding.

No database, volume, or external credentials are needed. Select the root
Dockerfile and public port 8080. Defaults are in the Dockerfile and .env.example.
Leave ROOT_PATH unset for a dedicated domain. ROOT_URL/CANONICAL_URL affect
metadata only; they need not be entered for gameplay. Optional CORS_ALLOWED_ORIGINS
can restrict CORS to the instance's public HTTPS origin. Current platform
EnvAutoFiller recognizes CORS_ALLOWED_ORIGINS but not ROOT_URL/CANONICAL_URL.

Private lobbies are unlisted UUID links, not password-protected rooms. Anyone
with the link can join. There are no game accounts. The proxy replaces incoming
forwarded-address chains with its last peer address, so the app's per-IP setting
does not identify real players; it defaults to eight to accommodate the shared
platform proxy. Do not describe this as reliable per-player abuse protection.
Upstream session cookies use SameSite=Strict without Secure/HttpOnly flags.
HTTPS edge behavior and cookies still need runtime review.

Rooms, drawings, chat, and scores live in process memory. Restart/replacement
ends existing rooms. Durable game-data persistence is not supported; acceptance
must confirm retained configuration and a fresh playable game after replacement.
The eight-player setting does not guarantee performance on 256 MB. Current
VibeNest Free inventory is permanent (256 MB RAM, 0.5 platform CPU, nominal 4 GiB
storage); actual cgroups, host CPU scaling, disk usage and disk enforcement must
be checked on the assigned host. No runtime pass is claimed here.

Upstream source, tests, examples, asset notices, and licenses are preserved.
Original artwork exclusions in the upstream README still apply. Repository
Actions are disabled; this integration has not run GitHub workflows.
