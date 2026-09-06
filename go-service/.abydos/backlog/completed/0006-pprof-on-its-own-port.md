# 6. pprof on its own port

Serving pprof on the same mux as the API meant that forwarding the profiler's
port forwarded the API with it, and a profile taken through that port
measured the forwarding as much as the service.

## Steps

- [x] A second listener on 6060, with the default mux.
- [x] Forward only that port from the launch configuration.
- [x] Check that a profile taken in the cluster names the handler.
