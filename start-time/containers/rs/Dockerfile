# Build stage
FROM arm32v7/rust:1.42-slim-buster AS build
WORKDIR /src
COPY pinger.rs .
RUN rustc pinger.rs

# Deployment stage
FROM arm32v7/debian:buster-slim
WORKDIR /app
COPY --from=build /src/pinger .
ENTRYPOINT [ "./pinger" ]
