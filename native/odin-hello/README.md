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
