## Why

`/healthz` writes `ok` unconditionally, so it cannot show what a readiness
probe is for. A pod that is not ready yet is exactly the state somebody opens
this example to watch the editor report, and this endpoint never reaches it.

From backlog item 3.

## What Changes

- **The service holds a `ready` flag**, false for the first few seconds after
  start, and answers `503` while it is false.
- The README says the first requests are meant to fail, so that nobody reads
  it as the example being broken.
