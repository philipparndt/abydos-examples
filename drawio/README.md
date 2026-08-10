# drawio

**Abydos opens these in draw.io's own editor.** Double-click `plain.drawio`
and the real thing appears in the pane — shape sidebar, format panel, page tabs
along the bottom — editing the file the tab is showing. Drag a box and the tab
grows its edited dot; ⌘S writes the file back the way it came, compressed if it
came compressed. Nothing is installed, nothing is fetched, and the machine can
be offline: draw.io is vendored inside the app.

There is no source half, deliberately. A `.drawio` is an editor's document
rather than text somebody types, and a text editor open on the same file beside
draw.io — neither aware of the other's edits — is the one way this could lose
work.

`architecture.drawio.svg` is the exception and stays a picture: it genuinely is
an SVG, it renders here and on GitHub as one, and the editor is one `.drawio`
away.

## The four

| file | what it is | why this one |
|---|---|---|
| [plain.drawio](plain.drawio) | one page, an uncompressed `<mxGraphModel>` | the readable form: open it and the diagram is right there as XML. Rare in the wild, and the only one anybody can check by eye — and the one that proves a plain file is written back plain |
| [pages.drawio](pages.drawio) | three pages, compressed | the normal form, and both hard parts at once — **all 155** templates draw.io ships are compressed, and a three-page file has no single picture to draw or to export |
| [stencils.drawio](stencils.drawio) | four AWS shapes, compressed | the failure that would have been silent. Shape libraries are fetched lazily by style prefix at draw time; offline and without the vendored bundles they simply do not appear, with no error, and the diagram looks finished |
| [architecture.drawio.svg](architecture.drawio.svg) | a real SVG carrying the whole `<mxfile>` in its root `content` attribute | the form people actually commit: one file that GitHub renders *and* draw.io reopens. It is also the file `url.pathExtension` calls `svg` |

## Writing a picture out

Right-click the diagram, or the file in the tree, for **Export ▸**. Two groups,
and the difference between them is what the file *is*:

- **`PNG` / `SVG`** writes a picture beside the document — `pages.png`,
  `pages_001.png`, `pages_002.png`, one per page, named the way PlantUML's own
  file output names them. A picture of the diagram, to point a README at.
- **`Editable PNG` / `Editable SVG`** writes **one** file, `pages.drawio.png`,
  which is the picture *and* the document: it renders wherever a PNG renders
  and reopens in draw.io with all three pages inside it. That is the form people
  commit, and it is what `architecture.drawio.svg` above already is.

Both are offered in the theme the app is wearing and the other one, and the name
says which — `pages-dark.png`, `pages-dark.drawio.png`. A file that has set its
own page background wins over both, and the app says so rather than writing a
picture the menu item did not promise.

Every picture exported from a diagram carries the `<mxfile>`, editable name or
not — the name is what tells a *reader* which is which. A picture Abydos did not
draw from a diagram is never written over.

## What the format is

Established in 0426 from draw.io's own `app.min.js`, and implemented here:

- the root is `<mxfile>`, with one `<diagram id name>` per page — pages are
  siblings, not a nesting;
- a page's payload is either plain `<mxGraphModel>` XML, or
  **`base64( deflateRaw( encodeURIComponent( xml ) ) )`**;
- the `encodeURIComponent` step is the trap. Inflate and stop there and you get
  a string of `%3CmxGraphModel%20dx%3D...` — which, if you only unescape the
  angle brackets, parses as XML and is quietly wrong everywhere a label had a
  space in it;
- `.drawio.svg` is an SVG whose root element carries the `<mxfile>` in a
  `content` attribute. draw.io's reader tries three encodings in order: raw
  (`<`), URI-escaped (`%`), then base64. These use the raw form, which is what
  draw.io itself writes;
- `.drawio.png` is a real PNG with a `tEXt` or `zTXt` chunk keyed `mxfile`,
  holding URI-escaped XML with `+` standing in for a space. Abydos writes one of
  those — see **Editable PNG** above — and reads either.

## Checking them without opening them

```sh
python3 make-fixtures.py            # decode all four and check they round-trip
python3 make-fixtures.py --build    # write them again from the XML in the script
```

Written when nothing could draw them, and still the cheaper check: each file is
decoded exactly as draw.io's reader would, the model is parsed, the labels are
looked at for leftover `%20`, and what comes out is compressed and decompressed
again to see that it survives the trip. The diagrams' source XML lives in the
script, so the compressed files have a readable original rather than being three
walls of base64 with nothing behind them.

Needs `python3` and nothing else — `zlib` and `base64` are in its standard
library, which is the whole reason the script is Python and not the shell.

## What this build of Abydos does not carry, and says so

Two parts of draw.io's offline set are deliberately left out of the app, and
neither can be allowed to fail silently — a diagram with a hole in it still
looks like a diagram.

- **`img/lib/`**, 5.9 MB of clipart that `shape=image` cells reference by path.
- **`math4/`**, 3.3 MB of MathJax, which only a diagram typesetting LaTeX uses.

Open a diagram using either and the pane says so, once, naming which. There is
no fixture here for them on purpose: the point of the notice is that a file
nobody anticipated says what is missing, and a file kept here to prove it would
be a file kept to draw a gap.
