# 4. The cluster run does not say what it is waiting for

Pressing **in the cluster** the first time puts the pod there, which takes as
long as pulling the image takes. The launch log says nothing between the push
and the first line of output, and a minute of nothing looks like a hang.

## Ruled out

A spinner with no words on it. The complaint is not that there is no motion,
it is that nobody can tell whether it is the pull, the schedule or the binary.

## Estimate

2026-09-04 16:10 — most of a morning left, mostly on the pull's own reporting.

## Steps

- [x] Find where the launch log is written from.
- [x] Report the pod's phase as it changes.
- [ ] Report the pull separately, since that is the slow one.
- [ ] Say the image's name, so a wrong tag is obvious.
- [ ] A line when it is listening, rather than only the service's own.
