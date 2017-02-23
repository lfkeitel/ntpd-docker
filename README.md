# ntpd Server Docker Image

## Usage

`docker run --name ntp -d -p 123:123/udp lfkeitel/ntpd`

The image exposes NTP port 123/udp.

## Configuration

The configuration is located at `/etc/ntp.conf` and by default following will be generated:

```
interface listen all
driftfile /var/lib/ntp/ntp.drift

statsdir /var/log/ntpstats/

statistics loopstats peerstats clockstats
filegen loopstats file loopstats type day enable
filegen peerstats file peerstats type day enable
filegen clockstats file clockstats type day enable

restrict default kod notrap nomodify nopeer
restrict -6 default kod notrap nomodify nopeer

restrict 127.0.0.1
restrict ::1

server 127.127.1.0 # local clock
fudge 127.127.1.0 stratum 10

logfile /dev/stdout

server 0.pool.ntp.org iburst
server 1.pool.ntp.org iburst
server 2.pool.ntp.org iburst
server 3.pool.ntp.org iburst
```

### Custom Servers

To set servers, use the environment variables `SERVERS` and `SERVERS_IBURST`. `SERVERS_IBURST` will simply add the `iburst` option for the servers in the list. If no servers are specified, servers from the global NTP pool are used. Servers are space separated so make sure to enclose them in quotes.

```sh
docker run \
    --name ntp \
    -e SERVERS_IBURST='0.pool.ntp.org 1.pool.ntp.org'
    lfkeitel/ntpd:latest
```

Any other configuration can be done by either making a new image from this one with a custom config, or using a volume mount to `/etc/ntp.conf`.

## Statistics

Statistics for loopstats, peerstats, and clockstats are enabled by default and are stored in `/var/log/ntpstats` which is exposed as a volume. You can control this with the environment variables `STATS_ENABLED` and `CRON_ENABLED`. Unless specified otherwise, `CRON_ENABLED` will be the same as `STATS_ENABLED`. Cron is used to rotate NTP statistics logs. If you don't want to rotate logs, set `CRON_ENABLED=false`. To disable statistics altogether, set `STATS_ENABLED=false`. If statistics are disabled, cron will also be disabled.

## Peers

By default, no servers are allowed to peer with ntpd. The environment variable `ALLOWED_PEERS` can be used to list servers that are allowed to peer. This list will generate restict lines with the format `restrict $SERVER kod notrap nomodify`.