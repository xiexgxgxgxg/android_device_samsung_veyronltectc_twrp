# Patches to the TWRP sources

The recovery for this device is built from a TWRP 9.0 source tree
(`/data/twrp/source-9.0`, the `twrp-9.0` manifest).  Two of its git
repositories carry local commits that only exist on the build machine, because
their remotes are the upstream TeamWin / omnirom repositories and we have no
push access there.

These patches are that work, exported so it survives losing that tree.

| directory | repository | upstream base | resulting tip |
|---|---|---|---|
| `bootable-recovery/` | `bootable/recovery` | `90e5d95` (`TeamWin/android-9.0`) | `33959d6` |
| `system-core/` | `system/core` | `53782f5` (`omnirom/android-9.0`) | `cbd6d28` |

## Re-applying

In a fresh TWRP 9.0 tree:

```sh
cd bootable/recovery
git checkout 90e5d95
git am /path/to/patches/bootable-recovery/*.patch

cd ../../system/core
git checkout 53782f5
git am /path/to/patches/system-core/*.patch
```

`git am` keeps the original commit messages.  If the base has moved, `git am
-3` or `git apply --3way` will normally still apply, since the changes are
small and local to recovery code.

## What is in them

`bootable/recovery`

* `recovery: veyronltectc usb bring-up` — `etc/init.recovery.usb.rc`
  (new: legacy `android_usb` gadget, Samsung VID/PID `04E8:6860`, function
  list written once), `etc/init.rc` (root adbd, no `stdio_to_kmsg`, no generic
  `mount functionfs`), `data.cpp` (MTP defaults), the two
  `init.recovery.hlthchrg2*.rc` files (`critical` removed), plus `Android.mk`
  and `prebuilt/Android.mk` wiring.
* `recovery: configure mtp,adb once at boot` — same `init.recovery.usb.rc`
  finished off, and `twrp.cpp` logging the reboot reason.

`system/core`

* `init/adb: 3.18 msm8996 recovery fixes` — `init.cpp`, `log.cpp`,
  `security.cpp`, `selinux.cpp`, `property_service.cpp`, `service.cpp`,
  `subcontext.cpp`, `adb/daemon/main.cpp`, `libcutils/fs_config.cpp`: guards
  for the 3.18 kernel (no `mmap_rnd_bits` sysctl, no usable SELinux policy),
  `restorecon /init` non-fatal, adbd never drops privileges.
* `init: log build tag bt30-1810 for recovery debugging` — one line in
  `init.cpp` that tags the persdata breadcrumbs with the build.

## Not covered here

The kernel is a separate repository (`android_kernel_samsung_veyronltectc`,
branch `lineage-18.1`), and the ramdisk overlay, fstab and scripts are in this
device tree itself.
