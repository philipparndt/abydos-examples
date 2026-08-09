# post-create-fails

The other half of `post-create` beside it: the same shape, with a command that
does not succeed. **Abydos runs it, and says which command failed and what it
said**:

> post-create-fails's postCreateCommand exited 3: error: no such package:
> a-package-that-does-not-exist. The container was removed and nothing after it
> was run — fix `sh .devcontainer/post-create.sh` in the devcontainer.json and
> open the project again.

The command fails three steps in, with a message on stderr and an exit code of
3:

```sh
docker run --rm -v "$PWD:/w" -w /w alpine:3.21 sh .devcontainer/post-create.sh; echo "exit $?"
```

Three things it is there to pin down. A failure has to be reported as *this
command, this output* — "the container could not be created" is the message that
sends somebody looking for a log nobody kept. The line quoted is the last one on
**standard error**, because a command that fails writes the reason there and its
progress to the other stream: the last line of standard output is "step 3 of 3",
which says how far it got and not what went wrong. And the `postStartCommand`
below it must not run at all, and the container is removed rather than left
running — a container that went on to start what it was told to start, after its
tools failed to install, is the half-built state this exists to prevent.

**This project was refused until 2026-08-09**, when the lifecycle commands
started running. The file did not change; Abydos did.
