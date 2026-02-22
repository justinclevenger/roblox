#!/usr/bin/env bash
# Lint and format-check all Luau code
# Usage: ./scripts/lint.sh [--fix]
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FIX="${1:-}"

echo "Linting with selene..."
selene "$REPO_ROOT/experiences" "$REPO_ROOT/packages"

if [ "$FIX" = "--fix" ]; then
	echo "Formatting with stylua..."
	stylua "$REPO_ROOT/experiences" "$REPO_ROOT/packages"
	echo "Formatted."
else
	echo "Checking formatting with stylua..."
	stylua --check "$REPO_ROOT/experiences" "$REPO_ROOT/packages"
fi

echo "All checks passed."
