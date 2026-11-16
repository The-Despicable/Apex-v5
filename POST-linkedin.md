I audited an AI engineering persona that advertised hook-enforced audit independence [C-audit-repro].

Clean repo. Shipped hook installed byte-for-byte. BLOCK verdict in place, a file staged under auth/:

  control                          exit 1  (rejected)
  echo PASS > .builder/audit/verdict  exit 0  (committed)
  git commit -n                       exit 0  (committed)
  git config core.hooksPath emptyhooks exit 0 (committed)

Three bypasses. The hook's own message said the builder could not edit the verdict. A shell redirect is not an edit tool, and -n is a git feature no local hook can stop.

The deeper finding was not the hook. The persona claimed "evals that prove the organs work" — there were no fixtures, no harness, and no executed eval [C-evals-not-run]. Its "no theater" table listed ten organs with a check that proves each ran. One check was executable [C-no-theater-1of10].

That is a category error: rules for the agent ("cite file:line") were written in the same confident register as claims about the system ("this is enforced"). Readers cannot tell which sentence to trust.

So I rebuilt it. Apex v5 has three layers:

1. Normative rules — no marker, no proof needed.
2. Descriptive claims — every one carries a a bracketed claim marker resolving to a public claim ledger with evidence and status [C-claims-resolve].
3. One enforced control — a signed verdict bound to a git tree hash, expiry and HMAC, verified in CI on every push. The local hook is explicitly advisory [C-ci-gate].

The receipt is runnable: sh verify/verify.sh regenerates the evidence file from real command output [C-evidence-generated]. Current run: 10/10 bypass and tamper probes rejected, 11/11 clean-room install commands passed [C-bypass-suite] [C-install-smoke].

What v5 will not claim: the local hook is still bypassable — CI is the control; behavioral evals were designed but not executed; and no token scheme survives a builder who holds the signing key. Key custody is stated as an assumption [C-key-custody].

An artifact is only as credible as its weakest unbacked sentence. Full audit and code in the first comment.

#softwareengineering #devtools #engineeringculture
