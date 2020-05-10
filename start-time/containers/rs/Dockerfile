# Build stage
FROM rust:1.42.0-slim-buster AS build
WORKDIR /src
COPY pinger.rs .
RUN rustc pinger.rs

# Deployment stage
FROM debian:buster-slim
WORKDIR /app
COPY --from=build /src/pinger .
ENTRYPOINT [ "./pinger" ]
