# Build stage
FROM arm32v7/golang:1.14-alpine3.11 AS build
WORKDIR /src
COPY go.mod master.go ./
RUN go mod download
RUN go build master.go

# Deployment stage
FROM arm32v7/alpine:3.11
WORKDIR /app
COPY --from=build /src/master .
EXPOSE 8080/udp
ENTRYPOINT [ "./master" ]
