#!/bin/sh
# APEX v5 — clean-room install check. Every command documented in docs/INSTALL.md
# must succeed in a fresh git repo, and the resulting state must be what docs claim.
set -u
ROOT=/home/yaser/apex-v5
T="${TMPDIR:-/tmp}/apex-v5-install-smoke"
rm -rf "$T"; mkdir -p "$T/project"
cd "$T/project" || exit 1
git init -q; git config user.email t@t; git config user.name t
pass=0; fail=0
run() {
  label="$1"; shift
  "$@" >/dev/null 2>"$T/err.txt"; rc=$?
  if [ "$rc" -eq 0 ]; then printf 'PASS  %-34s rc=0\n' "$label"; pass=$((pass+1));
  else printf 'FAIL  %-34s rc=%s :: %s\n' "$label" "$rc" "$(sed -n '1p' "$T/err.txt")"; fail=$((fail+1)); fi
}
expect_file() {
  if [ -s "$1" ]; then printf 'PASS  exists: %s\n' "$1"; pass=$((pass+1));
  else printf 'FAIL  missing: %s\n' "$1"; fail=$((fail+1)); fi
}
run 'mkdir -p ledgers/hooks/workflows' mkdir -p .opencode/agents githooks .builder/audit .builder/hygiene .builder/evals .builder/research .github/workflows
run 'copy persona' cp "$ROOT/persona/apex.md" .opencode/agents/apex.md
run 'copy pre-commit hook' cp "$ROOT/gate/pre-commit" githooks/pre-commit
run 'chmod +x hook' chmod +x githooks/pre-commit
run 'git config core.hooksPath' git config core.hooksPath githooks
run 'copy CI workflow' cp "$ROOT/gate/audit-gate.yml" .github/workflows/audit-gate.yml
expect_file .opencode/agents/apex.md
expect_file githooks/pre-commit
expect_file .github/workflows/audit-gate.yml
if [ "$(git config --get core.hooksPath)" = githooks ]; then
  echo 'PASS  core.hooksPath = githooks'; pass=$((pass+1))
else echo 'FAIL  core.hooksPath'; fail=$((fail+1)); fi
if cmp -s githooks/pre-commit "$ROOT/gate/pre-commit"; then
  echo 'PASS  installed hook byte-identical'; pass=$((pass+1))
else echo 'FAIL  installed hook differs'; fail=$((fail+1)); fi
printf '\nInstall smoke: %d passed, %d failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ] || exit 1
exit 0
