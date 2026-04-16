#!/usr/bin/env bash
# scripts/setup.sh — install everything needed for local development.
#
# Run once after cloning. Idempotent: safe to re-run.
#
# Installs:
#   • Homebrew packages: just, xcpretty, swiftformat, swiftlint (macOS only)
#   • pre-commit (via pip)
#   • pre-commit hooks into .git/hooks
#
# Linux sandboxes (e.g. Claude Code's Linux environment) can install pre-commit
# and the typos hook but not SwiftFormat/SwiftLint — those require macOS. The
# pre-commit config skips Swift hooks gracefully when their binaries aren't on
# $PATH, so commits still run the checks that are available.

set -euo pipefail

cd "$(dirname "$0")/.."

is_macos() { [[ "$(uname -s)" == "Darwin" ]]; }

echo "==> Checking pre-commit"
if ! command -v pre-commit >/dev/null 2>&1; then
    echo "    Installing pre-commit via pip"
    pip install --user pre-commit
fi

if is_macos; then
    echo "==> macOS detected — installing Swift toolchain helpers"
    if ! command -v brew >/dev/null 2>&1; then
        echo "    Homebrew not found. Install it from https://brew.sh and re-run." >&2
        exit 1
    fi
    for pkg in just xcpretty swiftformat swiftlint; do
        if ! brew list --formula "$pkg" >/dev/null 2>&1; then
            echo "    brew install $pkg"
            brew install "$pkg"
        else
            echo "    $pkg already installed"
        fi
    done
else
    echo "==> Non-macOS host — skipping brew-only tools (swiftformat, swiftlint, just, xcpretty)"
    echo "    These must run on macOS; CI is authoritative for Swift formatting and linting."
fi

echo "==> Installing pre-commit hooks"
pre-commit install --install-hooks

echo "==> Done"
