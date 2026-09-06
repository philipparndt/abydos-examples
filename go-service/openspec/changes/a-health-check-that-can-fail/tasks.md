## 1. The flag

- [x] 1.1 A `ready` flag, set by a timer a few seconds after the listener binds.
- [x] 1.2 `/healthz` answers `503 starting` while it is false.
- [ ] 1.3 The delay is a flag rather than a constant, so a run can make it long enough to watch.

## 2. Saying so

- [ ] 2.1 The README says the first requests fail on purpose.
- [ ] 2.2 The cluster launch configuration gets a readiness probe pointing at it.
