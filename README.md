# TWRP device tree for the Samsung W2017 (SM-W2017, veyronltectc)

Working recovery: **TWRP 3.7.0_9 on our own 3.18.140 kernel** (msm8996).

Status: usable. Display, touch, inner/outer screen switching, internal storage,
microSD, adb (root shell) and MTP all work, and the same kernel also runs the
persistent log channel described below.

The kernel is the tree in `xiexgxgxgxg/android_kernel_samsung_veyronltectc`,
branch `lineage-18.1`. It started from the untouched Samsung W2017 3.18.20
source and was bumped to 3.18.140 with a three-way merge against kernel.org
(3482 files taken verbatim, 410 auto-merged, 88 conflicts resolved by hand).
`W2017_PORT.md` in that repository documents the method, every deliberate
deviation and the verification steps.

## Flashing

The Odin package contains two images:

| entry | what it does |
|---|---|
| `recovery.img` | the recovery image (kernel + ramdisk + dtb) |
| `misc.img` | a bootloader control block with `command = "boot-recovery"` |

`LK` honours that word in `misc`, so the board comes up in recovery directly
after flashing instead of needing the key combination.

Because LK honours it on *every* boot, recovery has to clear it when it leaves
for the system; `recovery/root/sbin/rebootsystem.sh` does that. TWRP runs that
script from `tw_reboot()` for `rb_system`, immediately before `reboot()`.

Verified end to end: `misc[0..15] = "boot-recovery"` -> run
`/sbin/rebootsystem.sh` -> `misc[0..15] = zeroes` -> reboot boots the `boot`
partition.

Note that `adb reboot` from recovery does *not* run that script and will come
back into recovery; use the UI's Reboot System.

## Changes made to the TWRP sources

The TWRP tree in `/data/twrp/source-9.0` (Android 9 base) needed a number of
changes for this device. They are committed in the corresponding git
repositories of that tree:

| repo | commit | branch |
|---|---|---|
| `bootable/recovery` | `33959d6` recovery: configure mtp,adb once at boot | `veyron-twrp3.7.0` |
| `system/core` | `cbd6d28` init: log build tag bt30-1810 for recovery debugging | `veyron-twrp3.7.0` |

Both are local commits on top of the TeamWin / omnirom upstream remotes, so
they are *not* pushed anywhere. Keep the `/data/twrp/source-9.0` tree, or the
changes are lost.

### bootable/recovery

* `etc/init.recovery.usb.rc` (new, replaces the generated file)
  - Legacy `android_usb` gadget only. The kernel Kconfig puts `USB_CONFIGFS`
    and `USB_G_ANDROID` in the same `choice`, so configfs cannot be used
    together with the Samsung gadget, and configfs never pulled the UDC up on
    this dwc3 controller.
  - The function list is written exactly once (`mtp,adb`, Samsung VID/PID
    `04E8:6860`) and everything is bound before `adbd` starts.
  - Every later `sys.usb.config` change is turned into a no-op `setprop`.
    Rewriting `functions` re-binds functionfs and kills the running adb
    connection (that was the cause of the "adb offline" loops).
  - `functionfs` is mounted here, before the gadget functions are bound;
    the mount in the generic `init.rc` was removed for the same reason.
* `etc/init.rc`
  - adbd runs as root (`service.adb.root=1` is set from the device rc) and has
    no `stdio_to_kmsg`; routing adbd stdio through kmsg can block its main
    loop on a full ring buffer.
  - The generic `mount functionfs` and the adbd restart triggers on
    `service.adb.root` are removed; both re-enumerate the gadget.
* `data.cpp`
  - MTP is enabled by default and the settings for it match this device.
* `twrp.cpp`
  - Logs the reboot reason (`VEYRON-EXIT`) before leaving the main loop.
* `etc/init.recovery.hlthchrg2*.rc`
  - `critical` flags commented out (Samsung health-charging services do not
    exist in this ramdisk, a critical service that exits reboots recovery).

### system/core/init

* `init.cpp`
  - skip `mmap_rnd_bits` hardening when the 3.18 sysctl is missing
  - `restorecon /init` failure is a warning, not fatal
  - null guards for `property_set("ro.boottime.init...")`
  - SELinux initialisation skipped (this kernel has no usable policy)
  - breadcrumb markers written to persdata for debugging
  - a fatal error is written to persdata instead of rebooting
* `log.cpp`, `security.cpp`, `property_service.cpp`
  - matching guards for the same 3.18 kernel limitations
* `system/core/adb/daemon/main.cpp`
  - adbd never drops privileges in recovery

## Changes made to the kernel

Branch `lineage-18.1`, same repository as above. Relative to the stock
Samsung 3.18.20 TWRP kernel:

* the 3.18.140 merge itself (see `W2017_PORT.md`)
* `drivers/mmc/` taken whole from the Samsung source. Merging it per hunk put
  Samsung's `sdhci-msm` on top of the upstream mmc core and produced a host
  that reported success but never moved any data, which also meant no microSD.
  `mmc_first_sd_card()` is added on top for `veyron_sdlog`.
* `drivers/usb/{gadget,dwc3,phy}` taken whole from the Samsung source for the
  same reason.
* USB configuration matched to the verified 3.18.20 package:
  `USB_ANDROID_SAMSUNG_MTP`, `USB_ANDROID_SAMSUNG_SIDESYNC`, `USB_DUN_SUPPORT`
  and `USB_NCM_SUPPORT_MTU_CHANGE` are **off**, so `android.c` pulls in the
  standard `f_mtp.c` instead of Samsung's fork. This is what made adb and MTP
  behave on Windows.
* `drivers/usb/gadget/Makefile`: `-I` for its own directory, because
  `f_mtp.c` includes `"configfs.h"` through a nested include from `android.c`.
* `CONFIG_SEC_RESTRICT_SETUID`, `SEC_RESTRICT_FORK`, `SEC_RESTRICT_ROOTING`
  disabled, so `adb shell` is a root shell and setuid helpers no longer trip
  Samsung's rooting detection (which reboots the device).
* `drivers/misc/veyron_sdlog.c` (new, `CONFIG_VEYRON_SDLOG`): writes the tail
  of the kernel log into a 16 KiB region at `csd.capacity - 16384` on the
  microSD with raw CMD24, bypassing the block layer, every 300 ms. Survives a
  power cycle. With no card inserted it just polls and never blocks.
* `CONFIG_RKP_CFP` / `CONFIG_RKP_CFP_JOPP` disabled: Samsung's post-link
  instrumenter needs a cross `gdb` that the build host does not have.

## Ramdisk scripts (this device tree)

* `recovery/root/init.recovery.qcom.rc`
  - creates the `/dev/block/bootdevice` symlink that the TWRP fstab expects
  - starts the log services and the root command service
* `recovery/root/sbin/twrp-start.sh`
  - runs `/sbin/recovery` and mirrors its output and `recovery.log` to
    `/dev/kmsg`
* `recovery/root/sbin/rootsvc.sh` + `sbin/su`
  - non-setuid root command executor (`su -c ...`)
* `recovery/root/sbin/twrp-log.sh`, `persist-log.sh`, `clear-bcb.sh`
  - kernel log persistence and BCB clearing
* `recovery/root/sbin/rebootsystem.sh` (new)
  - clears the `boot-recovery` word from `misc` before "Reboot System", so the
    Odin package can boot straight into recovery without creating a loop

## Fstab

`recovery/twrp.fstab` carries the usual UFS partitions plus the card:

```
/external_sd  vfat  /dev/block/mmcblk0p1  flags=display="MicroSD";storage;wipeingui;removable
```

There is no eMMC on this board (internal storage is UFS), so `mmcblk0` is
always the microSD. Without that line recovery never mounts the card even
though the kernel exposes it, which looks like "the SD card is not detected".

## Known issues

* adb on the gadget occasionally ends up `offline`; `adb kill-server`,
  `adb start-server`, `adb reconnect offline` recovers it without a reboot.
* TWRP's `MtpServer` exits with `errno 5` when a host closes the MTP session
  and restarts; transfers work, but the restart is not clean.
* MTP is testable on Windows only. The Linux gvfs/libmtp side is unreliable
  with TWRP's MTP implementation and is not a valid test.

## Building

The recovery image is built from `omni_veyronltectc-eng`; the ramdisk is LZMA
compressed and the image is signed with the `SEANDROIDENFORCE` marker (see
`bootimg.mk`).

To swap only the kernel, repack an existing image with `mkbootimg` using
`--base 0x80000000 --kernel_offset 0x00008000 --ramdisk_offset 0x02200000
--tags_offset 0x02000000 --pagesize 4096` and append `SEANDROIDENFORCE`
without a newline.
