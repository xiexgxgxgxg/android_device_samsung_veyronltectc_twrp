#!/sbin/sh
# Persist the recovery log to persdata so it survives a dead display/reboot.
# The kernel logger uses the last 512 KiB of the partition; this script uses
# the 1 MiB area starting at offset 1 MiB.
LOGDEV=/dev/block/bootdevice/by-name/persdata
[ -e "$LOGDEV" ] || LOGDEV=/dev/block/by-name/persdata
[ -e "$LOGDEV" ] || LOGDEV=/dev/block/sda20
[ -e "$LOGDEV" ] || exit 0

i=0
while [ $i -lt 40 ]; do
    {
        echo "=== persist-log round $i ==="
        echo "--- dmesg ---"
        dmesg 2>/dev/null | tail -n 400
        echo "--- recovery.log ---"
        cat /tmp/recovery.log 2>/dev/null | tail -n 400
        echo "--- mounts ---"
        mount 2>/dev/null
        echo "--- fb ---"
        ls -l /dev/graphics 2>/dev/null
        echo "--- end ---"
    } > /tmp/persist.log 2>&1
    dd if=/tmp/persist.log of=$LOGDEV bs=4096 seek=256 conv=notrunc 2>/dev/null
    sync
    i=$((i + 1))
    sleep 3
done
