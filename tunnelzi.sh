#!/bin/bash

# Configuration paths
CONFIG_DIR="/etc/tunnelzi"
BACKHAUL_BIN="/usr/local/bin/backhaul"
TUNNEL_DIR="$CONFIG_DIR/tunnels"
SYSTEMD_DIR="/etc/systemd/system"
NGROK_BIN="/usr/local/bin/ngrok"
V2RAY_BIN="/usr/local/bin/v2ray"
STUNNEL_CONF_DIR="/etc/stunnel"

# Check for root privileges
if [ "$EUID" -ne 0 ]; then
    echo "❌ This script must be run as root (use sudo)."
    exit 1
fi

# Create necessary directories
mkdir -p "$TUNNEL_DIR" "$STUNNEL_CONF_DIR" || { echo "❌ Failed to create directories"; exit 1; }

show_help() {
    echo "🔧 Tunnelzi - Tunnel Management Tool"
    echo "------------------------------------"
    echo "Usage:"
    echo "  tunnelzi create           Create a new tunnel"
    echo "  tunnelzi list             List all tunnels"
    echo "  tunnelzi delete NAME      Delete a tunnel"
    echo "  tunnelzi start NAME       Start tunnel service"
    echo "  tunnelzi stop NAME        Stop tunnel service"
    echo "  tunnelzi enable NAME      Enable tunnel service on boot"
    echo "  tunnelzi disable NAME     Disable tunnel service on boot"
    echo "  tunnelzi help             Show this help message"
    echo ""
}

ask() {
    read -rp "$1: " "$2"
}

check_and_install() {
    local cmd=$1
    local pkg=$2

    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "⚠️ $cmd is not installed. Installing $pkg..."
        apt update && apt install -y "$pkg"
        if [ $? -ne 0 ]; then
            echo "❌ Failed to install $pkg. Please install it manually."
            exit 1
        fi
        echo "✅ $pkg installed successfully."
    fi
}

install_backhaul() {
    if [ ! -x "$BACKHAUL_BIN" ]; then
        echo "⚠️ Backhaul binary not found. Downloading..."
        wget -O /tmp/backhaul "https://github.com/mmatczuk/go-http-tunnel/releases/latest/download/backhaul-linux-amd64" || { echo "❌ Failed to download backhaul"; exit 1; }
        mv /tmp/backhaul "$BACKHAUL_BIN" && chmod +x "$BACKHAUL_BIN" || { echo "❌ Failed to install backhaul"; exit 1; }
        echo "✅ Backhaul installed successfully."
    fi
}

install_ngrok() {
    if [ ! -x "$NGROK_BIN" ]; then
        echo "⚠️ ngrok binary not found. Downloading..."
        wget -O /tmp/ngrok.zip "https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.zip" || { echo "❌ Failed to download ngrok"; exit 1; }
        unzip -o /tmp/ngrok.zip -d /usr/local/bin/ || { echo "❌ Failed to unzip ngrok"; exit 1; }
        chmod +x "$NGROK_BIN" || { echo "❌ Failed to set permissions for ngrok"; exit 1; }
        rm /tmp/ngrok.zip
        echo "✅ ngrok installed successfully."
    fi
}

install_v2ray() {
    if [ ! -x "$V2RAY_BIN" ]; then
        echo "⚠️ V2Ray binary not found. Downloading..."
        wget -O /tmp/v2ray.zip "https://github.com/v2fly/v2ray-core/releases/latest/download/v2ray-linux-64.zip" || { echo "❌ Failed to download V2Ray"; exit 1; }
        unzip -o /tmp/v2ray.zip -d /tmp/v2ray/ || { echo "❌ Failed to unzip V2Ray"; exit 1; }
        mv /tmp/v2ray/v2ray "$V2RAY_BIN" || { echo "❌ Failed to move V2Ray binary"; exit 1; }
        chmod +x "$V2RAY_BIN" || { echo "❌ Failed to set permissions for V2Ray"; exit 1; }
        rm -rf /tmp/v2ray /tmp/v2ray.zip
        echo "✅ V2Ray installed successfully."
    fi
}

create_service_file() {
    local name="$1"
    local service_path="$SYSTEMD_DIR/tunnelzi-$name.service"

    # Create systemd service file
    cat > "$service_path" <<EOF
[Unit]
Description=Tunnelzi Tunnel $name
After=network.target

[Service]
Type=simple
ExecStart=$TUNNEL_DIR/$name.sh
Restart=always
RestartSec=5
User=nobody
Group=nogroup
Environment="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

[Install]
WantedBy=multi-user.target
EOF

    chmod 644 "$service_path" || { echo "❌ Failed to set permissions for $service_path"; exit 1; }
    systemctl daemon-reload || { echo "❌ Failed to reload systemd daemon"; exit 1; }
    echo "✅ systemd service created at $service_path"
}

validate_tunnel_name() {
    local name="$1"
    if [[ ! "$name" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        echo "❌ Tunnel name can only contain letters, numbers, hyphens (-), and underscores (_)."
        exit 1
    fi
    if [ -f "$TUNNEL_DIR/$name.sh" ]; then
        echo "❌ Tunnel '$name' already exists."
        exit 1
    fi
}

create_tunnel() {
    echo "📡 Choose tunnel type:"
    echo "1) Backhaul Tunnel"
    echo "2) SSH Reverse Tunnel"
    echo "3) SSH Local Tunnel"
    echo "4) SSH Dynamic SOCKS5 Tunnel"
    echo "5) Socat TCP Tunnel"
    echo "6) WireGuard Tunnel"
    echo "7) OpenVPN Tunnel"
    echo "8) GRE Tunnel"
    echo "9) HTTP/HTTPS Tunnel (stunnel)"
    echo "10) V2Ray/Vmess Tunnel"
    read -rp "Enter the number: " tunnel_type

    ask "Unique tunnel name" name
    if [ -z "$name" ]; then
        echo "❌ Tunnel name cannot be empty."
        return
    fi
    validate_tunnel_name "$name"

    case $tunnel_type in
        1)
            install_backhaul
            echo "🎯 Backhaul Tunnel Configuration"
            ask "Server address" server
            ask "Server port" port
            ask "Local port to forward" local_port

            CONFIG_PATH="$TUNNEL_DIR/$name.toml"
            cat > "$CONFIG_PATH" <<EOF
[client]
remote_addr = "$server:$port"

[[client.services]]
name = "$name"
local_addr = "127.0.0.1:$local_port"
EOF
            echo "# Backhaul tunnel launcher" > "$TUNNEL_DIR/$name.sh"
            echo "$BACKHAUL_BIN -c $CONFIG_PATH" >> "$TUNNEL_DIR/$name.sh"
            chmod +x "$TUNNEL_DIR/$name.sh" || { echo "❌ Failed to set permissions for $TUNNEL_DIR/$name.sh"; exit 1; }
            echo "✅ Backhaul tunnel '$name' created."
            ;;
        2)
            check_and_install ssh openssh-client
            echo "🎯 SSH Reverse Tunnel Configuration"
            ask "Remote server (user@host)" ssh_target
            ask "Remote port to open" remote_port
            ask "Local port to forward" local_port

            echo "ssh -N -R $remote_port:localhost:$local_port $ssh_target" > "$TUNNEL_DIR/$name.sh"
            chmod +x "$TUNNEL_DIR/$name.sh" || { echo "❌ Failed to set permissions for $TUNNEL_DIR/$name.sh"; exit 1; }
            echo "✅ SSH Reverse tunnel '$name' created."
            ;;
        3)
            check_and_install ssh openssh-client
            echo "🎯 SSH Local Tunnel Configuration"
            ask "Remote server (user@host)" ssh_target
            ask "Remote port to connect to" remote_port
            ask "Local port to expose" local_port

            echo "ssh -N -L $local_port:localhost:$remote_port $ssh_target" > "$TUNNEL_DIR/$name.sh"
            chmod +x "$TUNNEL_DIR/$name.sh" || { echo "❌ Failed to set permissions for $TUNNEL_DIR/$name.sh"; exit 1; }
            echo "✅ SSH Local tunnel '$name' created."
            ;;
        4)
            check_and_install ssh openssh-client
            echo "🎯 SSH Dynamic SOCKS5 Tunnel Configuration"
            ask "Remote server (user@host)" ssh_target
            ask "Local SOCKS5 port" socks_port

            echo "ssh -N -D $socks_port $ssh_target" > "$TUNNEL_DIR/$name.sh"
            chmod +x "$TUNNEL_DIR/$name.sh" || { echo "❌ Failed to set permissions for $TUNNEL_DIR/$name.sh"; exit 1; }
            echo "✅ SOCKS5 tunnel '$name' created."
            ;;
        5)
            check_and_install socat socat
            echo "🎯 Socat TCP Tunnel Configuration"
            ask "Local port to listen on" local_port
            ask "Target IP:Port" target

            echo "socat TCP-LISTEN:$local_port,fork TCP:$target" > "$TUNNEL_DIR/$name.sh"
            chmod +x "$TUNNEL_DIR/$name.sh" || { echo "❌ Failed to set permissions for $TUNNEL_DIR/$name.sh"; exit 1; }
            echo "✅ Socat tunnel '$name' created."
            ;;
        6)
            check_and_install wg wireguard-tools
            echo "🎯 WireGuard Tunnel Configuration"
            ask "WireGuard server address" server
            ask "Server port" port
            ask "Private key" private_key
            ask "Public key of server" server_public_key
            ask "Allowed IPs (e.g., 0.0.0.0/0)" allowed_ips
            ask "Tunnel interface name (e.g., wg0)" interface

            CONFIG_PATH="/etc/wireguard/$name.conf"
            cat > "$CONFIG_PATH" <<EOF
[Interface]
PrivateKey = $private_key
Address = 10.0.0.2/24
ListenPort = $port

[Peer]
PublicKey = $server_public_key
Endpoint = $server:$port
AllowedIPs = $allowed_ips
PersistentKeepalive = 25
EOF
            chmod 600 "$CONFIG_PATH" || { echo "❌ Failed to set permissions for $CONFIG_PATH"; exit 1; }
            echo "# WireGuard tunnel launcher" > "$TUNNEL_DIR/$name.sh"
            echo "wg-quick up $name" >> "$TUNNEL_DIR/$name.sh"
            chmod +x "$TUNNEL_DIR/$name.sh" || { echo "❌ Failed to set permissions for $TUNNEL_DIR/$name.sh"; exit 1; }
            echo "✅ WireGuard tunnel '$name' created."
            ;;
        7)
            check_and_install openvpn openvpn
            echo "🎯 OpenVPN Tunnel Configuration"
            ask "Path to OpenVPN config file (.ovpn)" ovpn_config
            if [ ! -f "$ovpn_config" ]; then
                echo "❌ OpenVPN config file not found at $ovpn_config."
                return
            fi

            cp "$ovpn_config" "$TUNNEL_DIR/$name.ovpn" || { echo "❌ Failed to copy OpenVPN config"; exit 1; }
            echo "# OpenVPN tunnel launcher" > "$TUNNEL_DIR/$name.sh"
            echo "openvpn --config $TUNNEL_DIR/$name.ovpn" >> "$TUNNEL_DIR/$name.sh"
            chmod +x "$TUNNEL_DIR/$name.sh" || { echo "❌ Failed to set permissions for $TUNNEL_DIR/$name.sh"; exit 1; }
            echo "✅ OpenVPN tunnel '$name' created."
            ;;
        8)
            check_and_install iproute2 iproute2
            echo "🎯 GRE Tunnel Configuration"
            ask "Local IP address" local_ip
            ask "Remote IP address" remote_ip
            ask "Tunnel interface name (e.g., gre1)" gre_interface
            ask "Tunnel key (optional, press Enter to skip)" gre_key

            echo "# GRE tunnel launcher" > "$TUNNEL_DIR/$name.sh"
            echo "ip tunnel add $gre_interface mode gre local $local_ip remote $remote_ip ${gre_key:+key $gre_key}" >> "$TUNNEL_DIR/$name.sh"
            echo "ip link set $gre_interface up" >> "$TUNNEL_DIR/$name.sh"
            chmod +x "$TUNNEL_DIR/$name.sh" || { echo "❌ Failed to set permissions for $TUNNEL_DIR/$name.sh"; exit 1; }
            echo "✅ GRE tunnel '$name' created."
            ;;
        9)
            check_and_install stunnel4 stunnel4
            echo "🎯 HTTP/HTTPS Tunnel Configuration (stunnel)"
            ask "Local port to listen on" local_port
            ask "Remote host" remote_host
            ask "Remote port" remote_port
            ask "Use SSL/TLS? (y/n)" use_ssl
            if [ "$use_ssl" = "y" ]; then
                protocol="https"
            else
                protocol="http"
            fi

            CONFIG_PATH="$STUNNEL_CONF_DIR/$name.conf"
            cat > "$CONFIG_PATH" <<EOF
[stunnel-$name]
client = yes
accept = 127.0.0.1:$local_port
connect = $remote_host:$remote_port
EOF
            chmod 600 "$CONFIG_PATH" || { echo "❌ Failed to set permissions for $CONFIG_PATH"; exit 1; }
            echo "# stunnel launcher" > "$TUNNEL_DIR/$name.sh"
            echo "stunnel $CONFIG_PATH" >> "$TUNNEL_DIR/$name.sh"
            chmod +x "$TUNNEL_DIR/$name.sh" || { echo "❌ Failed to set permissions for $TUNNEL_DIR/$name.sh"; exit 1; }
            echo "✅ $protocol tunnel '$name' created."
            ;;
        10)
            install_v2ray
            echo "🎯 V2Ray/Vmess Tunnel Configuration"
            ask "Server address" server
            ask "Server port" port
            ask "User ID (UUID)" user_id
            ask "Alter ID" alter_id
            ask "Local port to listen on" local_port

            CONFIG_PATH="$TUNNEL_DIR/$name.json"
            cat > "$CONFIG_PATH" <<EOF
{
  "inbounds": [
    {
      "port": $local_port,
      "protocol": "socks",
      "settings": {
        "auth": "noauth",
        "udp": true
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "vmess",
      "settings": {
        "vnext": [
          {
            "address": "$server",
            "port": $port,
            "users": [
              {
                "id": "$user_id",
                "alterId": $alter_id
              }
            ]
          }
        ]
      }
    }
  ]
}
EOF
            echo "# V2Ray tunnel launcher" > "$TUNNEL_DIR/$name.sh"
            echo "$V2RAY_BIN run -c $CONFIG_PATH" >> "$TUNNEL_DIR/$name.sh"
            chmod +x "$TUNNEL_DIR/$name.sh" || { echo "❌ Failed to set permissions for $TUNNEL_DIR/$name.sh"; exit 1; }
            echo "✅ V2Ray/Vmess tunnel '$name' created."
            ;;
        *)
            echo "❌ Invalid selection."
            return
            ;;
    esac

    create_service_file "$name"
    echo "ℹ️ To start the tunnel: sudo systemctl start tunnelzi-$name"
    echo "ℹ️ To enable on boot: sudo systemctl enable tunnelzi-$name"
}

list_tunnels() {
    echo "📄 Available tunnels:"
    local found=0
    for f in "$TUNNEL_DIR"/*.sh; do
        [ -e "$f" ] || continue
        found=1
        local name
        name=$(basename "$f" .sh)
        local status
        systemctl is-active --quiet "tunnelzi-$name" && status="active" || status="inactive"
        echo "➤ $name ($status)"
    done
    if [ $found -eq 0 ]; then
        echo "⚠️ No tunnels found."
    fi
}

delete_tunnel() {
    local name="$1"
    if [ -z "$name" ]; then
        echo "❌ Please specify a tunnel name."
        exit 1
    fi
    validate_tunnel_name "$name"

    systemctl stop "tunnelzi-$name" 2>/dev/null
    systemctl disable "tunnelzi-$name" 2>/dev/null
    rm -f "$SYSTEMD_DIR/tunnelzi-$name.service" "$TUNNEL_DIR/$name.sh" "$TUNNEL_DIR/$name.toml" "$TUNNEL_DIR/$name.ovpn" "/etc/wireguard/$name.conf" "$STUNNEL_CONF_DIR/$name.conf" "$TUNNEL_DIR/$name.json" || { echo "❌ Failed to delete tunnel files"; exit 1; }
    ip link delete "$name" 2>/dev/null # For GRE tunnels
    systemctl daemon-reload || { echo "❌ Failed to reload systemd daemon"; exit 1; }

    echo "🗑️ Tunnel '$name' deleted."
}

start_tunnel() {
    local name="$1"
    if [ -z "$name" ]; then
        echo "❌ Please specify a tunnel name."
        exit 1
    fi
    validate_tunnel_name "$name"

    systemctl start "tunnelzi-$name" || { echo "❌ Failed to start tunnel '$name'"; exit 1; }
    echo "▶️ Tunnel '$name' started."
}

stop_tunnel() {
    local name="$1"
    if [ -z "$name" ]; then
        echo "❌ Please specify a tunnel name."
        exit 1
    fi
    validate_tunnel_name "$name"

    systemctl stop "tunnelzi-$name" || { echo "❌ Failed to stop tunnel '$name'"; exit 1; }
    ip link delete "$name" 2>/dev/null # For GRE tunnels
    echo "⏹️ Tunnel '$name' stopped."
}

enable_tunnel() {
    local name="$1"
    if [ -z "$name" ]; then
        echo "❌ Please specify a tunnel name."
        exit 1
    fi
    validate_tunnel_name "$name"

    systemctl enable "tunnelzi-$name" || { echo "❌ Failed to enable tunnel '$name'"; exit 1; }
    echo "✅ Tunnel '$name' enabled to start on boot."
}

disable_tunnel() {
    local name="$1"
    if [ -z "$name" ]; then
        echo "❌ Please specify a tunnel name."
        exit 1
    fi
    validate_tunnel_name "$name"

    systemctl disable "tunnelzi-$name" || { echo "❌ Failed to disable tunnel '$name'"; exit 1; }
    echo "❌ Tunnel '$name' disabled from starting on boot."
}

case "$1" in
    create) create_tunnel ;;
    list) list_tunnels ;;
    delete) delete_tunnel "$2" ;;
    start) start_tunnel "$2" ;;
    stop) stop_tunnel "$2" ;;
    enable) enable_tunnel "$2" ;;
    disable) disable_tunnel "$2" ;;
    help | *) show_help ;;
esac
