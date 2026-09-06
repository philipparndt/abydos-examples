# go-service

A backend with nothing in it but the shape of one, and a backlog to match:
the items below are invented, and they are here so that the panel has
something to draw. Nothing in this folder is work anybody is waiting for.

## What it is

An HTTP service with three handlers — a greeting, a health check and
`/api/things` — and pprof on a second port. It exists to be run here, run in
a development cluster, have a breakpoint put in it, and be profiled. Every
other concern a real service has is a different example in this repository.

## How it is built and run

```sh
go build -o build/go-service .    # or: make build, from the top
```

Two launch configurations, both in `.abydos/run`: **here** runs it on this
machine, **in the cluster** cross-compiles it, pushes it into a development
pod and holds it there under Delve. Neither needs anything installed by hand.

## How it is laid out

One file. `main.go` is the whole of it, and `things()` at the bottom is the
function to put a breakpoint in.

## What the code is like

Small enough to read at once, and meant to stay that way. A handler that
needs a second file is a sign the example has grown past what it is for.

## What not to do here

Do not give it a database, a configuration file or a front end. Those exist
as `smart-home-microservice` and `multi-tier`, and the reason there are three
projects rather than one is that each is small enough to hold in your head.
