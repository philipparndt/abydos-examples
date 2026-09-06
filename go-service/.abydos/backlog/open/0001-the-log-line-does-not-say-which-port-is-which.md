# 1. The log line does not say which port is which

`go-service listening on :8080, pprof on :6060` is one line for two servers,
and the second of them is started in a goroutine whose error nobody reads
until it is too late. Somebody profiling a pod that never bound 6060 sees a
service that started fine and a profiler that cannot connect.

## Steps

- [ ] Log each listener as it binds, not both before either.
- [ ] Fail the process when pprof cannot bind, rather than logging it.
