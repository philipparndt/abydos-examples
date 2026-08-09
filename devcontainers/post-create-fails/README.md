# post-create-fails

The same refusal as `post-create` beside it — the sentence names the field it
found, not the command, so both files produce it word for word:

> .devcontainer/devcontainer.json has a postCreateCommand, and this app does not
> run the lifecycle commands yet — the container would come up without whatever
> that command installs.

They are two fixtures rather than one because of what happens *after* step 5 of
0424 lands. This one's command fails, three steps in, with a message on stderr
and an exit code of 3:

```sh
docker run --rm -v "$PWD:/w" -w /w alpine:3.21 sh .devcontainer/post-create.sh; echo "exit $?"
```

Two things it is there to pin down. A failure has to be reported as *this
command, this output* — "the container could not be created" is the message
that sends somebody looking for a log nobody kept. And the `postStartCommand`
below it must not run at all: a container that went on to start what it was
told to start, after its tools failed to install, is the half-built state the
refusal exists to avoid.
