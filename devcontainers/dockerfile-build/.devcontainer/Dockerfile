# Three stages, so that `build.target` has something to choose between.
#
# Kept on Alpine deliberately: anybody who opens this example builds it, and a
# base nobody needed is a download nobody asked for.

ARG ALPINE=3.21
FROM alpine:${ALPINE} AS base
RUN apk add --no-cache git make

# What build.target names. Whatever build.args asked for goes on top, and the
# project's own script comes in from the context a level above .devcontainer.
FROM base AS development
ARG EXTRA=""
RUN [ -z "$EXTRA" ] || apk add --no-cache $EXTRA
COPY tools/hello.sh /usr/local/bin/abydos-hello
RUN chmod +x /usr/local/bin/abydos-hello

# Never built, because target stops above. If this file ever appears inside the
# container, `target` was not honoured.
FROM base AS shipping
RUN echo "the wrong stage was built" > /etc/abydos-wrong-stage
