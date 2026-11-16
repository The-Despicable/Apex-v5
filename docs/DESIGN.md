# Apex v5 design — three layers, no blurred claims

The defect in v4 was not bad intentions. It was one word doing too much work: claims about
*what the system does* were written in the same register as instructions about *what the agent
should do*. v5 separates them.

## Layer 1 — Normative (instructions, no proof required)

"Cite `file:line`." "Run the gates." "Escalate a BLOCK to the user." These are rules for the
agent, not statements about the world. They are internally consistent and need no external
evidence. They carry no claim marker.

## Layer 2 — Descriptive (claims, must be backed)

Any sentence asserting that a mechanism exists, enforces, blocks, proves, or guarantees carries
a a bracketed claim marker resolving to `persona/CLAIMS.md`, which points to a command in
`verify/verify.sh` or a primary source with a date. `verify.sh` checks that every marker resolves
and that unmarked descriptive keywords do not appear `[C-claims-resolve]`.

## Layer 3 — Enforced (mechanisms with mechanical tests)

The signed-verdict gate is the only mechanically enforced control `[C-ci-gate]`. It binds a verdict to a git tree hash,
milestone, expiry, and HMAC. CI verifies it on every push; the local hook does the same on a
best-effort basis. Ten bypass/tamper cases are executed by `verify/bypass-suite.sh` and all are
rejected `[C-bypass-suite]`.

## What this buys

A reader can distinguish, in one glance, between a rule they are asked to follow, a claim they
are asked to trust, and a mechanism they can test. That distinction is the whole point of v5.
