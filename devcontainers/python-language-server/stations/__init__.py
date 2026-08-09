"""The stations package.

A package rather than a module beside `main.py`, because resolving
`from stations.reading import …` is work the language server does against the
project root — and the project root inside the container is not the project root
out here. An import that resolves is the mapping working in one direction; the
definition opening the right file on this machine is it working in the other.
"""

from stations.reading import Reading, Scale, warmest

__all__ = ["Reading", "Scale", "warmest"]
