#!/bin/sh

# Config Caddy
cat << EOF > /etc/caddy/Caddyfile
:$PORT
root * /usr/share/caddy
file_server
@websockets_heroku {
header Connection *Upgrade*
header Upgrade    websocket
path $WSPATH
}
reverse_proxy @websockets_heroku 127.0.0.1:14514
EOF

# Download and install Xray
mkdir /tmp/xray
curl -L -H "Cache-Control: no-cache" -o /tmp/xray/xray.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip
unzip /tmp/xray/xray.zip -d /tmp/xray
install -m 755 /tmp/xray/xray /usr/local/bin/xray
install -m 755 /tmp/xray/geosite.dat  /usr/local/bin/geosite.dat
install -m 755 /tmp/xray/geoip.dat  /usr/local/bin/geoip.dat

# Remove temporary directory
rm -rf /tmp/xray

# V2Ray new configuration
install -d /usr/local/etc/xray
cat << EOF > /usr/local/etc/xray/config.json
{
    "inbounds": 
    [
        {
            "port": 14514,"listen": "127.0.0.1","protocol": "vless",
            "settings": {"clients": [{"id": "$UUID"}],"decryption": "none"},
            "streamSettings": {"network": "ws","wsSettings": {"path": "/"}}
        }
    ],
	
    "outbounds": 
    [
        {"protocol": "freedom","tag": "direct","settings": {}},
        {"protocol": "socks","tag": "sockstor","settings": {"servers": [{"address": "127.0.0.1","port": 9050}]}},
        {"protocol": "blackhole","tag": "blocked","settings": {}}
    ],
	
    "routing": 
    {
        "rules": 
        [
            {"type": "field","outboundTag": "blocked","domain": ["geosite:private","geosite:category-ads-all"]},
            {"type": "field","outboundTag": "sockstor","domain": ["geosite:tor"]}
        ]
    }
}	
EOF

nohup tor &
caddy run --config /etc/caddy/Caddyfile --adapter caddyfile &
# Run V2Ray
/usr/local/bin/xray -config /usr/local/etc/xray/config.json
