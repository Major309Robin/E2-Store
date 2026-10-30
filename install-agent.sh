#!/bin/sh
# E2 Store Agent - installer
# Usage: sh install-e2store.sh

URL="https://major309robin.github.io/E2-Store/enigma2-plugin-extensions-e2store-agent_1.0_all.ipk"
PKG="enigma2-plugin-extensions-e2store-agent"
TMP="/tmp/e2store-agent.ipk"

echo "=============================="
echo "   E2 Store Agent - Installer"
echo "=============================="

# 1) Make sure Python is available
if ! which python3 >/dev/null 2>&1 && ! which python >/dev/null 2>&1 && ! which python2 >/dev/null 2>&1; then
    echo "[!] Python not found. Trying to install it..."
    opkg update >/dev/null 2>&1
    opkg install python3 >/dev/null 2>&1 || opkg install python >/dev/null 2>&1
    if ! which python3 >/dev/null 2>&1 && ! which python >/dev/null 2>&1; then
        echo "[X] Failed to install Python. Install it manually and try again."
        exit 1
    fi
fi

# 2) Download the package
echo "[1/3] Downloading package..."
rm -f "$TMP"
if which wget >/dev/null 2>&1; then
    wget --no-check-certificate -q -O "$TMP" "$URL"
fi
if [ ! -s "$TMP" ] && which curl >/dev/null 2>&1; then
    curl -k -sL -o "$TMP" "$URL"
fi
if [ ! -s "$TMP" ]; then
    echo "[X] Download failed. Check your internet connection and this URL:"
    echo "    $URL"
    exit 1
fi

# Make sure we got a real package, not an HTML error page
if head -c 15 "$TMP" | grep -qi "<!doctype\|<html"; then
    echo "[X] Downloaded file is not an ipk (wrong URL or file not published yet)."
    rm -f "$TMP"
    exit 1
fi

# 3) Install
echo "[2/3] Installing package..."
opkg remove "$PKG" >/dev/null 2>&1
if ! opkg install --force-reinstall "$TMP"; then
    echo "[X] Installation failed."
    rm -f "$TMP"
    exit 1
fi
rm -f "$TMP"

# 4) Start and verify
echo "[3/3] Starting service..."
/etc/init.d/e2store-agent restart
sleep 2

IP=$(ip -4 addr show 2>/dev/null | grep -o 'inet [0-9.]*' | grep -v '127.0.0.1' | head -n1 | cut -d' ' -f2)
[ -z "$IP" ] && IP=$(ifconfig 2>/dev/null | grep -o 'inet addr:[0-9.]*' | grep -v '127.0.0.1' | head -n1 | cut -d: -f2)

echo
echo "[OK] Installed successfully."
echo "Open in your browser:  http://${IP:-<receiver-ip>}:8080"
exit 0
