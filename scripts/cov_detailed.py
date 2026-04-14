#!/usr/bin/env python3
"""
Show per-source-file line coverage.
Fully-covered files → single green summary line.
Partially-covered files → full source listing with uncovered lines in red.

Usage: python3 cov_detailed.py <TestResults.xcresult> <coverage.json>
"""
import json, os, re, subprocess, sys

RESULT_BUNDLE = sys.argv[1]
COV_JSON      = sys.argv[2]

RED    = "\033[31m"
GREEN  = "\033[32m"
YELLOW = "\033[33m"
DIM    = "\033[2m"
BOLD   = "\033[1m"
RESET  = "\033[0m"

# Matches lines like " 26: 0" or "  3: 0 [" (uncovered executable line)
UNCOV_RE = re.compile(r"^\s*(\d+):\s*0\b")
# Matches lines like " 17: 13" (covered), " 1: *" (non-executable)
COV_RE   = re.compile(r"^\s*(\d+):\s*(\d+|\*)")


def fetch_counts(path: str) -> dict[int, str | None]:
    """
    Return {line_number: count_str} for every executable line.
    count_str is "0", "1", "13", etc.  Non-executable lines are absent.
    """
    result = subprocess.run(
        ["xcrun", "xccov", "view", "--archive", RESULT_BUNDLE, "--file", path],
        capture_output=True, text=True,
    )
    if result.returncode != 0:
        return {}

    counts: dict[int, str | None] = {}
    for line in result.stdout.splitlines():
        m = COV_RE.match(line)
        if m:
            lineno, count = int(m.group(1)), m.group(2)
            if count != "*":
                counts[lineno] = count
    return counts


with open(COV_JSON) as fh:
    data = json.load(fh)

target = next((t for t in data["targets"] if t["name"].endswith(".app")), None)
if target is None:
    sys.exit("No .app target found in coverage JSON")

files = sorted(target["files"], key=lambda f: os.path.basename(f["path"]))

for f in files:
    path = f["path"]
    name = os.path.basename(path)
    pct  = f["lineCoverage"]

    if pct == 1.0:
        print(f"{GREEN}✓ {name:<55} 100.0%{RESET}")
        continue

    counts = fetch_counts(path)
    if not counts:
        print(f"{DIM}? {name:<55}   n/a{RESET}")
        continue

    try:
        source_lines = open(path).readlines()
    except OSError:
        print(f"{DIM}? {name} — source not readable{RESET}")
        continue

    pct_str = f"{pct * 100:.1f}%"
    bar_color = YELLOW if pct >= 0.70 else RED
    print(f"\n{BOLD}{bar_color}▸ {name}{RESET}{bar_color}  {pct_str}{RESET}")
    print(f"{DIM}{'─' * 72}{RESET}")

    line_w = len(str(len(source_lines)))  # width for line-number column
    for lineno, source in enumerate(source_lines, start=1):
        source = source.rstrip("\n")
        count  = counts.get(lineno)
        if count == "0":
            print(f"{RED}{lineno:{line_w}d}  ✗    {source}{RESET}")
