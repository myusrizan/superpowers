#!/usr/bin/env bash
# build-skills.sh
# Rebuilds the skills/ folder from custom-skills/.
# Called automatically by hooks/session-start on every session.
# Run manually to rebuild without starting a session:
#   ./scripts/build-skills.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
PLUGIN_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

SRC="${PLUGIN_ROOT}/custom-skills"
DEST="${PLUGIN_ROOT}/skills"

# Validate source exists
if [ ! -d "$SRC" ]; then
    echo "build-skills: ERROR — custom-skills/ not found at ${SRC}" >&2
    exit 1
fi

# Rebuild destination
rm -rf "$DEST"
cp -r "$SRC" "$DEST"
