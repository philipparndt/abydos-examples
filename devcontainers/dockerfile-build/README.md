# dockerfile-build

A devcontainer built from a Dockerfile instead of pulled from a registry, with
`build.context`, `build.args` and `build.target` all doing something you can
see from inside it.

Open this folder as a project and choose **View ▸ New Terminal in Container**.
The first time takes as long as `docker build` does; after that it is instant.

Three things to check in that terminal, one per field:

```sh
abydos-hello                 # context: ".." — the script lives in the project root
jq --version                 # args: EXTRA=jq
ls /etc/abydos-wrong-stage   # target: development — this must NOT exist
```

The image is kept as `abydos-devcontainer:dockerfile-build`. Nothing removes it
yet, which is the "rebuilding" question 0424 leaves open; `docker rmi` it by
hand after changing the Dockerfile until that has an answer.
