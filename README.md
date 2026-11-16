# Apex v5 — an engineering persona that can defend its own claims

Apex v4 was a polished engineering persona: 381 lines, eight specialist seats, ten skills, a
ledger, and a "hook-enforced" audit gate [C-audit-repro]. I audited it. The gate was defeated by three shell
commands, its "evals that prove the organs work" had never been run, and nine of the ten checks
in its "no theater" table did not exist as executable checks `[C-audit-repro]` `[C-evals-not-run]` `[C-no-theater-1of10]`.

Apex v5 is the rebuild. It keeps the working doctrine and replaces every unsupported assertion
with either a runnable check, a primary source, or an explicit "not verified" label.

## The test that started it

Clean git repo. Copy the shipped hook byte-for-byte. Set `core.hooksPath`. Put a BLOCK verdict in
place and stage a file under `auth/`:

```
control: BLOCK + staged auth/          exit 1   (rejected, as advertised)
```

Then three variations:

```
echo PASS > .builder/audit/verdict     exit 0   (commit created)
git commit -n                          exit 0   (commit created)
git config core.hooksPath emptyhooks   exit 0   (commit created)
```

All three committed while a BLOCK stood. The `edit` permission denies edit/write/patch tools,
but a shell redirect is not an edit tool; `-n` and hooksPath changes are git features no local
hook can stop `[C-audit-repro]`. The hook's own message — "the builder cannot edit this file" —
was false.

## The actual defect

Not bad intent. A category error. The document used one voice for two different things:

- **Rules** for the agent — "cite `file:line`", "escalate a BLOCK". These need no proof.
- **Claims** about the system — "this is enforced", "these evals prove it" [C-claims-resolve]. These need evidence.

When both are written in the same confident register, a reader cannot tell which sentence to
trust. v5 separates them, and the separation is mechanically checked `[C-claims-resolve]`.

## What v5 does instead

| Layer | What it contains | How it is checked |
|---|---|---|
| Normative | Working doctrine: evidence rules, ledger, decomposition, Flaw Hunt, debugging | Internal consistency; no claim marker |
| Descriptive | Statements about mechanisms | Each carries a a bracketed claim marker resolving to `persona/CLAIMS.md` |
| Enforced | Signed-verdict gate | Ten bypass/tamper probes; CI re-verification `[C-ci-gate]` `[C-bypass-suite]` |

The verdict is now a token bound to a milestone, a git tree hash, an expiry, and an HMAC.
CI verifies it against the pushed commit, so a local flag or a disabled hook cannot carry:
the tree changed, the token no longer matches `[C-ci-gate]`. The local hook still calls the same
verifier, but it is explicitly labeled advisory [C-ci-gate]. Claiming a local hook cannot be bypassed would
be false, so v5 does not claim it `[C-ci-gate]`.

## Prove it yourself

```sh
sh verify/verify.sh
```

It writes `evidence/EVIDENCE.md` from real command output `[C-evidence-generated]`. The checks
include the ten-case bypass suite, a clean-room install smoke test, claim-marker resolution,
a grounding-keyword scan, risk-path regex coverage, and two corrected commands that the audit
found broken `[C-bypass-suite]` `[C-install-smoke]`.

## What v5 does not claim

- That behavioral agent evals were run. They were not; a harness design is present, but no
  behavioral receipt is claimed `[C-evals-not-run]`.
- That the local hook is a security control. It is not; CI is the control `[C-ci-gate]`.
- That tokens survive a builder who holds the signing key. Key custody is stated as an
  operational assumption, not a verified fact `[C-key-custody]`.
- That the structural lint proves behavior. It checks file structure only `[C-structural-lint]`.

## Layout

```
persona/apex.md      the improved persona — normative rules + marked descriptive claims
persona/CLAIMS.md    every marker -> statement -> evidence -> status
gate/                signed verdict, verifier, advisory hook, CI workflow
verify/              bypass suite, install smoke, lint, master harness
docs/                audit findings, design rationale, install instructions
evidence/EVIDENCE.md generated output — do not edit by hand
```

Install instructions are in `docs/INSTALL.md`. The full audit is at `AUDIT-FULL.md`.
