#!/sbin/sh
#
# Root command executor. This service is started by init with uid 0, so it can
# run privileged commands without needing any setuid binary (the Samsung kernel
# restricts setuid and reboots when a setuid-root helper is executed in
# recovery). adb shell (uid 2000) talks to it through /tmp/su.cmd.

while true; do
    if [ -f /tmp/su.cmd ]; then
        mv /tmp/su.cmd /tmp/su.run 2>/dev/null
        if [ -f /tmp/su.run ]; then
            umask 022
            /sbin/sh /tmp/su.run > /tmp/su.out 2>&1
            echo $? > /tmp/su.rc
            chmod 644 /tmp/su.out /tmp/su.rc
            rm -f /tmp/su.run
        fi
    fi
    sleep 1
done
