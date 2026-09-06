# openscad

Two files, no setup. The model is re-rendered from the file on disk, so saving
is the only step.

| file | what it is for |
|---|---|
| [adapter-feder.scad](adapter-feder.scad) | a part that exists because something had to fit: twenty-nine named values at the top, seven of them worked out from the other twenty-two |
| [dollhouse.scad](dollhouse.scad) | the same loop at a metre of house: a model the preview has to be framed around |

`adapter-feder.scad` is an adapter for a Hubelino marble machine — a curved
web on an axle, a paddle end cut at 30°, and a blind hole aimed at where a
printed spring used to be. Change `stegLaenge`, `federStart` or `schnittWinkel`
and the preview follows; the interesting ones are the derived values, because
`bohrRi` — which way the hole points — is computed back through the same chain
of rotations that places the end piece, so moving the end piece moves the hole
with it.

One module is deliberately not called. `feder()` draws the printed spring the
part used to carry, and `stegUndFeder()` has the call commented out: a steel
spring in the blind hole replaced it, and the spring's parameters stay because
they are what say where that hole has to point. So the structure pane lists a
module the render does not contain, on purpose.

It is also the file to read if you have ever exported something that would not
slice. Three of its comments are about that and are worth more than the shape:
a union of two polygonisations of the same arc left 291 non-manifold edges, two
coplanar end faces made a solid of genus 17 rather than 0, and a flush top face
had to be raised 0.1 mm to stop the deck surfaces coinciding. `openscad -o
out.stl adapter-feder.scad` prints the verdict — *manifold*, *Genus 0*, 2,653
vertices, in about a twentieth of a second.

`dollhouse.scad` is the one to open second. Nothing in it is a fixed number
twice: move `ridge_x`, and the right roof pitch, both panel lengths, the mitre
angle and the height of the attic partition all follow. Set `explode = 150` to
take it apart, and read the cut list it prints to the console — the parts, the
angles, and a handful of checks that say when a window has run into the floor
above it.

Worth trying: the structure pane lists the modules; go-to-definition on
`steg(...)`, `endstueck(...)` or `plate(...)` jumps to it.

The comments in `adapter-feder.scad` are in German, as its author wrote them.
