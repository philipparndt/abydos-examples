# features

A devcontainer that installs two features. **Abydos refuses this one**, and
that is what it is for.

Open this folder as a project, choose **View ▸ New Terminal in Container**, and
what arrives is a message rather than a shell:

> .devcontainer/devcontainer.json installs devcontainer features
> (ghcr.io/devcontainers/features/github-cli:1), which this app does not build —
> put what they provide into the image or the Dockerfile the file names.

Which names the feature it found and says what to do instead — `dockerfile-build`
beside this one is the "do it in the Dockerfile" answer.

Nothing here is broken or half-written: this is a file `devcontainer up` builds
without complaint. The refusal is a statement about Abydos, not about the file,
and the file is the fixture the feature will be built against when somebody
implements it.
