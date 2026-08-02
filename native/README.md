# native

Five small programs in five languages, each with the same shape: something to
print, a function worth stepping into, and a `make build` that produces a
binary with debug information in it.

Each carries one configuration, **here**, which builds with make and then runs
the binary under LLDB. Put a breakpoint in the function that picks the warmest
or coldest reading and press debug.

| project | built by |
|---|---|
| odin-hello | `odin build src -debug` |
| zig-hello | `zig build` |
| rust-hello | `cargo build` |
| c-hello | `cc -g -O0` |
| cpp-hello | `c++ -g -O0 -std=c++20` |

All four also **run** in a cluster — each has an **in the cluster**
configuration — and the Linux binary is built here, on a Mac:

| project | how it cross-compiles |
|---|---|
| zig-hello | `zig build -Dtarget=aarch64-linux-musl` |
| odin-hello | Odin emits the objects, zig's linker takes them — its own cannot |
| c-hello | `zig cc -target aarch64-linux-musl` |
| cpp-hello | `zig c++ -target aarch64-linux-musl` |
| rust-hello | `cargo build --target aarch64-unknown-linux-musl`, linked by zig |

So `brew install zig` covers four of them, and Rust wants its own standard
library for the target as well:

    rustup target add aarch64-unknown-linux-musl

Debugging them in a cluster is not built yet: the debugger in the pod is
Delve, which is Go's. They run there; you step through them here.
