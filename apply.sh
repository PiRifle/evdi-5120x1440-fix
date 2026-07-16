#!/usr/bin/env bash
# Apply both patches to EVDI 1.14.16 or 1.15.0, rebuild via DKMS, and reload the module.
# Run as root or with sudo.

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Auto-detect installed version, prefer newest
if [ -d /usr/src/evdi-1.15.0 ]; then
    EVDI_VER="1.15.0"
    PATCH_SUFFIX="-v1.15.0"
elif [ -d /usr/src/evdi-1.14.16 ]; then
    EVDI_VER="1.14.16"
    PATCH_SUFFIX=""
else
    echo "Error: no supported EVDI source found in /usr/src (need 1.14.16 or 1.15.0)" >&2
    exit 1
fi

EVDI_SRC="/usr/src/evdi-$EVDI_VER"

echo "==> Applying patches to $EVDI_SRC"
patch "$EVDI_SRC/evdi_connector.c" "$SCRIPT_DIR/0001-connector-bypass-pixel-area-limit-for-sub-8K-modes${PATCH_SUFFIX}.patch"
patch "$EVDI_SRC/evdi_connector.c" "$SCRIPT_DIR/0002-connector-inject-5120x1440-mode-when-edid-truncated${PATCH_SUFFIX}.patch"

echo "==> Building EVDI via DKMS"
dkms build evdi/$EVDI_VER --force

echo "==> Installing EVDI via DKMS"
dkms install evdi/$EVDI_VER --force

echo ""
echo "Done. Reboot to load the new module:"
echo "  sudo reboot"
