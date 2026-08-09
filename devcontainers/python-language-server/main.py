"""Print a morning's readings, warmest first.

Things worth trying with the caret in this file, none of which work without a
pyright somewhere:

  * ⌘-click `Reading` on the import line, or on line 21 — it opens
    stations/reading.py, at a path on *this* machine.
  * Type `first.` on a line of its own inside `report` — completion offers
    `celsius`, `describe`, `fahrenheit`, `humidity`, `hour`, `is_muggy`,
    `converted`, `scale` and `station`.
  * Hover `warmest` — the docstring and the `Reading | None` it returns.
"""

from stations.reading import Reading, Scale, warmest

MORNING: list[Reading] = [
    Reading(station="Kiel", hour=7, celsius=17.5, humidity=0.82),
    Reading(station="Ulm", hour=7, celsius=21.0, humidity=0.55),
    Reading(station="Palermo", hour=7, celsius=26.5, humidity=0.71),
]


def report(readings: list[Reading], scale: Scale = Scale.CELSIUS) -> list[str]:
    """One line per reading, warmest first, in the scale asked for."""
    ordered = sorted(readings, key=lambda reading: reading.celsius, reverse=True)
    return [reading.converted(scale).describe() for reading in ordered]


def main() -> None:
    for line in report(MORNING):
        print(line)

    first = warmest(MORNING)
    # `warmest` can answer `None`, so this has to be asked. Take the `if` away
    # and pyright underlines the next line, which is the other half of a
    # language server being there at all.
    if first is not None:
        print(f"warmest: {first.describe()}")
        print(f"muggy:   {first.is_muggy()}")
        print(f"in F:    {first.converted(Scale.FAHRENHEIT).describe()}")


if __name__ == "__main__":
    main()
