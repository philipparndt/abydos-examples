//! Small enough to read, with something worth stepping through: a loop, a
//! function with an argument, and a value that changes on every pass.
const std = @import("std");

fn fib(n: u64) u64 {
    if (n < 2) return n;
    var a: u64 = 0;
    var b: u64 = 1;
    var i: u64 = 2;
    while (i <= n) : (i += 1) {
        const next = a + b;
        a = b;
        b = next;
    }
    return b;
}

pub fn main() !void {
    var i: u64 = 1;
    while (i <= 10) : (i += 1) {
        std.debug.print("fib({d}) = {d}\n", .{ i, fib(i) });
    }
}
