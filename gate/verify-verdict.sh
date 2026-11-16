#!/bin/sh
# APEX v5 — verify a signed audit verdict against the CURRENT commit.
# This is the check CI runs on every push/PR. Local hook calls it too (advisory).
# Exit 0 only for a valid, unexpired, tree-bound PASS (unless --no-require-pass).
set -u
V="${APEX_VERDICT_FILE:-.builder/audit/verdict}"
require_pass=1
for a in "$@"; do
  case "$a" in
    --no-require-pass) require_pass=0 ;;
    *) echo "unknown arg: $a" >&2; exit 2 ;;
  esac
done
fail() { printf 'AUDIT GATE FAIL: %s\n' "$1" >&2; exit 1; }
[ -f "$V" ] || fail "no verdict file at $V"
[ "$(wc -l < "$V" | tr -d ' ')" -eq 1 ] || fail "verdict file must contain exactly one line"
line=$(sed -n '1p' "$V" | tr -d '\r')
fields=$(printf '%s' "$line" | awk -F'|' '{print NF}')
[ "$fields" -eq 6 ] || fail "malformed token (expected 6 fields, got $fields)"
magic=$(printf '%s' "$line" | awk -F'|' '{print $1}')
mile=$(printf '%s' "$line" | awk -F'|' '{print $2}')
tree=$(printf '%s' "$line" | awk -F'|' '{print $3}')
verdict=$(printf '%s' "$line" | awk -F'|' '{print $4}')
expiry=$(printf '%s' "$line" | awk -F'|' '{print $5}')
hmac=$(printf '%s' "$line" | awk -F'|' '{print $6}')
[ "$magic" = APEX1 ] || fail "bad token magic"
[ -n "$mile" ] && [ -n "$tree" ] && [ -n "$verdict" ] && [ -n "$expiry" ] && [ -n "$hmac" ] || fail "empty token field"
case "$verdict" in PASS|BLOCK|BLOCK:*) ;; *) fail "unknown verdict value" ;; esac
case "$expiry" in ''|*[!0-9]*) fail "bad expiry" ;; esac
[ "$expiry" -gt "$(date +%s)" ] || fail "verdict expired"
[ -n "${APEX_AUDIT_KEY:-}" ] || fail "APEX_AUDIT_KEY not set in verifier"
command -v openssl >/dev/null || fail "openssl required"
payload="APEX1|$mile|$tree|$verdict|$expiry"
expected=$(printf '%s' "$payload" | openssl dgst -sha256 -hmac "$APEX_AUDIT_KEY" | awk '{print $NF}')
[ "$hmac" = "$expected" ] || fail "bad signature (forged or tampered verdict)"
current_tree=$(git rev-parse 'HEAD^{tree}' 2>/dev/null) || fail "not a git repo"
[ "$tree" = "$current_tree" ] || fail "verdict bound to a different tree (stale or bypassed commit)"
if [ "$require_pass" -eq 1 ] && [ "$verdict" != PASS ]; then
  fail "verdict is not PASS: $verdict"
fi
printf 'AUDIT GATE OK: %s | milestone %s | tree %s\n' "$verdict" "$mile" "$tree"
exit 0
