# --- 阶段一：下载与 UPX 压缩混淆 ---
FROM alpine:latest AS builder
RUN apk add --no-cache curl tar upx

WORKDIR /build
RUN curl -L https://github.com/SagerNet/sing-box/releases/download/v1.8.5/sing-box-1.8.5-linux-amd64.tar.gz | tar xz --strip-components=1 && \
    mv sing-box sys-daemon && \
    curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o cloud-engine && \
    chmod +x cloud-engine && \
    upx --best --lzma sys-daemon && \
    upx --best --lzma cloud-engine

# --- 阶段二：最终运行镜像 ---
FROM alpine:latest
RUN apk add --no-cache supervisor ca-certificates libc6-compat sed

WORKDIR /usr/bin/
COPY --from=builder /build/sys-daemon /usr/bin/sys-daemon
COPY --from=builder /build/cloud-engine /usr/bin/cloud-engine

# 配置文件处理
COPY config.json /etc/config.json
COPY supervisord.conf /etc/supervisord.conf
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENV VLESS_UUID=""
ENV CF_TOKEN=""

ENTRYPOINT ["/entrypoint.sh"]
