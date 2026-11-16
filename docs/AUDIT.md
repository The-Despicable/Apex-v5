# What the audit found (and why v5 exists)

Source target: the Apex 4.0.0 persona package. Full audit report: `AUDIT-FULL.md`.
All findings below were reproduced on 2026-11-16 against the unmodified package.

## The three reproduced gate bypasses

The package claimed hook-enforced audit independence [C-audit-repro]. In a clean git repo with the shipped hook
installed byte-for-byte, a standing BLOCK verdict rejected a staged `auth/` file (exit 1). Then:

| Action | Result |
|---|---|
| `echo PASS > .builder/audit/verdict` | exit 0, commit created `[C-audit-repro]` |
| `git commit -n` | exit 0, commit created `[C-audit-repro]` |
| `git config core.hooksPath emptyhooks` | exit 0, commit created `[C-audit-repro]` |

Root cause: the `edit` deny covers edit/write/patch tools, not shell writes; `-n` and hooksPath
changes are git features no local hook can stop. The honest conclusion is that a local hook is
advisory, not a control `[C-key-custody]`.

## The verification claims that had no evidence

- README claimed "evals that prove the organs work." No fixtures, harness, or executed eval
  existed; the eval log template was empty `[C-evals-not-run]`.
- The "no theater" table listed ten organs with a check that proves each ran. One was executable
  (the pre-commit hook). The other nine had prose or templates `[C-no-theater-1of10]`.
- "R0 loads nothing" was unenforced: all skills were permitted at every rigor level.

## What v5 changes

| Layer | v4 claim | v5 reality |
|---|---|---|
| Control | local hook is the gate | CI re-verifies signed verdict against the pushed tree; hook is advisory `[C-ci-gate]` |
| Verdict | plain editable file | HMAC token bound to milestone, tree hash, expiry; verified by CI `[C-ci-gate]` |
| Evidence | "evals prove" | mechanical harness runs and writes receipts; behavioral evals are labeled not-run `[C-evals-not-run]` |
| Docs | "no theater — every organ earns its keep" | normative practices and mechanically checked claims are listed separately `[C-no-theater-1of10]` |

## What v5 does not claim

- That the local hook cannot be bypassed. It can; CI is the control `[C-ci-gate]`.
- That behavioral agent evals were executed. They were not `[C-evals-not-run]`.
- That any token scheme survives a builder who holds the signing key. Key custody is an
  operational assumption, not a verified property `[C-key-custody]`.
