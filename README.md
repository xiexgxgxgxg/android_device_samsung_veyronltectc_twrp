# TWRP 3.7.0 device tree — Samsung W2017 (SM-W2017 / veyronltectc)

> **STATUS: WORK IN PROGRESS — NOT TESTED ON HARDWARE, DO NOT FLASH BLINDLY.**
>
> Boot image geometry and prebuilt kernel/dtb were taken from the stock
> `recovery.img` of `W2017KEU1ARG1` (identical layout in `W2017KEU1APJ7`), so the
> tree should now produce a recovery.img with the right header. Partition sizes
> and the fstab still need verification on the device.

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

## Values taken from the stock firmware

| Value | Source |
|---|---|
| `BOARD_KERNEL_BASE` 0x80000000, offsets `0x8000`/`0x2200000`/`0x2000000` | stock `recovery.img` header |
| `--board RILPF15A000RU` | stock recovery (boot uses `...KU`) |
| cmdline `console=null androidboot.hardware=qcom ...` | stock recovery |
| `prebuilt/Image.gz`, `prebuilt/dtb.img` (QCDT, 1872144 bytes) | stock recovery |
| fstab entries | stock `fstab.qcom` (`system`, `userdata`, `efs`, `hidden`→preload) |

## Still to verify on the device

- Partition sizes (`blockdev --getsize64 /dev/block/bootdevice/by-name/*`) —
  current values come from the PIT and image sizes.
- Whether recovery boots on the inner or outer panel (the kernel picks the panel
  from the folder hall state), and whether TWRP's touch maps correctly.
- Keypad keylayout.
- Encrypted /data (6.0.1 uses FDE with a footer; `TW_INCLUDE_CRYPTO` is off).

## Build

```bash
# inside a TWRP 3.7.0 (twrp-12.1 / omni) checkout
source build/envsetup.sh
lunch omni_veyronltectc-eng
mka recoveryimage
```

Output: `out/target/product/veyronltectc/recovery.img` plus an Odin-flashable
`recovery.tar` (produced by `bootimg.mk`).
