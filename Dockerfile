# ========= Build stage =========
FROM golang:1.22-alpine AS builder

WORKDIR /app

# 安装必要工具
RUN apk add --no-cache git ca-certificates

# 【关键修改】设置 Go 代理加速下载，解决 go mod download 失败问题
ENV GOPROXY=https://goproxy.io,direct

# 先拷贝依赖文件进行下载，利用 Docker 缓存
COPY go.mod go.sum ./
RUN go mod download

# 拷贝剩余源码
COPY . .

# 编译 Tinode Server
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
    go build -o tinode-server ./server

# ========= Runtime stage =========
FROM alpine:3.22

RUN apk add --no-cache ca-certificates

WORKDIR /app

# 从编译阶段拷贝生成的程序
COPY --from=builder /app/tinode-server /usr/local/bin/tinode-server

# 暴露端口
EXPOSE 6060

# 运行命令
CMD ["tinode-server", "-config", "/etc/tinode.conf"]
