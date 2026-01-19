# 使用最新的 Go 1.24 版本，解决 go.mod 要求 1.24 的问题
FROM golang:1.24-alpine AS builder

WORKDIR /app

# 安装 git 和证书
RUN apk add --no-cache git ca-certificates

# 【关键】强制开启全局代理加速下载
ENV GOPROXY=https://goproxy.io,direct

# 拷贝依赖文件
COPY go.mod go.sum ./
RUN go mod download

# 拷贝源码并编译
COPY . .
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
    go build -o tinode-server ./server

# 运行阶段
FROM alpine:3.22
RUN apk add --no-cache ca-certificates
WORKDIR /app
COPY --from=builder /app/tinode-server /usr/local/bin/tinode-server

EXPOSE 6060
CMD ["tinode-server", "-config", "/etc/tinode.conf"]
