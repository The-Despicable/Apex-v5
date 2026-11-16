#!/bin/sh
# APEX v5 — sign an audit verdict. Run by the AUDIT ROLE / CI only.
# The signing key must never be available to the builder role.
# Usage: APEX_AUDIT_KEY=<secret> sh sign-verdict.sh PASS|BLOCK[:reason] <milestone>
set -eu
: "${APEX_AUDIT_KEY:?APEX_AUDIT_KEY must be set (audit role only)}"
verdict="${1:-}"
milestone="${2:-M1}"
case "$verdict" in
  PASS|BLOCK|BLOCK:*) ;;
  *) echo "usage: sign-verdict.sh PASS|BLOCK[:reason] <milestone>" >&2; exit 2 ;;
esac
command -v openssl >/dev/null || { echo "openssl required" >&2; exit 2; }
tree=$(git rev-parse 'HEAD^{tree}')
expiry=$(( $(date +%s) + 86400 ))
payload="APEX1|$milestone|$tree|$verdict|$expiry"
hmac=$(printf '%s' "$payload" | openssl dgst -sha256 -hmac "$APEX_AUDIT_KEY" | awk '{print $NF}')
mkdir -p .builder/audit
printf '%s|%s\n' "$payload" "$hmac" > .builder/audit/verdict
printf 'signed %s | tree %s | milestone %s | expires %s\n' "$verdict" "$tree" "$milestone" "$expiry"
