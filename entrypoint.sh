#!/bin/sh

# 使用 sed 替换占位符并直接覆盖原文件
# 如果未设置 VLESS_UUID，则默认为全零 UUID 
sed -i "s/\${VLESS_UUID}/${VLESS_UUID:-00000000-0000-0000-0000-000000000000}/g" /etc/config.json

# 启动进程管理器
exec /usr/bin/supervisord -c /etc/supervisord.conf
