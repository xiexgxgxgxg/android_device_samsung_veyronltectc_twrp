#!/sbin/sh
#
# TWRP runs this right before "Reboot System".
#
# The Odin package we flash ships a misc partition whose bootloader control
# block says "boot-recovery", so that the device boots into recovery straight
# after flashing instead of needing the key combination.  LK keeps honouring
# that word on every boot, so without clearing it here "Reboot System" would
# come back to recovery forever.
#
# Clearing the command field is enough; LK then boots the boot partition.

MISC=/dev/block/bootdevice/by-name/misc

[ -e "$MISC" ] || exit 0
dd if=/dev/zero of="$MISC" bs=32 count=1 2>/dev/null
sync
