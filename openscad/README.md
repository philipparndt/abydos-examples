# openscad

Two files, no setup. The model is re-rendered from the file on disk, so saving
is the only step.

| file | what it is for |
|---|---|
| [bracket.scad](bracket.scad) | small enough to hold in your head — change `depth` or `fillet` and watch the preview follow |
| [dollhouse.scad](dollhouse.scad) | the same loop at a metre of house: a model the preview has to be framed around |

`dollhouse.scad` is the one to open second. Nothing in it is a fixed number
twice: move `ridge_x`, and the right roof pitch, both panel lengths, the mitre
angle and the height of the attic partition all follow. Set `explode = 150` to
take it apart, and read the cut list it prints to the console — the parts, the
angles, and a handful of checks that say when a window has run into the floor
above it.

Worth trying: the structure pane lists the modules; go-to-definition on
`plate(...)` or `above_roof()` jumps to it.
