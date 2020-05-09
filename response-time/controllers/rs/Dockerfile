# Build stage
FROM arm32v7/rust:1.42-slim-buster AS build
WORKDIR /src
COPY controller.rs .
RUN rustc controller.rs

# Deployment stage
FROM arm32v7/debian:buster-slim
WORKDIR /app
COPY --from=build /src/controller .
EXPOSE 8080/udp
ENTRYPOINT [ "./controller" ]
