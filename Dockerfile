ARG target

FROM golang:1.12-alpine as builder

ENV GO111MODULE on

ARG goarch
ENV GOARCH $goarch

COPY .  /go/src/github.com/justwatchcom/elasticsearch_exporter
WORKDIR /go/src/github.com/justwatchcom/elasticsearch_exporter

# RUN apk update && apk add make git && make
RUN GOARCH=$goarch make

COPY elasticsearch_exporter /bin/elasticsearch_exporter

FROM $target/alpine

COPY qemu-* /usr/bin/

LABEL maintainer="Jesse Stuart <hi@jessestuart.com>"

COPY --from=builder /bin/elasticsearch_exporter /bin/elasticsearch_exporter

EXPOSE      9108
ENTRYPOINT  [ "/bin/elasticsearch_exporter" ]
