# substitutions

Every `${...}` the reader answers, and the three fields it passes straight to
the runtime, in one file small enough to hold in your head.

Open this folder as a project, choose **View ▸ New Terminal in Container**, and:

```sh
env | grep ^ABYDOS_ | sort   # the five that resolved, and the one that did not
pwd                          # /src, from workspaceMount + workspaceFolder
cat /etc/hostname            # abydos-substitutions, from runArgs
mount | grep /scratch        # tmpfs, from mounts
```

`ABYDOS_UNKNOWN` comes through as the literal `${somethingNobodyDefined}`. That
is deliberate on both sides: a substitution nobody defined is left as written,
because rewriting it to the empty string would silently change a value instead
of leaving it visibly unhandled.

Set `ABYDOS_EXAMPLE_TOKEN` on this machine and open it again to watch
`ABYDOS_TOKEN` change — that is `${localEnv:NAME:fallback}` doing its job, and
it is how a devcontainer takes a secret from the host without committing one.

## What is deliberately not here

`${containerEnv:PATH}` and friends. Their values only exist once the container
is running, so the file is refused rather than guessed at:

> …uses ${containerEnv:PATH}, whose value only exists once the container is
> running, and this app cannot read it before starting one.

Add one to the file above and you can watch it say so.
