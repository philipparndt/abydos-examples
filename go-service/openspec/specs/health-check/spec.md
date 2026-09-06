# Health check

## Purpose

What `/healthz` answers, and when.

## Requirements

### Requirement: The health endpoint answers ok

The service SHALL answer `200 ok` at `/healthz` from the moment it is
listening.

#### Scenario: a request while it is up

- **GIVEN** the service listening on 8080
- **WHEN** `/healthz` is requested
- **THEN** the response is `200` with the body `ok`
