## MODIFIED Requirements

### Requirement: The health endpoint answers ok

The service SHALL answer `200 ok` at `/healthz` once it is ready, and `503`
before that — readiness being a state a probe can wait for, which an endpoint
that is always `ok` cannot offer.

#### Scenario: a request before it is ready

- **GIVEN** the service listening, within the readiness delay
- **WHEN** `/healthz` is requested
- **THEN** the response is `503`

#### Scenario: a request once it is ready

- **GIVEN** the readiness delay passed
- **WHEN** `/healthz` is requested
- **THEN** the response is `200` with the body `ok`
