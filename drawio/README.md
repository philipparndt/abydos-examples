# drawio

**Abydos cannot open these.** There is no `.drawio` preview, no export beside
the file, and no editor in the pane — draw.io support is a design draft
(backlog 0426) and not a feature. These four files are the fixtures that draft
asks for, written now so that whoever builds it has the four cases to build
against, and so that a decision about the format can be checked against a file
rather than against a memory of one.

Nothing here is broken and nothing here should look broken. Open one today and
you get its XML, which is what a text editor does with a file it has never
heard of. `architecture.drawio.svg` is the one exception, and only because it
genuinely is an SVG: it draws in the preview pane as any other picture would.

## The four

| file | what it is | why this one |
|---|---|---|
| [plain.drawio](plain.drawio) | one page, an uncompressed `<mxGraphModel>` | the readable form: open it and the diagram is right there as XML. Rare in the wild, and the only one anybody can check by eye |
| [pages.drawio](pages.drawio) | three pages, compressed | the normal form, and both hard parts at once — **all 155** templates draw.io ships are compressed, and a three-page file has no single picture to draw or to export |
| [stencils.drawio](stencils.drawio) | four AWS shapes, compressed | the failure that is silent. Shape libraries are fetched lazily by style prefix at draw time; offline and without `stencils.min.js` they simply do not appear, with no error, and the diagram looks finished |
| [architecture.drawio.svg](architecture.drawio.svg) | a real SVG carrying the whole `<mxfile>` in its root `content` attribute | the form people actually commit: one file that GitHub renders *and* draw.io reopens. It is also the file `url.pathExtension` calls `svg` |

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
  draw.io itself writes.

## Checking them, since they cannot be drawn

```sh
python3 make-fixtures.py            # decode all four and check they round-trip
python3 make-fixtures.py --build    # write them again from the XML in the script
```

The check is the only honest one available: each file is decoded exactly as
draw.io's reader would, the model is parsed, the labels are looked at for
leftover `%20`, and what comes out is compressed and decompressed again to see
that it survives the trip. The diagrams' source XML lives in the script, so the
compressed files have a readable original rather than being three walls of
base64 with nothing behind them.

Needs `python3` and nothing else — `zlib` and `base64` are in its standard
library, which is the whole reason the script is Python and not the shell.

## What is deliberately not here

A **`.drawio.png`** — a real PNG with the `<mxfile>` in a `tEXt` or `zTXt`
chunk. It is the fifth case and 0426 does not ask for it, because level 1 of
that entry reads files and does not write them; it belongs with whoever decides
whether "Save a copy as an editable PNG" is a menu item.

Nothing that needs `img/lib` clipart, either. That is 5.67 MB of assets
`stencils.min.js` does *not* cover, and a diagram using one would show a gap in
the same silent way `stencils.drawio` shows one — worth a fixture on the day
somebody decides whether a missing asset should be able to say so.
