ARG VERSION=v0.9.3

FROM rust:slim AS builder

ARG VERSION

WORKDIR /build

RUN rustup target add armv7-unknown-linux-musleabihf
RUN apt-get update
RUN apt-get install -y git clang cmake libsnappy-dev build-essential binutils-arm-linux-gnueabihf gcc-arm-linux-gnueabihf

RUN git clone --branch $VERSION https://github.com/andrestaffe/electrs.git .

RUN cargo install cross
RUN cross build --target armv7-unknown-linux-gnueabihf --release

FROM debian:bullseye-slim

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
