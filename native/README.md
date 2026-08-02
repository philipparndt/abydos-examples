# native

Four small programs in four languages, each with the same shape: something to
print, a function worth stepping into, and a `make build` that produces a
binary with debug information in it.

Each carries one configuration, **here**, which builds with make and then runs
the binary under LLDB. Put a breakpoint in the function that picks the warmest
or coldest reading and press debug.

| project | built by |
|---|---|
| zig-hello | `zig build` |
| rust-hello | `cargo build` |
| c-hello | `cc -g -O0` |
| cpp-hello | `c++ -g -O0 -std=c++20` |

Debugging these in a cluster is not built yet: the development pod runs any
static binary, but the debugger it starts is Delve, which is Go's.
