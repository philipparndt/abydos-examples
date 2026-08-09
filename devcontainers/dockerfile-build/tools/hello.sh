#!/bin/sh
# Copied into the image by the Dockerfile, from a directory that only exists in
# the project root — so finding it on the PATH inside the container is what
# proves `build.context: ".."` was honoured.
echo "abydos-hello: built from this project's own context"
