# TWRP 3.7 device tree — Samsung W2017 (SM-W2017 / veyronltectc)

> **STATUS: WORK IN PROGRESS — NOT TESTED ON HARDWARE.**
>
> Boot image geometry, kernel and dtb come from the stock `recovery.img` of
> `W2017KEU1ARG1`; partition sizes were read from the running device with
> `blockdev`. The tree is expected to compile; whether recovery can bring up the
> panel is the open question.

## Device facts used here

| | |
|---|---|
| SoC | Qualcomm Snapdragon 820 (msm8996), kernel 3.18.20 |
| Stock recovery | `W2017KEU1ARG1`, boot header v0 + `QCDT` dt appended |
| Boot geometry | base `0x80000000`, kernel `0x8000`, ramdisk `0x2200000`, tags `0x2000000`, page 4096, board `RILPF15A000RU` |
| Partitions | boot/recovery 76 MB, system 5.5 GB, cache 200 MB, userdata 53 GB |
| Display | dual 4.2" 1080x1920 panels, switched in-kernel (`lcd_id` / `lcd_id2`, `hall_ic`) |
| Touch | Synaptics DSX (`sec_touchscreen`, event4) |
| Keypad | `veyronlte_3x4-keypad` (event2), plus `sec_touchkey` (event3) |
| USB | legacy `android_usb` gadget (no `CONFIG_USB_CONFIGFS` in the kernel) |

## Build

```bash
source build/envsetup.sh
lunch omni_veyronltectc-eng
mka recoveryimage
```

Output: `out/target/product/veyronltectc/recovery.img` and, via `bootimg.mk`,
an Odin-flashable `recovery.tar`.

## Flashing

Odin, **AP slot only**, `Auto Reboot` disabled. Before booting the system again,
mount `/system` read-write in TWRP and delete `/system/recovery-from-boot.p`,
otherwise Android restores the stock recovery on the next boot.

## Debugging without a display

There is no known key combination that reaches recovery on this device, so two
channels are prepared:

* **adb** — adbd is forced to start as root (`init.recovery.qcom.rc`).
* **on-disk log** — `twrp-log.sh` writes `dmesg`, `/tmp/recovery.log`, the kernel
  cmdline and the display/input inventory to `/cache/twrplog` every 5 s and
  mirrors it to `/data/media/twrplog`. After a failed attempt, boot Android and
  read `/cache/twrplog` (root) to see how far recovery got.

The panel is selected by the kernel from the folder hall state; recovery may
therefore come up on the outer panel. `dmesg` in the log records the mdss panel
setup, and `/sys/class/lcd/panel/force_flip` exists as a possible override.

## Still unknown

- Whether the panel lights up at all, and on which of the two screens.
- Whether TWRP's touch handling matches the Synaptics DSX driver.
- Whether the keypad produces usable events in recovery.

## Getting into recovery without a key combination

This device has no key combination that reliably reaches recovery, so the
bootloader control block (BCB) is used instead. Android and Odin ask for a
one-shot recovery boot by writing `boot-recovery` into the `misc` partition;
the bootloader reads it once and then recovery clears it.

```bash
# from rooted Android, right before starting Odin
adb shell su -c 'printf boot-recovery > /dev/block/bootdevice/by-name/misc'
```

Then flash `recovery.tar` in Odin with **Auto Reboot enabled**. The device
reboots into TWRP instead of Android. `clear-bcb.sh` wipes the command field as
soon as recovery starts, so the next reboot goes back to the system even if
recovery never manages to boot.

If the flash still lands in Android, `adb reboot recovery` does the same thing
(framework writes the same BCB).
