# go-service

A backend with nothing in it but the shape of one: an HTTP handler, a health
check, and pprof.

- **here** runs it on this machine.
- **in the cluster** builds it for the cluster's architecture, pushes it into a
  development pod and runs it there. Nothing is installed by hand: pressing run
  puts the pod there the first time.

Try, in order: run it here and open http://localhost:8080/api/things. Then run
it in the cluster and follow the link in the launch log. Then put a breakpoint
in `things` and debug — in the cluster, the breakpoint is hit in the cluster.
Then press Profile, which forwards the pod's pprof port and connects.

## In a container

`.devcontainer/devcontainer.json` is the plainest one there is: an image, and
nothing else. Open this folder as a project and choose **View ▸ New Terminal in
Container** — the toolchain in that shell is `golang:1.24-alpine`'s, not this
machine's, and the checkout is bind-mounted so git and the editor go on working
here. `../devcontainers` has the rest of them.

## The panel

This is also the project with something in the bottom panel. `.abydos/backlog`
holds six invented items across five states, and `openspec/` holds three
changes — one part-way, one nearly done, and one with no `tasks.md`, which is
meant to show no fraction rather than `0/0`. ⇧⌘B opens the backlog; the board
and the list are the same files either way, and `abydos-backlog list` in a
terminal here reads exactly what the panel draws.

None of it is work anybody is waiting for. It is there so the panes have
something to draw that is not empty.
