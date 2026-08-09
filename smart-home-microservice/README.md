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

## In a container

`.devcontainer/devcontainer.json` forwards both ports this service listens on,
so `go run . config/dev.json` in a **View ▸ New Terminal in Container** shell is
reachable at http://127.0.0.1:8080/ from the browser here, with pprof on 6060.
It also sets `STAGE` on the container and `SMART_HOME_CONFIG` on the shells
started inside it, which are deliberately not the same thing.
`../devcontainers` has the rest of them.
