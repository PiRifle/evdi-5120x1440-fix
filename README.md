# EVDI: 5120x1440 (32:9) Support Fix

Patches for [DisplayLink/evdi](https://github.com/DisplayLink/evdi) enabling 5120x1440 resolution on Linux when using docks that truncate the monitor EDID.

## Problem

On Windows, a **Samsung Odyssey G93SC** (32:9, 5120x1440) connected via a **ThinkPad Hybrid USB-C with USB-A Dock** (USB ID `17e9:6015`) correctly exposes 5120x1440. On Linux with EVDI, only 3840x1080@120 is offered.

Two bugs combine to cause this:

### Bug 1 — `pixel_area_limit` rejects valid modes (EVDI, fixable here)

`evdi_mode_valid()` rejects any mode where `width × height > pixel_area_limit`. This limit is set by the closed-source `DisplayLinkManager` daemon at connect time. On this dock it is set too conservatively, blocking 5120x1440 (7,372,800 px) even though 3840x1080@120 Hz (which has *more* pixels/sec) is accepted.

The `pixel_per_second_limit` already correctly constrains bandwidth. The area check is redundant and overly strict.

**Fix:** `0001-bypass-pixel-area-limit.patch`

### Bug 2 — DisplayLinkManager truncates the EDID (closed source, workaround here)

The Odyssey G93SC EDID declares `EDID Extension Block Count: 3` (4 blocks total, 512 bytes). `DisplayLinkManager` forwards only 2 blocks (256 bytes) to EVDI, dropping the extension blocks that contain the 5120x1440 detailed timing descriptors. The root fix belongs in `DisplayLinkManager`.

**Workaround:** `0002-inject-5120x1440-mode.patch` — injects a synthetic CVT-RB 5120x1440@60 mode at the kernel level when the EDID-derived mode list does not include it.

## Affected hardware

| Component | Details |
|-----------|---------|
| Monitor | Samsung Odyssey G93SC (32:9, native 5120x1440) |
| Dock | ThinkPad Hybrid USB-C with USB-A Dock (USB ID `17e9:6015`) |
| EVDI | 1.15.0 (latest); 1.14.16 via [v1.14.16 release](https://github.com/PiRifle/evdi-5120x1440-fix/releases/tag/v1.14.16) |
| Kernel | 6.17.0 |
| DisplayLink driver | 6.3.0-48 |
| Desktop | GNOME on Wayland |

## Applying the patches

```bash
sudo bash apply.sh
sudo reboot
```

Or manually:

```bash
sudo patch /usr/src/evdi-1.15.0/evdi_connector.c 0001-bypass-pixel-area-limit.patch
sudo patch /usr/src/evdi-1.15.0/evdi_connector.c 0002-inject-5120x1440-mode.patch
sudo dkms build evdi/1.15.0 --force
sudo dkms install evdi/1.15.0 --force
sudo reboot
```

> For other EVDI versions, download the matching release from the [releases page](https://github.com/PiRifle/evdi-5120x1440-fix/releases).

## Upstream status

- **Patch 1** (`pixel_area_limit`): Candidate for upstream merge. The area limit set by `DisplayLinkManager` should be the sole authority; EVDI should not apply a secondary cap that contradicts it.
- **Patch 2** (mode injection): Workaround only. The correct fix is for `DisplayLinkManager` to forward the full EDID.
