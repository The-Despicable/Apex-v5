Corrected forms of the two shipped commands that the audit found broken.
These are documentation fixtures; verify.sh checks they are present and the broken forms absent.

Log-noise discovery (old form exited 2 with a regex parse error):
    rg -n "console\.log|print\(" src/

Playwright harvest failure handler (old form omitted the json import):
    import asyncio, json, random, sys
