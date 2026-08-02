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

Odin and Zig also **run** in a cluster — see odin-hello's README for how a
Linux binary gets built on a Mac. Debugging them there is not built yet: the
debugger in the pod is Delve, which is Go's.
