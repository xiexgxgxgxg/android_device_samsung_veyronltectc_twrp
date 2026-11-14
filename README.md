# TWRP 3.7.0 device tree — Samsung W2017 (SM-W2017 / veyronltectc)

> **STATUS: WORK IN PROGRESS — NOT FLASHABLE.**
>
> The tree compiles only after the placeholders in `BoardConfig.mk` are replaced
> with values read from the device's own stock images. Flashing a wrong recovery
> to a Samsung bootloader-unlocked device can hard-brick it.

## What this is

A TWRP 3.7.0 device tree skeleton for the Samsung W2017 (Snapdragon 820 msm8996,
China Telecom CTC). It is based on the structure of the Samsung msm8996 TWRP
trees (`heroqltechn`) and the LineageOS 18.1 device tree in
`android_device_samsung_veyronltectc`.

## Known hardware quirks

* **Dual panel.** The kernel picks the active panel via
  `samsung,mdss_dsi_lcd_sel_gpio` (TLMM GPIO 1) based on the folder hall IC
  (PM8994 GPIO 7). TWRP inherits this because it runs the stock kernel — but the
  UI may come up on the outer panel, or rotated, depending on the lid state at
  boot. Verify before assuming the display is broken.
* **Keypad.** Physical T9 keypad; TWRP's key handling needs the stock keylayout.
* **Samsung bootloader.** Recovery images must be flashed through Odin as a
  `.tar`, and the bootloader requires the `SEANDROIDENFORCE` trailer (see
  `bootimg.mk`) unless the image is signed.

## Placeholders that MUST be filled in

| Value | Where it comes from |
|---|---|
| `BOARD_KERNEL_BASE`, offsets, `--board` string, cmdline | `unpackbootimg` on stock `recovery.img` |
| `TARGET_PREBUILT_KERNEL` / `TARGET_PREBUILT_DTB` | stock `recovery.img` (kernel + dtb) |
| `BOARD_RECOVERYIMAGE_PARTITION_SIZE` etc. | PIT (`W2017*.pit`) or `ls -l /dev/block/bootdevice/by-name/` |
| `twrp.fstab` entries | stock `recovery.img` ramdisk `fstab.qcom` |

Put the extracted `Image.gz` / `dtb.img` into `prebuilt/` (see
`prebuilt/README.md`). Once the device is available, `twrpdtgen` on the stock
`recovery.img` can bootstrap most of these values.

## Build

```bash
# inside a TWRP 3.7.0 (twrp-12.1 / omni) checkout
source build/envsetup.sh
lunch omni_veyronltectc-eng
mka recoveryimage
```

Output: `out/target/product/veyronltectc/recovery.img` plus an Odin-flashable
`recovery.tar` (produced by `bootimg.mk`).
