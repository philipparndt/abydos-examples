"""One weather station's reading, and the arithmetic on it.

This is the file the language server has to find. `main.py` imports two names
from here through the package beside it, so a go-to-definition on either of them
crosses a file *and* a package — which is the thing worth checking, because a
server that resolves imports against the container's own paths and then reports
them back with the container's names sends the editor to a file that does not
exist on this machine.
"""

from dataclasses import dataclass
from enum import Enum


class Scale(Enum):
    """The two scales anybody argues about."""

    CELSIUS = "C"
    FAHRENHEIT = "F"


@dataclass(frozen=True)
class Reading:
    """A temperature and a humidity, taken somewhere, at some hour.

    Enough members that completion after `first.` has something to say: five
    attributes, three methods and a property, each with a docstring the hover
    shows.
    """

    station: str
    """Where it was taken."""

    hour: int
    """Local hour of the day, 0 to 23."""

    celsius: float
    """The temperature, in the scale the rest of the world uses."""

    humidity: float
    """Relative humidity, 0 to 1."""

    scale: Scale = Scale.CELSIUS
    """The scale `converted` reports in."""

    @property
    def fahrenheit(self) -> float:
        """The same temperature, for the one country that asks."""
        return self.celsius * 9 / 5 + 32

    def converted(self, to: Scale) -> "Reading":
        """The same reading, reported in another scale."""
        if to is self.scale:
            return self
        return Reading(
            station=self.station,
            hour=self.hour,
            celsius=self.celsius,
            humidity=self.humidity,
            scale=to,
        )

    def is_muggy(self) -> bool:
        """Warm and wet at once, which is what people actually complain about."""
        return self.celsius >= 24.0 and self.humidity >= 0.65

    def describe(self) -> str:
        """One line, in whichever scale this reading is reported in."""
        if self.scale is Scale.FAHRENHEIT:
            degrees = f"{self.fahrenheit:.1f}F"
        else:
            degrees = f"{self.celsius:.1f}C"
        return f"{self.station} at {self.hour:02d}:00 — {degrees}, {self.humidity:.0%} humidity"


def warmest(readings: list[Reading]) -> Reading | None:
    """The warmest of the readings, or nothing when there are none.

    Returning `None` rather than raising is deliberate: it gives the caller in
    `main.py` something for the language server to be right about, since a
    `Reading | None` used as a `Reading` is exactly the mistake pyright is there
    to underline.
    """
    if not readings:
        return None
    return max(readings, key=lambda reading: reading.celsius)
