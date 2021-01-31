#!/bin/sh

# Download and install Xray
mkdir /tmp/xray
curl -L -H "Cache-Control: no-cache" -o /tmp/xray/xray.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip
unzip /tmp/xray/xray.zip -d /tmp/xray
install -m 755 /tmp/xray/xray /usr/local/bin/xray

# Remove temporary directory
rm -rf /tmp/xray

# V2Ray new configuration
install -d /usr/local/etc/xray
cat << EOF > /usr/local/etc/xray/config.json
{
"inbounds":[
    {
  "port": $PORT,
  "protocol": "vless",
  "settings": {
    "clients": [
      {
        "id": "$UUID",
        "level": 0,
        "email": "114514@heroku.com"
      }
    ],
    "decryption": "none"
  },
  "streamSettings": {
    "network": "ws",
    "security": "none",
    "wsSettings": {
      "acceptProxyProtocol": true,
      "path": "/"
    }
  }
}
]
}
EOF

# Run V2Ray
/usr/local/bin/xray -config /usr/local/etc/xray/config.json
