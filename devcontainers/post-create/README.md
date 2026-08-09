# post-create

A devcontainer that installs its tools after it is created. **Abydos refuses
this one**, and that is what it is for.

> .devcontainer/devcontainer.json has a postCreateCommand, and this app does not
> run the lifecycle commands yet — the container would come up without whatever
> that command installs.

Refusing is the deliberate choice here, and the loudest of the three. Reading
`postCreateCommand` and quietly not running it would give somebody a container
that looks right and is missing exactly the tools the project needs, for a
reason nothing on screen explains.

`.devcontainer/post-create.sh` takes about fifteen seconds and prints a line a
second while it works. That is not padding: a lifecycle command is the one
thing in a devcontainer that can take minutes, and step 5 of 0424 is as much
about showing it happening as about running it. Run it by hand to see what the
progress ought to look like:

```sh
docker run --rm -v "$PWD:/w" -w /w alpine:3.21 sh .devcontainer/post-create.sh
```

`post-create-fails` beside this one is the other half: the same shape, with a
command that does not succeed.
