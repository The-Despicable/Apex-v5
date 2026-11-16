#!/bin/sh
# APEX v5 — structural lint of the persona file. Checks the V2 contract only;
# it does NOT claim to verify behavior or evidence (that is verify.sh's job).
set -u
F=/home/yaser/apex-v5/persona/apex.md
pass=0; fail=0
ok() { echo "PASS  $1"; pass=$((pass+1)); }
bad() { echo "FAIL  $1"; fail=$((fail+1)); }
[ -f "$F" ] || { echo 'FAIL  persona file missing'; exit 1; }
head -n 1 "$F" | grep -qx -- '---' && ok 'V2 frontmatter opens' || bad 'frontmatter opens'
awk 'NR>1 && $0=="---"{exit} NR>1{print}' "$F" | grep -q '^description:' && ok 'description present' || bad 'description missing'
awk 'NR>1 && $0=="---"{exit} NR>1{print}' "$F" | grep -q '^mode: primary' && ok 'mode primary' || bad 'mode'
desc=$(awk 'NR>1 && $0=="---"{exit} NR>1 && /^description:/{sub(/^description: */,""); gsub(/"/,""); print; exit}' "$F")
n=$(printf '%s' "$desc" | wc -c | tr -d ' ')
[ "$n" -le 300 ] && ok "description $n chars <= 300" || bad "description $n chars"
for v1 in 'permission:' 'tools:' 'temperature:' 'maxSteps:'; do
  awk 'NR>1 && $0=="---"{exit} NR>1{print}' "$F" | grep -q "^  $v1" && bad "V1 field $v1" || true
done
ok 'V1 field scan complete'
lines=$(wc -l < "$F" | tr -d ' ')
[ "$lines" -le 500 ] && ok "persona $lines lines <= 500" || bad "persona too long"
printf '\nStructural lint: %d passed, %d failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ] || exit 1
exit 0
