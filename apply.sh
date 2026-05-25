#!/usr/bin/env bash
# Apply both patches to EVDI 1.14.16, rebuild via DKMS, and reload the module.
# Run as root or with sudo.

set -e

EVDI_SRC="/usr/src/evdi-1.14.16"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "==> Applying patches to $EVDI_SRC"
patch "$EVDI_SRC/evdi_connector.c" "$SCRIPT_DIR/0001-connector-bypass-pixel-area-limit-for-sub-8K-modes.patch"
patch "$EVDI_SRC/evdi_connector.c" "$SCRIPT_DIR/0002-connector-inject-5120x1440-mode-when-edid-truncated.patch"

echo "==> Building EVDI via DKMS"
dkms build evdi/1.14.16 --force

echo "==> Installing EVDI via DKMS"
dkms install evdi/1.14.16 --force

echo ""
echo "Done. Reboot to load the new module:"
echo "  sudo reboot"
