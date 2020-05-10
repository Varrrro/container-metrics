# Build stage
FROM golang:1.14-alpine3.11 AS build
WORKDIR /src
COPY controller.go .
RUN go build controller.go

# Deployment stage
FROM alpine:3.11
WORKDIR /app
COPY --from=build /src/controller .
EXPOSE 8080/udp
ENTRYPOINT [ "./controller" ]
