FROM redis:alpine
#FROM redis:alpine3.12
LABEL maintainer="NexCloud Jinwoong <jinwoong@nexclipper.io>"

ENV WKDIR=/data

RUN apk add --no-cache --update curl jq
COPY entrypoint.sh /entrypoint.sh

WORKDIR	$WKDIR
CMD ["/entrypoint.sh"]
