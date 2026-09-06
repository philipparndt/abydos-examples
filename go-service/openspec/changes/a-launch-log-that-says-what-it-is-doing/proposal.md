## Why

Pressing **in the cluster** the first time takes as long as pulling the image
takes, and the launch log says nothing between the push and the first line of
the service's own output. A minute of nothing looks like a hang.

From backlog item 4.

## What Changes

- The launch log reports the pod's phase as it changes, and the pull
  separately from the schedule.
- The image's name is written out, so a wrong tag is obvious rather than slow.
