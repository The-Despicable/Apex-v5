# Installing Apex v5

Two layers, deliberately separated:

- **Normative layer** — `persona/apex.md` is an agent instruction file. Install it if you want the working doctrine.
- **Control layer** — `gate/` is a signed-verdict gate. The real control is CI; the local hook is advisory.

This package is published as a verifiable artifact. You do not have to install it to inspect it:
`sh verify/verify.sh` runs every check against this checkout and writes `evidence/EVIDENCE.md`.

## Project install (all commands verified by `verify/install-smoke.sh`)

```sh
cd /path/to/your/project                 # a dedicated git repo, not $HOME
mkdir -p .opencode/agents githooks .builder/audit .builder/hygiene .builder/evals .builder/research .github/workflows
cp /path/to/apex-v5/persona/apex.md .opencode/agents/apex.md
cp /path/to/apex-v5/gate/pre-commit githooks/pre-commit
chmod +x githooks/pre-commit
git config core.hooksPath githooks
cp /path/to/apex-v5/gate/audit-gate.yml .github/workflows/audit-gate.yml
```

Add a GitHub Actions secret `APEX_AUDIT_KEY`. The audit role (never the builder) signs verdicts:

```sh
APEX_AUDIT_KEY='<secret>' sh /path/to/apex-v5/gate/sign-verdict.sh PASS M1
```

Verify on any commit:

```sh
APEX_AUDIT_KEY='<secret>' sh /path/to/apex-v5/gate/verify-verdict.sh
```

## What is and is not enforced

- **Enforced:** CI re-verifies the signed verdict against the pushed commit's tree hash, expiry, and HMAC.
- **Advisory:** the local `pre-commit` hook calls the same verifier, but `git commit -n` and
  `git config core.hooksPath` bypass any local hook. That is a property of git, not a defect we hide.
- **Assumed:** the signing key is held only by the audit role / CI. If the builder can sign,
  no token scheme can help. This assumption is stated, not silently claimed as verified.

## Rollback

```sh
git config --unset core.hooksPath
rm -f .opencode/agents/apex.md githooks/pre-commit .github/workflows/audit-gate.yml
```

Ledger directories and any signed verdicts under `.builder/` are left in place deliberately:
they are your project data, not package files.
