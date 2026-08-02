# smart-home-microservice

A service that will not start without being told where its configuration is,
with a page to look at while working on it. This is the shape most of the
smart-home bridges have, and it is the awkward one to develop in a cluster: the
pod has never seen the file.

- **here** runs it with `config/dev.json`.
- **in the cluster** sends that file into the pod first — it lands in
  `/app/files` and the argument is rewritten to point there — and publishes the
  service at `coffee.dev.local` as well as forwarding its port.

Try: run it in the cluster, open the link the launch log prints, press Toggle,
and watch the log. The page and the log both update on the change itself —
`/api/events` streams it — so nothing asks again on a timer. Then put a
breakpoint in `watch` and debug it there.
