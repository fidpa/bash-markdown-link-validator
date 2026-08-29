# Examples

Two ready-to-use wrapper scripts. A wrapper is all you write yourself: it sets
the area variables, sources `validate-links-core.sh` and calls the library in
the documented order.

| File | Use case |
|------|----------|
| [basic-wrapper.sh](basic-wrapper.sh) | One directory, for example a project's `docs/` |
| [multi-area-wrapper.sh](multi-area-wrapper.sh) | Several areas in one run, for example the four DIATAXIS quadrants |

Copy the one that fits next to the documentation it should check, adjust
`AREA_NAME` and `EXCLUDE_DIRS` at the top, and run it. Both scripts carry
comments on every variable they expect.

The pattern behind them, including how several areas share one core, is
described in [../docs/WRAPPER_SYSTEM.md](../docs/WRAPPER_SYSTEM.md).
