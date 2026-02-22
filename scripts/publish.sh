#!/usr/bin/env bash
# Publish a built experience to Roblox via Open Cloud
# Usage: ./scripts/publish.sh <experience-name> <universe-id> <place-id>
# Requires: ROBLOX_API_KEY environment variable
set -euo pipefail

if [ $# -lt 3 ]; then
	echo "Usage: $0 <experience-name> <universe-id> <place-id>"
	echo "Requires ROBLOX_API_KEY environment variable"
	exit 1
fi

NAME="$1"
UNIVERSE_ID="$2"
PLACE_ID="$3"
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_FILE="$REPO_ROOT/build/$NAME.rbxl"

if [ -z "${ROBLOX_API_KEY:-}" ]; then
	echo "Error: ROBLOX_API_KEY not set"
	exit 1
fi

if [ ! -f "$BUILD_FILE" ]; then
	echo "Error: $BUILD_FILE not found. Run ./scripts/build.sh $NAME first."
	exit 1
fi

echo "Publishing $NAME to universe=$UNIVERSE_ID place=$PLACE_ID..."
rbxcloud place publish \
	--universe-id "$UNIVERSE_ID" \
	--place-id "$PLACE_ID" \
	--filepath "$BUILD_FILE" \
	--publish-type published \
	--api-key "$ROBLOX_API_KEY"

echo "Published successfully."
