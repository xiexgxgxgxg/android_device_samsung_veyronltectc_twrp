# TWRP device tree for the Samsung W2017 (SM-W2017, veyronltectc)

Working recovery: TWRP 3.7.0_9 on the stock Samsung 3.18.20 kernel (msm8996).

Status: display, touch, dual-screen switching, internal/external storage, adb
and MTP all work. `adb shell` is a root shell.

## Changes made to the TWRP sources

The TWRP tree in `/data/twrp/source-9.0` (Android 9 base) needed a number of
changes for this device. They are committed in the corresponding git
repositories of that tree.

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

### Kernel (branch `veyron-twrp`)

* `CONFIG_SEC_RESTRICT_SETUID`, `SEC_RESTRICT_FORK`, `SEC_RESTRICT_ROOTING`
  disabled. This kernel is only used by TWRP and LineageOS; with these off,
  `adb shell` comes up as root and executing setuid helpers no longer trips
  Samsung's rooting detection (which rebooted the device).
* `CONFIG_USB_G_ANDROID=y` with `CONFIG_USB_ANDROID_SAMSUNG_COMPOSITE=y`
  (the stock build configuration) and `functions=mtp,adb`.
* `f_mtp.c`: relative `configfs.h` include, `__maybe_unused` on the helpers
  that are only used by the legacy gadget.
* `usb_notifier_qcom.c`: `set_ncm_ready` stub when the legacy gadget is off.
* `drivers/misc/veyron_lastlog.c`: clears the bootloader control block at
  late init so a recovery that cannot start does not loop back into recovery.

## Ramdisk scripts (this device tree)

* `recovery/root/init.recovery.qcom.rc`
  - creates the `/dev/block/bootdevice` symlink that the TWRP fstab expects
  - starts the log services and the root command service
* `recovery/root/sbin/twrp-start.sh`
  - runs `/sbin/recovery` and mirrors its output and `recovery.log` to
    `/dev/kmsg`
* `recovery/root/sbin/rootsvc.sh` + `sbin/su`
  - non-setuid root command executor (`su -c ...`). Verified: the device
    reboots if a setuid-root helper is executed on this kernel with Samsung's
    restrictions enabled, so no setuid binary is installed.
* `recovery/root/sbin/twrp-log.sh`, `persist-log.sh`, `clear-bcb.sh`
  - kernel log persistence and BCB clearing

## Known issues

* TWRP's `MtpServer` exits with `errno 5` when a host closes the MTP session
  and restarts; transfers work, but the restart is not clean.
* The 3.18.140 kernel upgrade is work in progress (branch `wip-318140`,
  79 files / 146 conflict regions left).

## Building

The recovery image is built from `omni_veyronltectc-eng` with the prebuilt
kernel in `prebuilt/Image.gz`; the ramdisk is LZMA compressed and the image is
signed with the `SEANDROIDENFORCE` marker (see `bootimg.mk`).
