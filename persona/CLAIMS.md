# Apex v5 claim ledger

Every descriptive claim in the public artifacts carries a a bracketed claim marker that resolves to one
of the entries below. Normative instructions carry no marker. Generated/verified on 2026-11-16.

### C-v4-inventory
**Claim:** The audited v4 package shipped a 381-line core, 8 seats, 10 skills and 10 commands.
**Evidence:** `AUDIT-FULL.md` scope section; verified by `wc -l` and `find` on 2026-11-16.
**Status:** CONFIRMED 2026-11-16

### C-audit-repro
**Claim:** The original v4 gate was defeated by a shell redirect, `git commit -n`, and a hooksPath change.
**Evidence:** `docs/AUDIT.md`; full report `AUDIT-FULL.md`; reproduced in a clean repo with exit 0 for all three.
**Status:** CONFIRMED 2026-11-16

### C-evals-not-run
**Claim:** The v4 package shipped no executed eval; its eval log template was empty. v5 labels behavioral evals as designed-but-not-executed.
**Evidence:** `docs/AUDIT.md`; `verify/verify.sh` §5-8 runs mechanical checks only; no behavioral eval receipt is claimed.
**Status:** CONFIRMED 2026-11-16

### C-no-theater-1of10
**Claim:** The v4 "no theater" table listed ten organs; one had an executable check.
**Evidence:** `docs/AUDIT.md`; full audit report §"Evaluation and proportion".
**Status:** CONFIRMED 2026-11-16

### C-ci-gate
**Claim:** CI re-verifies a signed verdict against the pushed commit's tree hash, expiry, and HMAC; the local hook is advisory.
**Evidence:** `gate/audit-gate.yml`, `gate/verify-verdict.sh`; ten rejection probes in `verify/bypass-suite.sh`.
**Status:** CONFIRMED 2026-11-16 (mechanical checks executed by `sh verify/verify.sh`)

### C-key-custody
**Claim:** The signing key must be held only by the audit role/CI. This is an operational assumption, not a verified property.
**Evidence:** `docs/INSTALL.md` §"What is and is not enforced"; `gate/sign-verdict.sh` requires `APEX_AUDIT_KEY`.
**Status:** ASSUMPTION — stated, not verified

### C-bypass-suite
**Claim:** All ten bypass/tamper probes are rejected by the v5 gate.
**Evidence:** `verify/bypass-suite.sh`; output in `evidence/EVIDENCE.md` §5.
**Status:** CONFIRMED 2026-11-16 — 10 passed, 0 failed

### C-install-smoke
**Claim:** Every command documented in `docs/INSTALL.md` succeeds in a clean git repo.
**Evidence:** `verify/install-smoke.sh`; output in `evidence/EVIDENCE.md` §6.
**Status:** CONFIRMED 2026-11-16 — 11 passed, 0 failed

### C-structural-lint
**Claim:** The persona file satisfies the V2 structural contract; the lint checks structure only, not behavior.
**Evidence:** `verify/lint.sh`; output in `evidence/EVIDENCE.md` §2.
**Status:** CONFIRMED 2026-11-16

### C-claims-resolve
**Claim:** Every marker used in public artifacts resolves to a claim here; unmarked descriptive keywords are absent.
**Evidence:** `verify/verify.sh` §3-4; output in `evidence/EVIDENCE.md`.
**Status:** CONFIRMED by `sh verify/verify.sh` on 2026-11-16

### C-evidence-generated
**Claim:** `verify/verify.sh` generates `evidence/EVIDENCE.md` from real command runs.
**Evidence:** `verify/verify.sh` §9; the file itself.
**Status:** CONFIRMED 2026-11-16

### C-perm-order
**Claim:** OpenCode V2 permission rules are ordered and the last matching rule wins; v5 has no base allow-all.
**Evidence:** `persona/apex.md` frontmatter lines 5-105; official docs https://opencode.ai/docs/permissions/ ("The last matching rule wins").
**Status:** CONFIRMED 2026-11-16 (documented + structural lint)

### C-env-prompt
**Claim:** A read of a path matching `*.env*` resolves to `ask` under v5's rule order.
**Evidence:** `persona/apex.md` frontmatter lines 8-19 (`read "*" allow` then `read "*.env*" ask`); last-match-wins rule above.
**Status:** CONFIRMED 2026-11-16 as a configuration fact. Runtime prompt behavior was not exercised.

### C-egress-ask
**Claim:** `webfetch` and `websearch` default to `ask`; only an explicitly added later allowlist would change that.
**Evidence:** `persona/apex.md` frontmatter lines 79-85.
**Status:** CONFIRMED 2026-11-16 as a configuration fact.

### C-shell-policy
**Claim:** Shell is ask-by-default with narrow pre-allowed localhost curls and hard-denied command forms; `--auto` approves every ask. These are policy rules, not a guarantee of coverage for every wrapper form.
**Evidence:** `persona/apex.md` frontmatter lines 33-78; official docs https://opencode.ai/docs/permissions/ (shell runs with host authority, matching is best effort).
**Status:** CONFIRMED as configuration + documented platform limitation; wrapper-form coverage NOT verified.

### C-audit-path
**Claim:** Local permission rules deny edit, write, and shell writes into `.builder/audit/*`.
**Evidence:** `persona/apex.md` frontmatter lines 21-47. Local layer only; see C-ci-verdict.
**Status:** CONFIRMED as configuration. Local shell writes can still occur outside this agent's tool layer; CI is the authority.

### C-ci-verdict
**Claim:** The authoritative verdict is checked by a server-side CI gate against tree hash, expiry and HMAC; the local hook is advisory.
**Evidence:** `gate/audit-gate.yml`, `gate/verify-verdict.sh`; ten probes in `verify/bypass-suite.sh`.
**Status:** CONFIRMED 2026-11-16 mechanically. CI provider execution was not run; key custody is assumed (C-key-custody).

### C-seat-scope
**Claim:** The squad "Writes" column declares permissions, not a performance guarantee; fan-out and skills are restricted to Apex seats plus the built-in explorer.
**Evidence:** `persona/apex.md` frontmatter lines 86-101; squad table lines 305-317.
**Status:** CONFIRMED as configuration.

### C-subagent-depth
**Claim:** Subagents do not launch further subagents; fan-out originates with the primary seat.
**Evidence:** squad section line 317; OpenCode docs describe child sessions and per-agent `subagent` permissions.
**Status:** ASSUMPTION — depends on the host's subagent policy; not mechanically verified in this package.

### C-evals-status
**Claim:** Behavioral evals S5 and S7 are designed but not executed; no results are claimed.
**Evidence:** `persona/apex.md` "Honest status (c)"; `docs/AUDIT.md`; `verify/verify.sh` runs mechanical checks only.
**Status:** CONFIRMED 2026-11-16 (no behavioral eval receipts exist).

### C-playwright
**Claim:** Playwright is the designated tool for the fourth retrieval rung; this is a design choice, not an executed capability eval.
**Evidence:** `persona/apex.md` line 270 (retrieval ladder).
**Status:** DESIGN CHOICE — not verified by a run in this package.

### C-cli-telemetry
**Claim:** Token/cost telemetry is available via `opencode stats --project . --cost --json`.
**Evidence:** `persona/apex.md` line 189 and CLI table line 335; command exists in the installed CLI.
**Status:** CONFIRMED 2026-11-16 — flags `--project`, `--cost`, `--json` verified via `opencode stats --help` on v2.3.0; field contents not inspected.

### C-stop-policy
**Claim:** Stop conditions are obligations backed locally by permission rules; the authoritative verdict belongs to CI.
**Evidence:** `persona/apex.md` frontmatter + stop conditions lines 349-358.
**Status:** CONFIRMED as configuration; see C-ci-verdict for the control layer.
