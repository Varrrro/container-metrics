# Build stage
FROM arm32v7/gcc:9 AS build
# FROM i386/gcc:latest AS build
WORKDIR /src
COPY pinger.c .
RUN gcc -o pinger pinger.c

# Deployment stage
FROM debian:buster-slim
WORKDIR /app
COPY --from=build /src/pinger .
ENTRYPOINT [ "./pinger" ]
