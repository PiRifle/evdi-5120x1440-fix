#!/usr/bin/env bash
# Apply both patches to EVDI 1.15.0, rebuild via DKMS, and reload the module.
# Run as root or with sudo.

set -e

EVDI_VER="1.15.0"
EVDI_SRC="/usr/src/evdi-$EVDI_VER"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

if [ ! -d "$EVDI_SRC" ]; then
    echo "Error: $EVDI_SRC not found. For EVDI 1.14.16 use the v1.14.16 release." >&2
    exit 1
fi

echo "==> Applying patches to $EVDI_SRC"
patch "$EVDI_SRC/evdi_connector.c" "$SCRIPT_DIR/0001-connector-bypass-pixel-area-limit-for-sub-8K-modes.patch"
patch "$EVDI_SRC/evdi_connector.c" "$SCRIPT_DIR/0002-connector-inject-5120x1440-mode-when-edid-truncated.patch"

echo "==> Building EVDI via DKMS"
dkms build evdi/$EVDI_VER --force

echo "==> Installing EVDI via DKMS"
dkms install evdi/$EVDI_VER --force

echo ""
echo "Done. Reboot to load the new module:"
echo "  sudo reboot"
