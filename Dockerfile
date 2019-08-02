ARG target

FROM quay.io/prometheus/golang-builder as builder

ENV GO111MODULE on

ARG goarch
ENV GOARCH $goarch

WORKDIR /go/src/github.com/justwatchcom/elasticsearch_exporter
COPY . ./
COPY promu /go/bin/

RUN GOARCH=$goarch make build && cp ./elasticsearch_exporter /bin/

FROM $target/alpine
LABEL maintainer="Jesse Stuart <hi@jessestuart.com>"

COPY qemu-* /usr/bin/

EXPOSE      9114
COPY --from=builder /bin/elasticsearch_exporter /bin/elasticsearch_exporter

ENTRYPOINT  [ "/bin/elasticsearch_exporter" ]
