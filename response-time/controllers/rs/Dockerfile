# Build stage
FROM rust:1.42.0-slim-buster AS build
WORKDIR /src
COPY controller.rs .
RUN rustc controller.rs

# Deployment stage
FROM debian:buster-slim
WORKDIR /app
COPY --from=build /src/controller .
EXPOSE 8080/udp
ENTRYPOINT [ "./controller" ]
