# APEX persona — independent audit report

> Primary evidence file. The commands and outputs quoted here are the backing for the
> `[C-...]` markers used in the persona, README and posts. Statements in this file are
> supported inline; it is not a derivative claim.

**Date:** 2026-11-16
**Target:** /home/yaser/Glm/Glm-Apex (Apex 4.0.0)
**Mode:** AUDIT / EVALUATE. Target repo not modified.
**Sources:** request → package's own README/CHANGELOG/OPERATING-MODEL claims; universal persona-quality bar.

## Verdict

**DO NOT SHIP** as the enforced-governance persona it claims to be.

Apex is a well-written process specification with a convincing surface (84/84 structural lint,
8 seats, 10 skills, 10 commands, a pre-commit hook). But its three differentiating claims —
hook-enforced audit independence, "evals that prove the organs work," and "no theater — every
organ earns its keep" — are respectively **bypassable**, **never run**, and **9/10 fictional**.
I independently reproduced three separate bypasses of the audit gate, each committing a file
under `auth/` with a standing BLOCK verdict and exit code 0. Fixing this is a redesign of the
enforcement layer, not a patch. The engineering doctrine itself is sound and worth keeping.

## Scope and method

- Read fully: `.opencode/agents/apex.md` (381 lines), 8 seats, 10 SKILL.md + 3 reference files,
  10 commands, README, INSTALL, CHANGELOG, OPERATING-MODEL, evals, templates/AGENTS.md,
  13 builder templates, 3 config files, 2 scripts. ~50 files.
- Ran: `apex-lint.sh` -> 84 passed, 0 failed; `apex-doctor.sh`; `opencode --version` -> v2.3.0;
  `opencode debug agents` -> effective merged permission order; a clean temp git repo with the
  exact hook copied byte-for-byte to reproduce gate bypasses under /tmp/opencode.
- Primary sources: official OpenCode v2 permissions and agents docs (fetched 2026-11-16) for
  rule ordering, wildcard semantics, tool actions, and subagent permission isolation.
- Four independent parallel lenses: content consistency, enforcement/security, install/ledger,
  evals/proportion. Every top finding verified against real files or commands before inclusion.

## Confirmed blockers

| ID | Evidence | Issue | Fix | Status |
|---|---|---|---|---|
| B1 | apex.md:11-13 (edit deny only); pre-commit:19; own repro: `echo PASS > .builder/audit/verdict` -> exit 0 with auth/ staged under BLOCK | `edit` deny does not cover shell writes; verdict forgeable; "builder cannot edit this file" is false | Signed verdict outside builder-writable paths + server-side CI gate | CONFIRMED |
| B2 | apex.md:59-60; policies.snippet.jsonc:14; own repro: `git commit -n` -> exit 0 under BLOCK | Short form and `-c` variants unmatched; local hook bypassable by design | Deny aliases + enforce in CI | CONFIRMED |
| B3 | no rule denies `git config core.hooksPath`; policies:16 protects `.git/hooks/*` but hook lives in `githooks/`; own repro: hooksPath -> emptyhooks -> exit 0 | Enforcement hook disposable with one git command | Deny config changes; verify hook activation; CI | CONFIRMED |
| B4 | pre-commit:11,24-29; lens test K: `rm verdict` + non-risk commit -> exit 0 | Deleting verdict clears BLOCK for non-risk commits | Require valid PASS for every commit | CONFIRMED |
| B5 | researcher.md:24-26 (`shell: *` allowed), :48-53 (webfetch/websearch allow); apex.md:74-76 | All parent egress asks bypassed by delegating to researcher; its "writes research/** only" claim false | Shell allowlist; deny webfetch/websearch by default | CONFIRMED |
| B6 | README.md:40; lens repro: `cp: cannot stat 'githooks'`, RC=1 | Quickstart command fails and leaves a partial install that looks successful | Correct command + full hook activation steps | CONFIRMED |
| B7 | README.md:3,32; evals/persona-evals.md:18,37,61; templates/builder/EVALS.md empty | No fixtures, harness, or executed eval anywhere; "evals that prove" is prospective only | Ship harness + fixtures, run S1-S3, populate EVALS.md, or drop "prove" | CONFIRMED |

## Major findings (grouped)

**Self-consistency**
- apex.md:316 omits internal-audit at R2 while :217, build.md:15, audit.md:13, gates:57, release:14 mandate it.
- Council size at R2 is both 3-5 (apex.md:316) and >=8 (apex.md:236, build.md:14).
- task-contract-example.md:7,10,28,31 assigns OUTPUT files to `apex/auditor` and `apex/redteam`, both permission-denied from writing anything (apex.md:302,304).
- apex.md:131-146 ledger table omits `.builder/research/`, `.builder/audit/`, PLAN files, eval run files.
- Label sets differ (apex.md:103 has SUSPECTED; researcher.md:78 does not); architect.md:73 drops reversibility; retro skill requires Cost field absent from ledger schema; apex.md:377 cites eval 7-8 when enforcement is S5.

**Enforcement**
- No `webfetch`/`websearch` rules; `webfetch * -> allow` in effective permissions. Data-in-URL egress unguarded.
- `curl *localhost*` allow matches `localhost.evil.com` and headers containing "localhost" (whole-value wildcard on raw command string).
- Verdict has no milestone/tree-hash binding or expiry (internal-audit.md:116); `PASSED-caveats` and leading-blank verdicts accepted (pre-commit:17,25).
- Hook RISK_RE (pre-commit:12) misses models/, terraform/, k8s/, workflows/, openapi.yaml, lockfiles.
- Hook is opt-in, never verified at runtime; its own self-test fails because `.builder/audit/` is never created.

**Install and ledger**
- `templates/builder/` ships flat `hygiene-queue.md` / `EVALS.md`; every reference expects `.builder/hygiene/queue.md` / `.builder/evals/EVALS.md`. Seats are permissioned to write the nonexistent nested paths.
- No install step creates `.builder/{audit,hygiene,evals,research}/`.
- INSTALL section 1 never copies `scripts/`, so its own verification commands fail inside the installed project.
- Rollback leaves `githooks/`, `AGENTS.md`, and `.opencode/` structure.
- "14 ledger files" (README.md:29) vs 13 shipped; "3 commands" quickstart omits git init, hook activation, root AGENTS.md, ledger copy, reload.

**Evaluation and proportion**
- Most "deterministic" oracles require transcript interpretation; several can false-PASS. S7 counts "the ask fired" as equivalent to no egress.
- OPERATING-MODEL.md:71-86 claims a proving check per organ; only internal-audit has one (1/10).
- "R0 loads nothing" is prose only; all 10 skills permitted at all rigor; core always loaded (~4-5k token floor).
- N=2 A/B (persona-evals.md:76) cannot support a "not slower" claim; judge-oracle disagreement metric has no implementation.

**Shipped command bugs**
- apex-hygiene/SKILL.md:31 `rg -n "console\.log\|print(" src/` exits 2 with `regex parse error: unclosed group`.
- playwright-patterns.md:64 omits `json` from imports but :77 calls `json.dumps` in the failure handler.

## Rejected finding

One lens claimed glob depth was broken: apex.md:299 uses `.builder/research/**` while researcher.md:56 uses `.builder/research/*`, and if `*` were single-segment the researcher could not write nested captures. Official docs state `*` matches zero or more characters **including `/`** and matches the entire normalized path. **Not a defect.**

## Quality scores

| Dimension | Score | Evidence |
|---|---|---|
| Design doctrine | 4.5/5 | Evidence-first, failure-mode driven, decomposition contracts, Flaw Hunt, spend ladder, debugging protocol (apex.md:100-108,219-281,357-359) |
| Internal consistency | 2.5/5 | R2 matrix contradictions, worked examples assigning writes to read-only seats, schema drift, wrong eval citations |
| Enforcement correctness | 1/5 | Three independently reproduced gate bypasses; opt-in hook; no CI; egress bypass via subagent |
| Installability / docs | 2/5 | Quickstart RC=1; partial install; ledger layout mismatch; incomplete rollback |
| Verification / evidence | 1/5 | Zero executed evals; empty EVALS.md; 9/10 no-theater checks absent |
| Maintainability | 3/5 | Modular files, real lint, honest UNVERIFIED labels; offset by 4-5k always-loaded tokens and diffused permissions |

## Top fixes by effort

1. **L — Redesign enforcement.** Signed verdict outside builder-writable paths; server-side CI gate; deny shell writes to audit dir, `-n`, hooksPath changes; remove base shell allow-all; lock researcher shell; webfetch/websearch rules.
2. **M-L — Make verification real.** Fixtures + `run-eval.sh` + mechanical oracles; run S1-S3; populate EVALS.md with receipts; split machine-assertable from judged oracles.
3. **S-M — Fix install and ledger layout.** Nested templates, `cp -r`, create audit/hygiene/evals/research dirs, copy scripts, correct quickstart and rollback.
4. **S — Align contradictions.** R2 matrix, council counts, worked example owners, label sets, schemas, eval citations.
5. **S — Fix shipped command bugs.** rg pattern, missing json import.
6. **S — Correct claims.** Verification date 2026-11-17, "prove/verified/no theater" language, 14 -> 13 ledger files.

## Recommendation

Do not integrate wholesale. Cherry-pick the doctrine (evidence rules, ledger discipline, task contracts,
Flaw Hunt, spend ladder, structural lint) into the existing claude-builder persona. If Apex is kept,
install it only as an opt-in style layer with all "enforced", "hook-enforced", "proven", and
"no theater" claims removed; treat the hook as an honesty speed bump, not a control. Re-audit with
the same harness after fixes; the verdict changes only when the gate survives the three bypasses.

## Audit limitations

- Policy/permission pattern matching was verified against official docs and effective config order,
  not a live permission-event harness for every pattern (curl substring and sudo-wrapper cases are
  design-level CONFIRMED, runtime form may vary by install).
- Global install, `opencode reload`, `--worktree`, `session export`, and `stats --json` were not executed.
- Target's own lint passes 84/84; that checks structure only and was not treated as evidence of truth.
