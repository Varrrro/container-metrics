# Build stage
FROM arm32v7/gcc:9 AS build
# FROM i386/gcc:latest AS build
WORKDIR /src
COPY controller.c .
RUN gcc -o controller controller.c

# Deployment stage
FROM debian:buster-slim
WORKDIR /app
COPY --from=build /src/controller .
EXPOSE 8080/udp
ENTRYPOINT [ "./controller" ]
