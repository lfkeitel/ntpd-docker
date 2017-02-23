#!/bin/sh

NTPD_CONFIG=/etc/ntp.conf
NTPD_STATS_DIR=/var/log/ntpstats
DEFAULT_SERVERS='0.pool.ntp.org 1.pool.ntp.org 2.pool.ntp.org 3.pool.ntp.org'
STATS_ENABLED=${STATS_ENABLED:-true}
CRON_ENABLED=${CRON_ENABLED:-$STATS_ENABLED}
ALLOWED_PEERS=${ALLOWED_PEERS:-}

mkdir -p $NTPD_STATS_DIR
chown -R ntp:ntp $NTPD_STATS_DIR

# If the file exists either from a image based on this one
# or from a volume mount, don't mess with it.
if [ ! -e "$NTPD_CONFIG" ]; then
    echo "Generating configuration"

    # Setup base configuration
    cat > "$NTPD_CONFIG" <<'EOF'
interface listen all
driftfile /var/lib/ntp/ntp.drift

restrict default kod notrap nomodify nopeer
restrict -6 default kod notrap nomodify nopeer

restrict 127.0.0.1
restrict ::1

server 127.127.1.0 # local clock
fudge 127.127.1.0 stratum 10

logfile /dev/stdout
EOF

    SERVERS_IBURST=${SERVERS_IBURST:-}
    SERVERS=${SERVERS:-}

    # Setup servers
    if [ -z "$SERVERS" -a -z "$SERVERS_IBURST" ]; then
        SERVERS_IBURST=$DEFAULT_SERVERS
    fi

    for SERVER in $SERVERS; do
        echo "server $SERVER" >> $NTPD_CONFIG
    done

    for SERVER in $SERVERS_IBURST; do
        echo "server $SERVER iburst" >> $NTPD_CONFIG
    done

    for SERVER in $ALLOWED_PEERS; do
        echo "restrict $SERVER kod notrap nomodify" >> $NTPD_CONFIG
    done

    # Enable statistics
    if [ "$STATS_ENABLED" = "true" ]; then
        echo "Stats enabled"

        cat >> "$NTPD_CONFIG" <<EOF
statsdir $NTPD_STATS_DIR/
statistics loopstats peerstats clockstats
filegen loopstats file loopstats type day enable
filegen peerstats file peerstats type day enable
filegen clockstats file clockstats type day enable
EOF
    else
        echo "Stats disabled"
    fi
fi

# Disable cron if stats are disabled or cron was explicitly disabled
if [ "$STATS_ENABLED" != "true" -o "$CRON_ENABLED" != "true" ]; then
    echo "Cron disabled"
    mkdir /app/s6-disabled
    mv /app/s6/cron /app/s6-disabled/cron
else
    echo "Cron enabled"
fi

echo "Starting services"
s6-svscan /app/s6/
