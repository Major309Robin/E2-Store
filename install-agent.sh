#!/bin/sh
# =====================================================================
# E2 Store Agent - Professional Installer
# Compatible with Enigma2 (OpenATV, OpenBH, etc.)
# =====================================================================

# Color definitions for terminal formatting
RED='\033[1;31m'
GREEN='\033[1;32m'
CYAN='\033[1;36m'
YELLOW='\033[1;33m'
NC='\033[0m' # Reset color

BASE="https://major309robin.github.io/E2-Store"
DIR="/usr/lib/e2store"
INIT_SCRIPT="/etc/init.d/e2store-agent"

clear
echo -e "${CYAN}=====================================================${NC}"
echo -e "${CYAN}       E2 Store Agent - Automated Installer         ${NC}"
echo -e "${CYAN}=====================================================${NC}"
echo ""

# 1. Check for Python environment
echo -e "${YELLOW}[*]${NC} Checking Python environment..."
PY=$(command -v python3 || command -v python)
if [ -z "$PY" ]; then
    echo -e "${RED}[✘] Error:${NC} Python was not found on your system. Please install it first."
    exit 1
fi
echo -e "${GREEN}[✔]${NC} Python found: $($PY --version 2>&1)"

# 2. Create directories and download files
echo -e "${YELLOW}[*]${NC} Setting up directories and downloading agent..."
mkdir -p "$DIR" /etc/e2store

dl() {
  wget --no-check-certificate -qO "$2" "$1" 2>/dev/null || curl -k -sL -o "$2" "$1" 2>/dev/null
  [ -s "$2" ]
}

if ! dl "$BASE/e2store-agent.py" "$DIR/agent.py"; then
    echo -e "${RED}[✘] Error:${NC} Failed to download agent.py."
    echo -e "    Please check your internet connection and GitHub repository link."
    exit 1
fi
echo -e "${GREEN}[✔]${NC} Main script downloaded successfully."

# 3. Create the SysVinit service script
echo -e "${YELLOW}[*]${NC} Configuring system daemon service..."
cat > "$INIT_SCRIPT" <<'INIT'
#!/bin/sh
### BEGIN INIT INFO
# Provides:          e2store-agent
# Required-Start:    $network $local_fs
# Required-Stop:     $network $local_fs
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: E2 Store Agent background service
### END INIT INFO

PY=$(command -v python3 || command -v python)
DAEMON="/usr/lib/e2store/agent.py"
LOG="/tmp/e2store-agent.log"

case "$1" in
  start)
    [ -n "$PY" ] || exit 1
    if ! pidof -x agent.py >/dev/null 2>&1 && ! ps | grep -v grep | grep -q "e2store/agent.py"; then
      nohup $PY "$DAEMON" > "$LOG" 2>&1 &
      echo "E2 Store Agent started."
    fi
    ;;
  stop)
    for p in $(ps | grep "e2store/agent.py" | grep -v grep | awk '{print $1}'); do
      kill "$p" 2>/dev/null
    done
    echo "E2 Store Agent stopped."
    ;;
  restart)
    $0 stop
    sleep 1
    $0 start
    ;;
  status)
    if pidof -x agent.py >/dev/null 2>&1 || ps | grep -v grep | grep -q "e2store/agent.py"; then
      echo "E2 Store Agent is running."
    else
      echo "E2 Store Agent is stopped."
    fi
    ;;
  *)
    echo "Usage: $0 {start|stop|restart|status}"
    exit 1
    ;;
esac
exit 0
INIT

chmod +x "$INIT_SCRIPT" "$DIR/agent.py"

# 4. Register the service for startup boot
if command -v update-rc.d >/dev/null 2>&1; then
  update-rc.d -f e2store-agent remove >/dev/null 2>&1
  update-rc.d e2store-agent defaults 99 >/dev/null 2>&1
else
  for l in 2 3 4 5; do
    mkdir -p "/etc/rc$l.d"
    ln -sf "$INIT_SCRIPT" "/etc/rc$l.d/S99e2store-agent"
  done
fi

# 5. Start the service and fetch receiver IP address
echo -e "${YELLOW}[*]${NC} Starting the service..."
"$INIT_SCRIPT" restart >/dev/null 2>&1
sleep 2

IP=$(ip route get 1 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i=="src") print $(i+1)}' | head -1)
[ -z "$IP" ] && IP=$(ifconfig 2>/dev/null | grep -o 'inet addr:[0-9.]*' | grep -v 127.0.0.1 | head -1 | cut -d: -f2)
[ -z "$IP" ] && IP="<Receiver-IP>"

echo ""
echo -e "${CYAN}=====================================================${NC}"
echo -e "${GREEN}      [✔] Service installed and started successfully! ${NC}"
echo -e "${CYAN}=====================================================${NC}"
echo -e " Open your browser from any device on the same network and visit:"
echo -e " ${YELLOW}http://${IP}:8080${NC}"
echo -e "${CYAN}=====================================================${NC}"
