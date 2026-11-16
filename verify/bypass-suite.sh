#!/bin/sh
# APEX v5 — reproduce the original persona's three gate bypasses against the NEW gate,
# plus five more tamper cases. Every case must be REJECTED by gate/verify-verdict.sh.
set -u
ROOT=/home/yaser/apex-v5
T="${TMPDIR:-/tmp}/apex-v5-bypass"
GATE="$ROOT/gate/verify-verdict.sh"
SIGN="$ROOT/gate/sign-verdict.sh"
export APEX_AUDIT_KEY='apex-v5-test-key-public-fixture-only'
rm -rf "$T"; mkdir -p "$T"
pass=0; fail=0

setup() {
  name="$1"; D="$T/$name"
  mkdir -p "$D/.builder/audit" "$D/auth" "$D/models"
  cd "$D" || exit 1
  git init -q; git config user.email t@t; git config user.name t
  echo base > base.txt; git add base.txt; git commit -qm baseline
}

probe() {
  name="$1"; want="$2"
  out=$(sh "$GATE" 2>&1); rc=$?
  if [ "$want" = OK ]; then want_rc=0; else want_rc=1; fi
  line=$(printf '%s\n' "$out" | sed -n '1p')
  if [ "$rc" -eq "$want_rc" ]; then
    printf 'PASS  %-26s want=%s rc=%s :: %s\n' "$name" "$want" "$rc" "$line"
    pass=$((pass+1))
  else
    printf 'FAIL  %-26s want=%s rc=%s :: %s\n' "$name" "$want" "$rc" "$line"
    fail=$((fail+1))
  fi
}

# 1. Control: a correctly signed PASS for the current tree is accepted.
setup control
sh "$SIGN" PASS M1 >/dev/null
probe 'control-valid-pass' OK

# 2. Original bypass G: plain shell redirect over the verdict.
setup forge_plain
echo PASS > .builder/audit/verdict
probe 'forge-plain-redirect' FAIL

# 3. Tampered signature on an otherwise valid token.
setup forge_hmac
sh "$SIGN" PASS M1 >/dev/null
v=$(sed -n '1p' .builder/audit/verdict)
printf '%sX\n' "${v%?}" > .builder/audit/verdict
probe 'tampered-hmac' FAIL

# 4. A validly signed BLOCK is not a PASS.
setup signed_block
sh "$SIGN" 'BLOCK: IA-1' M1 >/dev/null
probe 'signed-block-not-pass' FAIL

# 5. Original bypass D: git commit -n (local hook skipped) changes the tree.
setup dash_n
sh "$SIGN" PASS M1 >/dev/null
echo x > auth/a.ts; git add auth/a.ts
git commit -n -m dashn >/dev/null 2>&1
probe 'commit-dash-n-tree-change' FAIL

# 6. Original bypass F: hooksPath disabled, commit changes the tree.
setup hooks_off
sh "$SIGN" PASS M1 >/dev/null
mkdir -p emptyhooks; git config core.hooksPath emptyhooks
echo x > auth/b.ts; git add auth/b.ts
git commit -m hooksoff >/dev/null 2>&1
probe 'hooksPath-disabled-tree-change' FAIL

# 7. Verdict deleted entirely.
setup deleted
sh "$SIGN" PASS M1 >/dev/null
rm -f .builder/audit/verdict
probe 'verdict-deleted' FAIL

# 8. Malformed verdict that the old hook accepted as PASS.
setup malformed
printf 'PASSED-caveats\n' > .builder/audit/verdict
probe 'malformed-PASSED-prefix' FAIL

# 9. Correctly signed but expired token.
setup expired
tree=$(git rev-parse 'HEAD^{tree}')
payload="APEX1|M1|$tree|PASS|1"
hmac=$(printf '%s' "$payload" | openssl dgst -sha256 -hmac "$APEX_AUDIT_KEY" | awk '{print $NF}')
printf '%s|%s\n' "$payload" "$hmac" > .builder/audit/verdict
probe 'expired-token' FAIL

# 10. Valid signature but bound to a different tree (stale verdict from another commit).
setup stale
sh "$SIGN" PASS M1 >/dev/null
echo x > models/m.ts; git add models/m.ts
git commit -n -m newtree >/dev/null 2>&1
probe 'stale-tree-binding' FAIL

printf '\nBypass suite: %d passed, %d failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ] || exit 1
exit 0
