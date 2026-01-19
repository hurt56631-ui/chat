# ========= Build =========
FROM golang:1.22-alpine AS builder

WORKDIR /app

RUN apk add --no-cache git ca-certificates

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
    go build -o tinode-server ./server

# ========= Runtime =========
FROM alpine:3.22

RUN apk add --no-cache ca-certificates

WORKDIR /app

COPY --from=builder /app/tinode-server /usr/local/bin/tinode-server

# Tinode 配置文件路径（docker-compose 会挂载）
EXPOSE 6060

CMD ["tinode-server", "-config", "/etc/tinode.conf"]
