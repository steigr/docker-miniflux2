FROM docker.io/library/golang:1.10 AS miniflux2-builder
RUN  apt-get update
RUN  apt-get install -y upx-ucl
RUN go get -u -d -v github.com/miniflux/miniflux
WORKDIR /go/src/github.com/miniflux/miniflux
RUN CGO_ENABLED=0 make linux \
 && install -D -m 0755 miniflux-linux-amd64 /go/bin/linux-amd64/miniflux
ARG UPX_ARGS=-6
RUN upx ${UPX_ARGS} $(find "${GOBIN:-/go/bin}" -name miniflux)

FROM docker.io/library/alpine:3.7 AS miniflux2
RUN  apk add --no-cache ca-certificates
ENV POLLING_FREQUENCY=15 \
    LISTEN_ADDR=0.0.0.0:8080
COPY dockerfiles/ /
COPY --from=miniflux2-builder /go/bin/linux-amd64/miniflux /bin/miniflux
CMD ["miniflux"]