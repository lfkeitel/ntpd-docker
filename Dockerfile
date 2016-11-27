FROM alpine:3.4

MAINTAINER Kim Goh <jggao [at] clustertech.com>

ENV TZ=UTC

ADD docker/s6 /app/s6
ADD https://github.com/tianon/gosu/releases/download/1.10/gosu-amd64 /usr/sbin/gosu

EXPOSE 123/udp

RUN apk --update --no-cache add bash s6 openntpd tzdata \
    && sed -i 's/#listen on/listen on/' /etc/ntpd.conf \
    && chmod +x /usr/sbin/gosu

ENTRYPOINT ["s6-svscan", "/app/s6/"]
CMD []
