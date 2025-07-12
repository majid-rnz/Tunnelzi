#!/bin/bash

CONFIG_DIR="/etc/tunnelzi"
BACKHAUL_BIN="/usr/local/bin/backhaul"
TUNNEL_DIR="$CONFIG_DIR/tunnels"
SYSTEMD_DIR="/etc/systemd/system"

mkdir -p "$TUNNEL_DIR"

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
        if [ "$EUID" -ne 0 ]; then
            echo "❌ Please run this script as root to install dependencies."
            exit 1
        fi
        apt update && apt install -y "$pkg"
        if [ $? -ne 0 ]; then
            echo "❌ Failed to install $pkg. Please install it manually."
            exit 1
        fi
        echo "✅ $pkg installed successfully."
    fi
}

create_service_file() {
    local name="$1"
    local service_path="$SYSTEMD_DIR/tunnelzi-$name.service"

    cat > "$service_path" <<EOF
[Unit]
Description=Tunnelzi Tunnel $name
After=network.target

[Service]
ExecStart=$TUNNEL_DIR/$name.sh
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
    echo "✅ systemd service created at $service_path"
}

create_tunnel() {
    # Check common dependencies
    check_and_install ssh openssh-client
    check_and_install socat socat

    echo "📡 Choose tunnel type:"
    echo "1) Backhaul Tunnel"
    echo "2) SSH Reverse Tunnel"
    echo "3) SSH Local Tunnel"
    echo "4) SSH Dynamic SOCKS5 Tunnel"
    echo "5) Socat TCP Tunnel"
    read -rp "Enter the number: " tunnel_type

    ask "Unique tunnel name" name

    if [ -z "$name" ]; then
        echo "❌ Tunnel name cannot be empty."
        return
    fi

    case $tunnel_type in
        1)
            # Backhaul binary check
            if [ ! -x "$BACKHAUL_BIN" ]; then
                echo "⚠️ Backhaul binary not found at $BACKHAUL_BIN."
                echo "Please install Backhaul manually before creating this tunnel."
                return
            fi
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
            chmod +x "$TUNNEL_DIR/$name.sh"
            echo "✅ Backhaul tunnel '$name' created."
            ;;
        2)
            echo "🎯 SSH Reverse Tunnel Configuration"
            ask "Remote server (user@host)" ssh_target
            ask "Remote port to open" remote_port
            ask "Local port to forward" local_port

            echo "ssh -N -R $remote_port:localhost:$local_port $ssh_target" > "$TUNNEL_DIR/$name.sh"
            chmod +x "$TUNNEL_DIR/$name.sh"
            echo "✅ SSH Reverse tunnel '$name' created."
            ;;
        3)
            echo "🎯 SSH Local Tunnel Configuration"
            ask "Remote server (user@host)" ssh_target
            ask "Remote port to connect to" remote_port
            ask "Local port to expose" local_port

            echo "ssh -N -L $local_port:localhost:$remote_port $ssh_target" > "$TUNNEL_DIR/$name.sh"
            chmod +x "$TUNNEL_DIR/$name.sh"
            echo "✅ SSH Local tunnel '$name' created."
            ;;
        4)
            echo "🎯 SSH Dynamic SOCKS5 Tunnel Configuration"
            ask "Remote server (user@host)" ssh_target
            ask "Local SOCKS5 port" socks_port

            echo "ssh -N -D $socks_port $ssh_target" > "$TUNNEL_DIR/$name.sh"
            chmod +x "$TUNNEL_DIR/$name.sh"
            echo "✅ SOCKS5 tunnel '$name' created."
            ;;
        5)
            echo "🎯 Socat TCP Tunnel Configuration"
            ask "Local port to listen on" local_port
            ask "Target IP:Port" target

            echo "socat TCP-LISTEN:$local_port,fork TCP:$target" > "$TUNNEL_DIR/$name.sh"
            chmod +x "$TUNNEL_DIR/$name.sh"
            echo "✅ Socat tunnel '$name' created."
            ;;
        *)
            echo "❌ Invalid selection."
            return
            ;;
    esac

    create_service_file "$name"
    echo "ℹ️ To start tunnel now: sudo systemctl start tunnelzi-$name"
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

    sudo systemctl stop "tunnelzi-$name" 2>/dev/null
    sudo systemctl disable "tunnelzi-$name" 2>/dev/null
    sudo rm -f "$SYSTEMD_DIR/tunnelzi-$name.service"
    sudo rm -f "$TUNNEL_DIR/$name.sh" "$TUNNEL_DIR/$name.toml"

    sudo systemctl daemon-reload

    echo "🗑️ Tunnel '$name' deleted."
}

start_tunnel() {
    local name="$1"
    if [ -z "$name" ]; then
        echo "❌ Please specify a tunnel name."
        exit 1
    fi

    sudo systemctl start "tunnelzi-$name"
    echo "▶️ Tunnel '$name' started."
}

stop_tunnel() {
    local name="$1"
    if [ -z "$name" ]; then
        echo "❌ Please specify a tunnel name."
        exit 1
    fi

    sudo systemctl stop "tunnelzi-$name"
    echo "⏹️ Tunnel '$name' stopped."
}

enable_tunnel() {
    local name="$1"
    if [ -z "$name" ]; then
        echo "❌ Please specify a tunnel name."
        exit 1
    fi

    sudo systemctl enable "tunnelzi-$name"
    echo "✅ Tunnel '$name' enabled to start on boot."
}

disable_tunnel() {
    local name="$1"
    if [ -z "$name" ]; then
        echo "❌ Please specify a tunnel name."
        exit 1
    fi

    sudo systemctl disable "tunnelzi-$name"
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
