# ntpd Server Docker Image

## Usage

`docker run --name ntp lfkeitel/ntpd`

## Configuration

By default, the server is setup with the following base configuration:

```
listen on *
restrict default limited kod nomodify notrap nopeer
restrict 127.0.0.1
server  127.127.1.0 # local clock
fudge   127.127.1.0 stratum 10
logfile /dev/stdout
```

To add servers, use the environment variables `SERVERS` and `SERVERS_IBURST`. `SERVERS_IBURST` will simply add the `iburst` option for the servers in the list. If no servers are specified, `pool.ntp.org` is used.

The image exposes NTP port 123/udp.