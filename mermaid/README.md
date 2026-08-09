# mermaid

Six diagrams and nothing to install. Open `render.mmd`: the source is on the
left, the drawing on the right, and the drawing follows the text as it is
typed. Unlike [plantuml](../plantuml) beside it there is no image to fetch, no
container runtime to have running and no `tools.json` — Mermaid is a JavaScript
bundle inside the app, drawn in a web view that reaches nowhere. A machine with
nothing on it and no network at all draws all six.

Right-click the drawing, or the file in the tree, for **Export ▸ PNG** and
**Export ▸ SVG**: the picture is written beside the source as `render.png` or
`render.svg`, the same rules as PlantUML's export. Nothing is written for a
diagram that does not parse, and a picture this app did not draw is never
written over.

## The diagrams

| file | what it is | what it exercises |
|---|---|---|
| [render.mmd](render.mmd) | how a `.mmd` becomes the picture beside it | a flowchart: shaped nodes, edge labels, labels wrapped onto rows |
| [export.mermaid](export.mermaid) | what happens between the menu item and the file appearing in the tree | a sequence diagram, `autonumber` and an `alt` block — and the other extension |
| [document.mmd](document.mmd) | a file open in the editor, and the states it is in | a state diagram with a composite state in it |
| [preview.mmd](preview.mmd) | the pieces behind a preview pane | a class diagram: inheritance, composition, dependency, stereotypes |
| [project.mmd](project.mmd) | what a project keeps beside itself in `.abydos` | an entity-relationship diagram, crow's feet and attributes |
| [branches.mmd](branches.mmd) | the shape `git-scenarios/out/merge-conflict` is built into | a git graph, which shares no layout code with any of the above |

Six rather than two on purpose. Mermaid is not one renderer: a flowchart, a
sequence diagram and a git graph are laid out by three different pieces of code
that agree only about the file they come out of. The faults worth finding are
the ones where a diagram *draws* and is the wrong picture — an edge filled
solid black, an arrowhead missing, a label above its box instead of in it — and
those are found per diagram type, by looking, not by parsing.

## Both extensions

`.mmd` is what Mermaid's own `mmdc` reads and writes; `.mermaid` is what a few
editors use. Both open with the same pane and the same export menu, which is
why `export.mermaid` is the one file here that is not a `.mmd`.

A ```` ```mermaid ```` fence inside a Markdown file is the commoner place for a
diagram to live, and it is deliberately not drawn yet — so a fenced block in
one of this repository's READMEs is still text.

## No pictures are committed

The same rule as `plantuml/`: the sources are here and the pictures are not.
Export writes `render.png` beside `render.mmd` whenever you want to look at
one, and both formats are ignored by git only in the sense that nobody has
committed them — check before you add a picture that a diagram already makes.

## One thing worth knowing about comments

A comment line is `%%` followed by something. A line that is **exactly** `%%`
is not removed by Mermaid before parsing, and in a **flowchart** — only there —
it stops the diagram being recognised at all, with a complaint about line 1
that has nothing to do with line 1:

```
Expecting 'NEWLINE', 'SPACE', 'GRAPH', got 'NODE_STRING'
```

Every header here is written without one for that reason. Inside the body of a
flowchart, and anywhere in the other five diagram types, a bare `%%` is
harmless. It is Mermaid's own behaviour rather than the editor's, and it is
written down here because the message names the wrong place and costs an hour.
