FROM debian:jessie

MAINTAINER Lee Keitel <lfkeitel [at] usi.edu>

ENV TZ=UTC

RUN apt-get update && apt-get install -y ntp tzdata cron \
    && rm -rf /var/lib/apt/lists/*

ADD docker/s6 /app/s6
ADD https://github.com/tianon/gosu/releases/download/1.10/gosu-amd64 /usr/sbin/gosu
ADD https://github.com/just-containers/s6-overlay/releases/download/v1.11.0.1/s6-overlay-amd64.tar.gz /tmp/

COPY docker-entrypoint.sh /docker-entrypoint.sh

RUN tar xzf /tmp/s6-overlay-amd64.tar.gz -C / \
    && chmod +x /usr/sbin/gosu \
    && chmod +x /docker-entrypoint.sh \
    && rm /etc/ntp.conf

EXPOSE 123/udp

VOLUME /var/log/ntpstats

ENTRYPOINT ["/docker-entrypoint.sh"]
