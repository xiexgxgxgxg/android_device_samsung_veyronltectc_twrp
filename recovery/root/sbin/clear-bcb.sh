#!/sbin/sh
#
# Clear the Android bootloader control block (BCB) as soon as recovery starts.
#
# Android and Odin both ask the bootloader for "boot-recovery" by writing the
# command field of misc; the bootloader only reads it once, but if recovery
# dies before clearing it the device would keep booting recovery. Zeroing the
# first 32 bytes (command) leaves the rest of misc untouched.

MISC=/dev/block/bootdevice/by-name/misc

[ -e "$MISC" ] || exit 0
dd if=/dev/zero of="$MISC" bs=32 count=1 conv=notrunc 2>/dev/null
sync
