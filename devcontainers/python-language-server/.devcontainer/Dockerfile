# Python, and pyright — which is a Node program that reads Python.
#
# `ToolImages/gopls/Dockerfile` in the Abydos repository argues at length that a
# language server needs the toolchain it is a front end for beside it in the
# image, and why a bare binary is the failure that reads as "the editor is
# broken". That argument is not repeated here; it applies, and here it applies
# twice over, because pyright is two things away from a static binary:
#
#   * it is written in TypeScript and runs on Node, so a Python image with no
#     Node in it cannot start the server at all; and
#   * it carries typeshed, so it answers about the standard library with no
#     interpreter anywhere — and then knows nothing about anything pip
#     installed, because site-packages is found by asking the interpreter.
#
# So: the Python image with Node added, rather than the Node image with Python
# added. The project is Python; the toolchain it is worked on is the one named
# on the line below.
FROM python:3.12-alpine3.21

# nodejs and npm out of alpine rather than mcr.microsoft.com/devcontainers/python,
# which carries both and is over a gigabyte. Anybody who opens this example
# pulls whatever it names, so it names the small one.
RUN apk add --no-cache nodejs npm

# Pinned, for the reason the gopls image pins gopls: the version is a decision
# about which answers a project gets, and this is the place to say which one.
#
# In the image rather than in a postCreateCommand, which is the other way this
# could have been done and is written down in the README beside this file.
ARG PYRIGHT_VERSION=1.1.411
RUN npm install -g pyright@${PYRIGHT_VERSION} && npm cache clean --force

# The name Abydos looks for, asserted while the image is built rather than
# discovered ten seconds into a failed handshake. `pyright-langserver --stdio`
# is what it runs — the server, not the `pyright` command-line checker that the
# same package installs beside it.
RUN command -v pyright-langserver
