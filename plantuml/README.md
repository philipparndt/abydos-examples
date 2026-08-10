# plantuml

Four diagrams and no PlantUML. Open `render.puml`: the source is on the left,
the drawing on the right, and the drawing follows the text as it is typed. What
draws it is `.abydos/tools.json` —

```json
{ "plantuml": "plantuml/plantuml:1.2026.6" }
```

— an image, run by whichever container runtime is on the machine. Nothing to
install, nothing to keep in step with anybody, and the version is the
repository's answer rather than each machine's.

## The diagrams

| file | what it is | needs Graphviz |
|---|---|---|
| [render.puml](render.puml) | how the pane on the right gets its picture | no |
| [discovery.puml](discovery.puml) | which PlantUML draws it, and in which order that is asked | no |
| [cluster.puml](cluster.puml) | the `multi-tier` example, as its chart deploys it | yes |
| [debug.puml](debug.puml) | what the native examples do between the press and the breakpoint | yes |

The Graphviz column is the point of the last two. PlantUML lays out sequence
and activity diagrams itself; everything else it hands to `dot`, so a machine
with the jar but no Graphviz draws the first two and shows an empty pane for
the other two. The image carries both, so all four come back.

## Both runtimes

Apple's `container` is looked for first, then `docker`, `nerdctl`, `podman` —
they all take the three flags this needs. Apple's is first because it answers
without a daemon having been started first, which is the difference between a
feature that works after a restart and one that says "cannot connect". Either
way the render is `run --rm -i`: the diagram goes in on standard input, the
picture comes back on standard output, and nothing is mounted, so the container
never sees the project and never writes a `.png` beside somebody's source.

Same thing from a terminal, if you would rather watch it once:

```sh
./draw.sh          # or: make diagrams, from the top of the repository
```

The first draw fetches the image, so it takes as long as a pull. After that it
is the time to start a JVM.

## Worth trying

Delete `.abydos/tools.json` and the diagrams are drawn by whatever is on the
machine instead — `plantuml` on the PATH, or a jar named by `PLANTUML_JAR`, or
one where the downloads land. Put it back and the image wins again: a named
image beats a local install, because pinning it is how the same file comes to
look the same on two machines. With neither, the pane says in one sentence what
to install.

Settings say the same thing for one person across every project, for somebody
who would rather not install a Java toolchain at all. The file wins where both
speak.

Note that this project's `.abydos/.gitignore` has a line the app does not
write: `!tools.json`. The generated one ignores everything but the run
configurations, which would leave the file everybody is meant to share
untracked.
