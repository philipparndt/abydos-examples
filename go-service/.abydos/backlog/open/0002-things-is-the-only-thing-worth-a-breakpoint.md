# 2. `things()` is the only thing worth a breakpoint

There is one function with a loop in it, so every debugging example in the
repository stops on the same line. A second shape — a call into a call, with
an argument worth looking at in the variables pane — would give stepping
somewhere to go.

## Ruled out

Adding a dependency to get a call stack worth stepping through. The point of
this example is that it builds with nothing installed.

## Steps

- [ ] A handler that calls something that calls something.
- [ ] A value that is wrong on the third iteration and not before.
