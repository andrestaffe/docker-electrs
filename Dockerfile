ARG VERSION=v0.9.3

FROM rust:slim AS builder

ARG VERSION

WORKDIR /build

RUN apt-get update
RUN apt-get install -y git clang cmake libsnappy-dev build-essential

RUN git clone --branch $VERSION https://github.com/romanz/electrs .
RUN cargo install cross
RUN cross build --target armv7-unknown-linux-gnueabihf

FROM debian:slim

RUN adduser --disabled-password --uid 1000 --home /data --gecos "" electrs
USER electrs
WORKDIR /data

COPY --from=builder /usr/local/cargo/bin/electrs /bin/electrs

# Electrum RPC
EXPOSE 50001

# Prometheus monitoring
EXPOSE 4224

STOPSIGNAL SIGINT

ENTRYPOINT ["electrs"]
