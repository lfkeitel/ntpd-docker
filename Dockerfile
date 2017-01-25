FROM debian:jessie

MAINTAINER Lee Keitel <lfkeitel [at] usi.edu>

ENV TZ=UTC

ADD docker/s6 /app/s6
ADD https://github.com/tianon/gosu/releases/download/1.10/gosu-amd64 /usr/sbin/gosu

COPY docker-entrypoint.sh /docker-entrypoint.sh

ADD https://github.com/just-containers/s6-overlay/releases/download/v1.11.0.1/s6-overlay-amd64.tar.gz /tmp/
RUN tar xzf /tmp/s6-overlay-amd64.tar.gz -C /

RUN apt-get update && apt-get install -y ntp tzdata \
    && rm -rf /var/lib/apt/lists/* \
    && chmod +x /usr/sbin/gosu \
    && chmod +x /docker-entrypoint.sh

EXPOSE 123/udp

ENTRYPOINT ["/docker-entrypoint.sh"]
