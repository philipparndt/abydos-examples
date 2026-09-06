## Why

`things()` is the only function in the service with a loop in it, so every
debugging example in the repository stops on the same line. Stepping has
nowhere to go: no call into a call, and no argument worth opening in the
variables pane.

From backlog item 2.

## What Changes

- A handler that calls something that calls something, with a value that is
  wrong on the third iteration and right on the others.

This change has no `tasks.md` yet, which is the point of it being here: a
change nobody has broken down shows no fraction, rather than `0/0`.
