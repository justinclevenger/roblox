#!/usr/bin/env bash
# Build a specific experience or all experiences
# Usage: ./scripts/build.sh [experience-name]
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
EXPERIENCES_DIR="$REPO_ROOT/experiences"

build_experience() {
	local name="$1"
	local dir="$EXPERIENCES_DIR/$name"

	if [ ! -f "$dir/default.project.json" ]; then
		echo "Skipping $name (no default.project.json)"
		return
	fi

	echo "Building $name..."

	# Install wally packages if wally.toml exists
	if [ -f "$dir/wally.toml" ]; then
		(cd "$dir" && wally install)
	fi

	# Build the place file
	(cd "$dir" && rojo build -o "../../build/$name.rbxl")
	echo "Built build/$name.rbxl"
}

mkdir -p "$REPO_ROOT/build"

if [ $# -eq 1 ]; then
	build_experience "$1"
else
	for dir in "$EXPERIENCES_DIR"/*/; do
		name="$(basename "$dir")"
		build_experience "$name"
	done
fi

echo "Done."
