# Build stage
FROM golang:1.14-alpine3.11 AS build
WORKDIR /src
COPY pinger.go .
RUN go build pinger.go

# Deployment stage
FROM alpine:3.11
WORKDIR /app
COPY --from=build /src/pinger .
ENTRYPOINT [ "./pinger" ]
