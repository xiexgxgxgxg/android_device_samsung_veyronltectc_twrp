#!/sbin/sh
# Start TWRP and mirror everything it prints into the kernel log.
# init gives services /dev/null for stdout/stderr, so without this a recovery
# that exits immediately leaves no trace at all.
echo "VEYRON-TWRP: launching /sbin/recovery" > /dev/kmsg
/sbin/recovery > /tmp/rec.out 2>&1
rc=$?
cat /tmp/rec.out > /dev/kmsg 2>/dev/null
if [ -f /tmp/recovery.log ]; then
    echo "VEYRON-TWRP: /tmp/recovery.log" > /dev/kmsg
    cat /tmp/recovery.log > /dev/kmsg 2>/dev/null
fi
echo "VEYRON-TWRP: recovery exited rc=$rc" > /dev/kmsg
exit $rc
