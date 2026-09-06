# 5. Delve in the pod is older than the one here

The debug image carries whatever Delve was current when it was built, and
this machine's is newer. They talk to each other until they do not, and the
failure arrives as a step that goes to the wrong line.

Waiting on the image being rebuilt, which is not this repository's to do.

## Steps

- [x] Pin the version in the image and say which it is.
- [ ] Compare the two at launch and say so when they differ.
