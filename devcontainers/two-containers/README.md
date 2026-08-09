# two-containers

A project that offers a choice of two containers to work in, which is what
`.devcontainer/<name>/devcontainer.json` is for. **Abydos offers both**, in the
menu behind the `+` at the end of the terminal tabs:

```
New Terminal
New Terminal in Small ⬢
New Terminal in With a Go toolchain ⬢
```

Each entry is named after its own file's `name`, and after the folder the file
sits in when it has none — `.devcontainer/go` would be "go". That naming is the
whole of why both can be offered: two entries both reading "Container" would say
less than the refusal this used to be.

Opening a terminal in each gives two containers up at once, for one project,
each with its own shell:

```
IN:/workspaces/two-containers:abydos-devcontainer-22709-1
IN:/workspaces/two-containers:abydos-devcontainer-22709-2
```

The names are sorted rather than taken in whatever order the file system
answered in, so which one is offered first is a fact about the names.

**This project was refused until 2026-08-09**, and the reason is worth keeping:
picking the first quietly would have been picking somebody's toolchain for them,
and they would have found out by typing `go` and being told there is no such
thing. What changed is not the reader — it is that there is now a menu to ask
in. The View menu's single **New Terminal in Container** item cannot hold a
list, so it opens the first and says which one that is in its title; the `+`
chevron is where all of them are.

One thing is still chosen rather than asked: **the language servers go in the
first container**, because a server starts when a file is opened and there is no
gesture behind it to attach a question to. Abydos says so once, in a notification,
rather than choosing silently.
