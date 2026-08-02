# odin-hello

A small Odin program, written the way Odin is written: `::` for constants and
procedures, snake_case names, explicit allocators, and `defer` for the cleanup.

`coldest` is the one to put a breakpoint in — it walks a slice and keeps the
extreme, so every pass changes something worth looking at.

```sh
make build   # odin build src -out:build/odin-hello -debug
make run
```

Needs the Odin compiler: `brew install odin`.

## In a cluster

There is a second configuration, **in the cluster**, and it works — which is
less obvious than it sounds. Odin's own linker refuses to make a Linux binary
on a Mac:

    Linking for cross compilation for this platform is not yet supported

So the build happens in two steps: Odin emits the objects for `linux_amd64` or
`linux_arm64`, and zig's linker — which cross-links happily — turns them into a
static ELF. That is what gets pushed into the development pod. `brew install
zig` is the only extra thing needed.

Debugging it there is not possible yet: the debugger in the pod is Delve, which
is Go's.
