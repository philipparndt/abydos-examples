# post-create

A devcontainer that installs its tools after it is created. **Abydos runs it**,
and reports it happening, which is what this project is for.

Opening a terminal in it shows the command being run before the shell appears:

```
Running post-create's postCreateCommand: sh .devcontainer/post-create.sh…
```

and the pane that reported it becomes the shell in the finished container. Then
`jq` is on the path — a package the image deliberately does not carry, so
finding it there is the command having really run rather than having been read.

Everything the command printed goes to `~/Library/Logs/Abydos/devcontainer.log`,
because a `postCreateCommand` is the one thing in a devcontainer that can print
for ten minutes and a notification per line would be worse than silence.

`.devcontainer/post-create.sh` takes about fifteen seconds and prints a line a
second while it works. That is not padding: a lifecycle command is the one thing
in a devcontainer that can take minutes, and step 5 of 0424 was as much about
showing it happening as about running it. Run it by hand to see what the
progress ought to look like:

```sh
docker run --rm -v "$PWD:/w" -w /w alpine:3.21 sh .devcontainer/post-create.sh
```

**This project was refused until 2026-08-09**, when the lifecycle commands
started running. The file did not change; Abydos did.

`post-create-fails` beside this one is the other half: the same shape, with a
command that does not succeed.
