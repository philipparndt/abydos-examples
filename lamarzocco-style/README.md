# lamarzocco-style

A service that will not start without being told where its configuration is,
with a page to look at while working on it. This is the shape most of the
smart-home bridges have, and it is the awkward one to develop in a cluster: the
pod has never seen the file.

- **here** runs it with `config/dev.json`.
- **in the cluster** sends that file into the pod first — it lands in
  `/app/files` and the argument is rewritten to point there — and publishes the
  service at `lamarzocco.dev.local` as well as forwarding its port.

Try: run it in the cluster, open the link the launch log prints, press Toggle,
and watch the log. Then put a breakpoint in `poll` and debug it there.
