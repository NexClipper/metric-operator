FROM redis:alpine
LABEL maintainer="NexCloud Jinwoong <jinwoong@nexclipper.io>"

ENV WKDIR=/data

RUN apk add --update curl bash

COPY entrypoint.sh /entrypoint.sh

WORKDIR	$WKDIR
CMD ["/entrypoint.sh"]