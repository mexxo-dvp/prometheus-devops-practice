FROM golang:1.24 AS builder
WORKDIR /app

COPY go.mod ./
COPY src/ ./src/
RUN cd src && CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o /app/server

FROM scratch
COPY --from=builder /app/server /server
COPY html/ /html

WORKDIR /
EXPOSE 8080
ENTRYPOINT ["/server"]
