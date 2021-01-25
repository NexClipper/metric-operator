FROM alpine as installer

RUN apk add --update curl

## KubeCTL Download ##
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl && \
  chmod +x kubectl && mv kubectl /usr/bin/

FROM redis:alpine
LABEL maintainer="NexCloud Jinwoong <jinwoong@nexclipper.io>"

ENV WKDIR=/data

COPY entrypoint.sh /entrypoint.sh
COPY --from=installer /usr/bin/kubectl /usr/bin/kubectl

WORKDIR	$WKDIR
CMD ["/entrypoint.sh"]