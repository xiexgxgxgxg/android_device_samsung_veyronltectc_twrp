#!/sbin/sh
#
# Persist TWRP logs to the cache partition so they survive a reboot.
#
# The W2017 has no known key combination that reaches recovery, so a recovery
# that boots with a dark panel can only be diagnosed from adb or from a log
# written to a physical partition. This service writes to /cache (ext4, not
# encrypted, never touched by the system while recovery runs) and mirrors the
# directory to /data/media once internal storage is mounted.

CACHE_DEV=/dev/block/bootdevice/by-name/cache
OUT=/cache/twrplog

mkdir -p /cache 2>/dev/null
mount -t ext4 -o rw "$CACHE_DEV" /cache 2>/dev/null
mkdir -p "$OUT" 2>/dev/null || exit 1

echo "start: $(date)" > "$OUT/stage.txt"
cat /proc/cmdline > "$OUT/cmdline.txt" 2>&1
cat /proc/bus/input/devices > "$OUT/input.txt" 2>&1
cat /sys/class/lcd/panel/lcd_type > "$OUT/lcd_type.txt" 2>&1
cat /sys/class/graphics/fb0/modes > "$OUT/fb0_modes.txt" 2>&1
cat /sys/class/graphics/fb1/modes > "$OUT/fb1_modes.txt" 2>&1
cat /sys/class/graphics/fb0/mode > "$OUT/fb0_mode.txt" 2>&1
sync

i=0
while [ $i -lt 120 ]; do
    dmesg > "$OUT/dmesg.txt" 2>/dev/null
    cp /tmp/recovery.log "$OUT/recovery.log" 2>/dev/null
    echo "tick $i: $(date)" >> "$OUT/stage.txt"
    sync
    i=$((i + 1))
    # Mirror once into internal storage, which is easier to pull from Android.
    if [ $i -eq 6 ] && [ -d /data/media ]; then
        mkdir -p /data/media/twrplog 2>/dev/null
        cp -r "$OUT"/. /data/media/twrplog/ 2>/dev/null
        sync
    fi
    sleep 5
done
