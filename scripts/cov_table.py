#!/usr/bin/env python3
"""
Print a Unicode box table summarising per-file code coverage.
Usage: python3 cov_table.py <coverage.json>
"""
import json, os, sys

COV_JSON = sys.argv[1]

RED    = "\033[31m"
YELLOW = "\033[33m"
GREEN  = "\033[32m"
BOLD   = "\033[1m"
RESET  = "\033[0m"

TL, TM, TR = "┌", "┬", "┐"
ML, MM, MR = "├", "┼", "┤"
BL, BM, BR = "└", "┴", "┘"
HZ, VT     = "─", "│"


def pct_color(pct: float) -> str:
    if pct >= 0.90: return GREEN
    if pct >= 0.70: return YELLOW
    return RED


def fmt_pct(pct: float) -> str:
    """Return a fixed-width '  X.X%' string wrapped in ANSI colour codes."""
    return pct_color(pct) + f"{pct * 100:5.1f}%" + RESET


def hline(left: str, mid: str, right: str, widths: list[int]) -> str:
    return left + mid.join(HZ * (w + 2) for w in widths) + right


def cell(value: str, width: int, align: str = "<") -> str:
    return f" {value:{align}{width}} "


with open(COV_JSON) as fh:
    data = json.load(fh)

target = next((t for t in data["targets"] if t["name"].endswith(".app")), None)
if target is None:
    sys.exit("No .app target found in coverage JSON")

files = sorted(target["files"], key=lambda f: os.path.basename(f["path"]))

name_w = max((len(os.path.basename(f["path"])) for f in files), default=4)
name_w = max(name_w, len("File"))

# Column visible widths: name | lines | covered | coverage
W = [name_w, 6, 7, 8]
HEADERS = ["File", "Lines", "Covered", "Coverage"]

print()
print(hline(TL, TM, TR, W))

# Header row
print(
    VT
    + VT.join([
        cell(BOLD + HEADERS[0] + RESET, W[0] + len(BOLD) + len(RESET), "<"),
        cell(BOLD + HEADERS[1] + RESET, W[1] + len(BOLD) + len(RESET), ">"),
        cell(BOLD + HEADERS[2] + RESET, W[2] + len(BOLD) + len(RESET), ">"),
        cell(BOLD + HEADERS[3] + RESET, W[3] + len(BOLD) + len(RESET), ">"),
    ])
    + VT
)
print(hline(ML, MM, MR, W))

for f in files:
    name = os.path.basename(f["path"])
    pct  = f["lineCoverage"]
    # fmt_pct always produces 6 visible chars; pad column to W[3]
    pct_str = fmt_pct(pct)
    extra   = len(pct_str) - 6  # invisible ANSI bytes

    print(
        VT
        + cell(name,                  W[0], "<")
        + VT
        + cell(str(f["executableLines"]), W[1], ">")
        + VT
        + cell(str(f["coveredLines"]),    W[2], ">")
        + VT
        + cell(pct_str, W[3] + extra, ">")
        + VT
    )

print(hline(ML, MM, MR, W))

# Totals row
pct     = target["lineCoverage"]
pct_str = fmt_pct(pct)
extra   = len(pct_str) - 6
total   = BOLD + "TOTAL" + RESET

print(
    VT
    + cell(total,                               W[0] + len(BOLD) + len(RESET), "<")
    + VT
    + cell(BOLD + str(target["executableLines"]) + RESET, W[1] + len(BOLD) + len(RESET), ">")
    + VT
    + cell(BOLD + str(target["coveredLines"])    + RESET, W[2] + len(BOLD) + len(RESET), ">")
    + VT
    + cell(BOLD + pct_str + RESET,              W[3] + extra + len(BOLD) + len(RESET), ">")
    + VT
)
print(hline(BL, BM, BR, W))
print()
