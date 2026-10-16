# EYW-622 — GitHub Pages deploy failure triage & hardening note

**Issue:** EYW-622 — fix the github deployment
**Date:** 2026-10-16/17 (AEST)
**Repo:** `terrygzhou/terrygzhou.github.io` (legacy GitHub-managed Jekyll + `pages-themes/architect`)

## Triage (ADR-style, Type 2 — two-way door)

- **Context:** Pages build+deploy run `38960872036` (commit `e2717791`, 20:15 view-counter refresh) failed: build PASS, deploy stuck in `updating_pages` for the full 10-min `actions/deploy-pages@v5` timeout and was cancelled; site flagged `errored`.
- **Decision:** treat stuck `updating_pages` as a **GitHub-side transient Pages deployment-backend hang, not a repo defect**. Recovery = let the next scheduled refresh (or a clean redeploy) re-run build+deploy; **do not patch the repo**.
- **Consequences:** no in-repo workflow change; keep the 30-min refresh cadence (content-only `assets/views-data.json` pushes, low risk). A custom longer-timeout Actions deploy job is **not** warranted for a GitHub-managed Jekyll Pages build.
- **Verification outcome:** the site **self-healed** without any manual redeploy — the next scheduled refresh run `38964486968` (commit `78fbc5e3`, 20:45) succeeded and the live site returned HTTP 200 serving the 20:45 content. The manual-redeploy portion of the approved fix plan (A) therefore became unnecessary; the gate was declined with reason.

## Run ledger (evidence)

| Run | Commit | Time (Z) | Result |
|---|---|---|---|
| 38960872036 | `e2717791` | 20:15 | **failure** (deploy timeout in `updating_pages`) |
| 38957210612 | `1c59d268` | 19:45 | success (last build live at failure time) |
| 38964486968 | `78fbc5e3` | 20:45 | success (recovered; site live) |

All 30-min refresh runs 16:45–19:45 also succeeded; 20:15 was the sole transient hang in the window.

## Recurrence checklist (if Pages fails again)

1. Check Actions runs: is **build** green and only **deploy** stuck? → GitHub-side, retry, don't patch the repo.
2. Wait for the next scheduled refresh push (30-min cadence) — the stuck state usually clears on the next build+deploy.
3. If two consecutive refresh runs fail, trigger a clean redeploy (Pages redeploy control or trivial push) and verify `status=active` / latest build `built` / newest content live.
4. Only consider workflow changes if the failure mode moves out of `updating_pages` (e.g. build errors) — then it's a repo defect, not a Pages backend hang.

---
*Recorded by: Enterprise Architecture Lead (EYW-622 approver heartbeat, run 704825ff). Filed in the Blog project workspace per project-task routing; also attached to EYW-622 in Paperclip.*
