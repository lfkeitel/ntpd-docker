#!/bin/sh

NTPD_CONFIG=/etc/ntpd.conf
SETUP_FILE=/etc/.ntpd.setup

if [ ! -e "$SETUP_FILE" ]; then
    rm -f $NTPD_CONFIG

    echo "listen on *" > $NTPD_CONFIG

    cat > $NTPD_CONFIG <<'EOF'
listen on *
restrict default limited kod nomodify notrap nopeer
restrict 127.0.0.1
server  127.127.1.0
fudge   127.127.1.0 stratum 10
logfile /dev/stdout
EOF

    SERVERS_IBURST=${SERVERS_IBURST:-}
    SERVERS=${SERVERS:-}

    if [ -z "$SERVERS" -a -z "$SERVERS_IBURST" ]; then
        SERVERS_IBURST="pool.ntp.org"
    fi

    for SERVER in $SERVERS; do
        echo "servers $SERVER" >> $NTPD_CONFIG
    done

    for SERVER in $SERVERS_IBURST; do
        echo "servers $SERVER iburst" >> $NTPD_CONFIG
    done

    touch $SETUP_FILE
fi

s6-svscan /app/s6/