# 3. A health check that can fail

`/healthz` writes `ok` unconditionally, which makes it useless as an example
of a readiness probe: a pod that is not ready is exactly the state somebody
wants to see the editor report.

## Steps

- [ ] Hold a `ready` flag, false for the first few seconds after start.
- [ ] 503 while it is false, so a probe has something to wait for.
- [ ] Say in the README that the first requests are meant to fail.
