#!/usr/bin/env python3
"""Writes the four .drawio fixtures, and reads them back to prove they decode.

Nothing in Abydos opens a .drawio yet — these are the fixtures for backlog 0426
— so they cannot be checked by drawing them. They are checked the only other
way there is: by decoding them exactly as draw.io's own reader does and
comparing the result with the XML that went in.

The format, established in 0426 from draw.io's own app.min.js:

  * the root is <mxfile>, with one <diagram> per page;
  * a <diagram>'s payload is either plain <mxGraphModel> XML or, far more
    commonly, base64( deflateRaw( encodeURIComponent( xml ) ) ) — all 155
    diagram templates draw.io ships are compressed and not one is plain;
  * the encodeURIComponent step is the trap. Inflating and stopping there
    gives a string full of %20 that parses as XML and is wrong everywhere a
    label had a space in it.

    make-fixtures.py           # decode what is here and check it round-trips
    make-fixtures.py --build   # write the four files again
"""

import base64
import re
import sys
import urllib.parse
import zlib
from pathlib import Path
from xml.etree import ElementTree

HERE = Path(__file__).resolve().parent

# What JavaScript's encodeURIComponent leaves alone. Python's quote() already
# spares A-Za-z0-9 and _.-~, so these four pairs are the whole difference.
UNRESERVED = "!~*'()"


def compress(xml: str) -> str:
	"""draw.io's Graph.compress: base64( deflateRaw( encodeURIComponent( xml ) ) )."""
	escaped = urllib.parse.quote(xml, safe=UNRESERVED)
	deflater = zlib.compressobj(9, zlib.DEFLATED, -15)
	raw = deflater.compress(escaped.encode("utf-8")) + deflater.flush()
	return base64.b64encode(raw).decode("ascii")


def decompress(payload: str) -> str:
	"""And back again, which is what the reader does and what --check uses."""
	raw = zlib.decompress(base64.b64decode(payload), -15)
	return urllib.parse.unquote(raw.decode("utf-8"))


def model(cells: str) -> str:
	"""One page's mxGraphModel, around the cells that make it up.

	`0` is the model root and `1` is the default layer; every other cell is a
	child of `1`. draw.io writes those two into every file it saves and a file
	without them opens empty.
	"""
	return (
		'<mxGraphModel dx="1102" dy="768" grid="1" gridSize="10" guides="1" '
		'tooltips="1" connect="1" arrows="1" fold="1" page="1" pageScale="1" '
		'pageWidth="850" pageHeight="1100" math="0" shadow="0">\n  <root>\n'
		'    <mxCell id="0" />\n    <mxCell id="1" parent="0" />\n'
		f"{cells}"
		"  </root>\n</mxGraphModel>\n"
	)


def box(ident: str, label: str, x: int, y: int, w: int = 200, h: int = 60, style: str = "") -> str:
	shape = style or "rounded=0;whiteSpace=wrap;html=1;"
	return (
		f'    <mxCell id="{ident}" value="{label}" style="{shape}" vertex="1" parent="1">\n'
		f'      <mxGeometry x="{x}" y="{y}" width="{w}" height="{h}" as="geometry" />\n'
		"    </mxCell>\n"
	)


def arrow(ident: str, source: str, target: str, label: str = "") -> str:
	return (
		f'    <mxCell id="{ident}" value="{label}" '
		'style="edgeStyle=orthogonalEdgeStyle;rounded=0;html=1;" '
		f'edge="1" parent="1" source="{source}" target="{target}">\n'
		'      <mxGeometry relative="1" as="geometry" />\n'
		"    </mxCell>\n"
	)


def mxfile(pages: list[tuple[str, str, str]]) -> str:
	"""<mxfile> around one <diagram> per page, each already encoded or not."""
	body = "".join(
		f'  <diagram id="{ident}" name="{name}">{payload}</diagram>\n'
		for ident, name, payload in pages
	)
	return (
		'<mxfile host="Electron" agent="abydos-examples" version="31.1.8" type="device">\n'
		f"{body}</mxfile>\n"
	)


# ---------------------------------------------------------------- the diagrams

PLAIN = model(
	box("v1", "a .drawio in the tree", 120, 80)
	+ box("v2", "GraphViewer, in a WKWebView with nothing fetched", 120, 200, 200, 80)
	+ box("v3", "a picture in the preview pane", 120, 360)
	+ box("v4", "architecture.png beside the file", 120, 480)
	+ arrow("e1", "v1", "v2", "the XML, decompressed")
	+ arrow("e2", "v2", "v3")
	+ arrow("e3", "v3", "v4", "Export &#9656; PNG")
)

PAGES = [
	(
		"Editor",
		model(
			box("p1v1", "the tab bar", 80, 60)
			+ box("p1v2", "the text, or the picture, or both", 80, 180, 240, 60)
			+ arrow("p1e1", "p1v1", "p1v2", "Source / Preview / Split")
		),
	),
	(
		"Viewer",
		model(
			box("p2v1", "viewer-static.min.js (3.95 MB)", 80, 60, 240, 60)
			+ box("p2v2", "stencils.min.js (7.23 MB)", 80, 180, 240, 60)
			+ box("p2v3", "11.3 MB, fully offline", 80, 300, 240, 60)
			+ arrow("p2e1", "p2v1", "p2v3")
			+ arrow("p2e2", "p2v2", "p2v3")
		),
	),
	(
		"Export",
		model(
			box("p3v1", "page 1", 60, 60, 120, 50)
			+ box("p3v2", "page 2", 200, 60, 120, 50)
			+ box("p3v3", "page 3", 340, 60, 120, 50)
			+ box("p3v4", "x.png, x_001.png, x_002.png", 60, 200, 400, 60)
			+ arrow("p3e1", "p3v1", "p3v4")
			+ arrow("p3e2", "p3v2", "p3v4")
			+ arrow("p3e3", "p3v3", "p3v4")
		),
	),
]

# The shapes here are the point: every one is a stencil that draw.io's viewer
# fetches lazily, by style prefix, at draw time. Offline and without
# stencils.min.js they fail *silently* — one <path> instead of two, no error,
# no message, and a diagram that looks finished with its icons missing.
AWS = "sketch=0;outlineConnect=0;fontColor=#232F3E;gradientColor=none;fillColor=#232F3E;strokeColor=none;dashed=0;verticalLabelPosition=bottom;verticalAlign=top;align=center;html=1;fontSize=12;fontStyle=0;aspect=fixed;pointerEvents=1;"
STENCILS = model(
	box("s1", "Users", 80, 60, 78, 78, AWS + "shape=mxgraph.aws4.users;")
	+ box("s2", "API Gateway", 240, 60, 78, 78, AWS + "shape=mxgraph.aws4.api_gateway;")
	+ box("s3", "Lambda", 400, 60, 78, 78, AWS + "shape=mxgraph.aws4.lambda;")
	+ box("s4", "S3", 560, 60, 78, 78, AWS + "shape=mxgraph.aws4.s3;")
	+ box(
		"s5",
		"Every icon above is a stencil, fetched at draw time. "
		"Without the bundle they are simply absent, and nothing says so.",
		80,
		220,
		560,
		60,
	)
	+ arrow("se1", "s1", "s2")
	+ arrow("se2", "s2", "s3")
	+ arrow("se3", "s3", "s4")
)

ARCHITECTURE = model(
	box("a1", "abydos-examples", 40, 40, 240, 50)
	+ box("a2", "plantuml/", 40, 150, 150, 50)
	+ box("a3", "mermaid/", 210, 150, 150, 50)
	+ box("a4", "drawio/", 380, 150, 150, 50)
	+ box("a5", "a container, or nothing", 40, 260, 150, 50)
	+ box("a6", "3.57 MB in the app", 210, 260, 150, 50)
	+ box("a7", "11.3 MB, and unwritten", 380, 260, 150, 50)
	+ arrow("ae1", "a1", "a2")
	+ arrow("ae2", "a1", "a3")
	+ arrow("ae3", "a1", "a4")
	+ arrow("ae4", "a2", "a5")
	+ arrow("ae5", "a3", "a6")
	+ arrow("ae6", "a4", "a7")
)

# The picture half of the .drawio.svg. A real SVG, so GitHub and Preview.app
# draw it; the <mxfile> travels in the root element's `content` attribute, and
# that is what draw.io reopens. Drawn by hand here rather than by draw.io,
# because the point of the fixture is the attribute rather than the artwork.
PICTURE = """<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" \
version="1.1" width="590" height="330" viewBox="-0.5 -0.5 590 330" content="{content}">
<rect x="0" y="0" width="590" height="330" fill="#ffffff"/>
<g font-family="Helvetica" font-size="12" text-anchor="middle" fill="#000000">
{shapes}</g>
</svg>
"""

SVG_BOXES = [
	(40, 40, 240, 50, "abydos-examples"),
	(40, 150, 150, 50, "plantuml/"),
	(210, 150, 150, 50, "mermaid/"),
	(380, 150, 150, 50, "drawio/"),
	(40, 260, 150, 50, "a container, or nothing"),
	(210, 260, 150, 50, "3.57 MB in the app"),
	(380, 260, 150, 50, "11.3 MB, and unwritten"),
]
SVG_LINES = [
	(160, 90, 115, 150),
	(160, 90, 285, 150),
	(160, 90, 455, 150),
	(115, 200, 115, 260),
	(285, 200, 285, 260),
	(455, 200, 455, 260),
]


def picture(content: str) -> str:
	shapes = ""
	for x1, y1, x2, y2 in SVG_LINES:
		shapes += (
			f'<path d="M {x1} {y1} L {x1} {(y1 + y2) // 2} L {x2} {(y1 + y2) // 2} L {x2} {y2}" '
			'fill="none" stroke="#000000" stroke-miterlimit="10"/>\n'
		)
	for x, y, w, h, label in SVG_BOXES:
		shapes += (
			f'<rect x="{x}" y="{y}" width="{w}" height="{h}" fill="#ffffff" stroke="#000000"/>\n'
			f'<text x="{x + w // 2}" y="{y + h // 2 + 4}">{label}</text>\n'
		)
	return PICTURE.format(content=escape_attribute(content), shapes=shapes)


def escape_attribute(text: str) -> str:
	return (
		text.replace("&", "&amp;")
		.replace("<", "&lt;")
		.replace(">", "&gt;")
		.replace('"', "&quot;")
		.replace("\n", "&#xa;")
	)


# --------------------------------------------------------------------- writing

FIXTURES = {
	"plain.drawio": lambda: mxfile([("plain-1", "Preview", PLAIN)]),
	"pages.drawio": lambda: mxfile(
		[(f"pages-{index + 1}", name, compress(xml)) for index, (name, xml) in enumerate(PAGES)]
	),
	"stencils.drawio": lambda: mxfile([("stencils-1", "AWS", compress(STENCILS))]),
	"architecture.drawio.svg": lambda: picture(
		mxfile([("architecture-1", "Repository", compress(ARCHITECTURE))])
	),
}


def build() -> None:
	for name, make in FIXTURES.items():
		(HERE / name).write_text(make(), encoding="utf-8")
		print(f"  wrote {name}")


# -------------------------------------------------------------------- checking

def pages_of(text: str) -> list[tuple[str, str]]:
	"""Every page's name and its decoded mxGraphModel XML.

	The reader draw.io has: a payload that starts with `<` is plain, and
	anything else is base64 of deflateRaw of the URI-escaped XML.
	"""
	if text.lstrip().startswith("<svg"):
		root = ElementTree.fromstring(text)
		content = root.get("content")
		if content is None:
			raise ValueError("the SVG carries no content attribute")
		text = content
	found = []
	for match in re.finditer(r'<diagram\b[^>]*name="([^"]*)"[^>]*>(.*?)</diagram>', text, re.S):
		name, payload = match.group(1), match.group(2).strip()
		found.append((name, payload if payload.startswith("<") else decompress(payload)))
	if not found:
		raise ValueError("no <diagram> in it")
	return found


def check() -> int:
	faults = 0
	for name in FIXTURES:
		path = HERE / name
		if not path.exists():
			print(f"  {name}: missing — run --build")
			faults += 1
			continue
		text = path.read_text(encoding="utf-8")
		try:
			pages = pages_of(text)
		except Exception as trouble:  # noqa: BLE001 — the message is the report
			print(f"  {name}: could not be read — {trouble}")
			faults += 1
			continue

		compressed = "<mxGraphModel" not in text
		for page, xml in pages:
			model_root = ElementTree.fromstring(xml)
			cells = model_root.findall(".//mxCell")
			labels = [cell.get("value") for cell in cells if cell.get("value")]
			# The %20 trap: a decoder that skipped unquote() gets XML that parses
			# and has no spaces in any of its labels.
			if any("%20" in (label or "") for label in labels):
				print(f"  {name} [{page}]: labels are still URI-escaped")
				faults += 1
			if len(cells) < 3:
				print(f"  {name} [{page}]: only {len(cells)} cells")
				faults += 1
			# And the round trip, which is the actual claim: what came out,
			# compressed again and decompressed again, is what came out.
			if compressed and decompress(compress(xml)) != xml:
				print(f"  {name} [{page}]: does not round-trip")
				faults += 1
		kind = "compressed" if compressed else "plain"
		spaced = sum(1 for _, xml in pages for label in [xml] if " " in label)
		print(
			f"  {name}: {len(pages)} page{'s' if len(pages) != 1 else ''}, {kind}, "
			f"{sum(len(ElementTree.fromstring(x).findall('.//mxCell')) for _, x in pages)} cells"
			f"{'' if spaced else ' (no spaces anywhere — suspicious)'}"
		)
	return faults


if __name__ == "__main__":
	if "--build" in sys.argv:
		print("==> writing")
		build()
	print("==> checking")
	problems = check()
	if problems:
		print(f"==> {problems} problem(s)")
		sys.exit(1)
	print("==> every fixture decodes to the XML it was made from")
