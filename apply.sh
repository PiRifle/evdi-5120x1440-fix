#!/usr/bin/env bash
# Apply the combined patch to EVDI 1.15.0, rebuild via DKMS, and reload the module.
# Run as root or with sudo.

set -e

EVDI_VER="1.15.0"
EVDI_SRC="/usr/src/evdi-$EVDI_VER"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

if [ ! -d "$EVDI_SRC" ]; then
    echo "Error: $EVDI_SRC not found. Download the release for your EVDI version from:" >&2
    echo "  https://github.com/PiRifle/evdi-5120x1440-fix/releases" >&2
    exit 1
fi

echo "==> Applying patch to $EVDI_SRC"
patch "$EVDI_SRC/evdi_connector.c" "$SCRIPT_DIR/evdi-5120x1440-fix.patch"

echo "==> Building EVDI via DKMS"
dkms build evdi/$EVDI_VER --force

echo "==> Installing EVDI via DKMS"
dkms install evdi/$EVDI_VER --force

echo ""
echo "Done. Reboot to load the new module:"
echo "  sudo reboot"
