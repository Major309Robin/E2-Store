#!/bin/sh
# =============================================================================
#  E2 Store - Link installer
#  Installs the E2 Store Link panel (Panel_<version>_all.ipk) on an Enigma2
#  receiver, starts the service and prints the link code.
#
#  Usage (run on the receiver, as root):
#    wget --no-check-certificate -qO- https://major309robin.github.io/E2-Store/install-link.sh | sh
# =============================================================================

VERSION="2.0.0"
BASE_URL="https://major309robin.github.io/E2-Store"
IPK_NAME="Panel_${VERSION}_all.ipk"
IPK_URL="${BASE_URL}/${IPK_NAME}"
IPK_TMP="/tmp/${IPK_NAME}"
SERVICE="/etc/init.d/e2ipkpanel"
CONF="/etc/e2ipkpanel.conf"
PORT="8765"
MIN_SIZE=10000

# ---------- output helpers ----------
if [ -t 1 ]; then
  C_OK="\033[1;32m"; C_ERR="\033[1;31m"; C_WARN="\033[1;33m"
  C_INFO="\033[1;36m"; C_DIM="\033[2m"; C_OFF="\033[0m"
else
  C_OK=""; C_ERR=""; C_WARN=""; C_INFO=""; C_DIM=""; C_OFF=""
fi

line()  { printf "${C_DIM}%s${C_OFF}\n" "------------------------------------------------------------"; }
step()  { printf "${C_INFO}[*]${C_OFF} %s\n" "$1"; }
ok()    { printf "${C_OK}[+]${C_OFF} %s\n" "$1"; }
warn()  { printf "${C_WARN}[!]${C_OFF} %s\n" "$1"; }
die()   { printf "${C_ERR}[x] %s${C_OFF}\n" "$1"; exit 1; }

have()  { command -v "$1" >/dev/null 2>&1; }

# ---------- 1. checks ----------
clear 2>/dev/null
line
printf "${C_INFO}  E2 Store - Link installer  v%s${C_OFF}\n" "$VERSION"
line

step "Checking receiver..."
[ "$(id -u 2>/dev/null)" = "0" ] || die "Run this script as root."
[ -d /etc/enigma2 ] || [ -d /usr/lib/enigma2 ] || warn "Enigma2 folders not found - continuing anyway."
ok "Root access OK"

if ! have wget; then
  step "wget not found, installing..."
  opkg update >/dev/null 2>&1
  opkg install wget >/dev/null 2>&1 || die "Could not install wget. Check the internet connection."
fi
ok "wget ready"

# ---------- 2. download ----------
step "Downloading ${IPK_NAME}..."
rm -f "$IPK_TMP"
wget --no-check-certificate -q -T 30 -t 3 -O "$IPK_TMP" "$IPK_URL" \
  || die "Download failed. Check the internet connection or try again later."
SIZE=$(wc -c < "$IPK_TMP" 2>/dev/null || echo 0)
[ "$SIZE" -ge "$MIN_SIZE" ] || die "Downloaded file looks broken (${SIZE} bytes)."
ok "Downloaded (${SIZE} bytes)"

# ---------- 3. stop old service ----------
if [ -x "$SERVICE" ]; then
  step "Stopping previous version..."
  "$SERVICE" stop >/dev/null 2>&1
  ok "Previous service stopped"
fi

# ---------- 4. install package ----------
step "Installing package..."
if have opkg; then
  opkg install --force-reinstall "$IPK_TMP" >/tmp/e2store-install.log 2>&1
  RC=$?
elif have ipkg; then
  ipkg install --force-reinstall "$IPK_TMP" >/tmp/e2store-install.log 2>&1
  RC=$?
else
  die "No package manager found (opkg/ipkg)."
fi
[ "$RC" = "0" ] || { cat /tmp/e2store-install.log; die "Package installation failed (code $RC)."; }
ok "Package installed"

# ---------- 5. verify files ----------
step "Verifying installation..."
[ -x /usr/bin/e2ipkpanel ] || die "Server file is missing: /usr/bin/e2ipkpanel"
[ -f "$CONF" ] || die "Config file is missing: $CONF"
[ -x "$SERVICE" ] || die "Service script is missing: $SERVICE"
ok "Files in place"

# ---------- 6. start service ----------
step "Starting E2 Store Link service..."
"$SERVICE" restart >/dev/null 2>&1
sleep 3

PING=$(wget -qO- -T 5 "http://127.0.0.1:${PORT}/ping" 2>/dev/null)
case "$PING" in
  *'"agent": true'*|*'"agent":true'*) ok "Service is responding on port ${PORT}" ;;
  *) warn "Service did not answer yet. Check it with: ${SERVICE} restart" ;;
esac

# ---------- 7. read link code ----------
LC=$(grep '^linkcode=' "$CONF" 2>/dev/null | cut -d= -f2 | tr -d ' \r')
if [ -n "$LC" ] && [ "${#LC}" -eq 20 ]; then
  LINK_CODE="$(echo "$LC" | cut -c1-5)-$(echo "$LC" | cut -c6-10)-$(echo "$LC" | cut -c11-15)-$(echo "$LC" | cut -c16-20)"
else
  LINK_CODE="(not generated - run: ${SERVICE} restart)"
fi

# ---------- 8. detect IP ----------
IP=""
if have ip; then
  IP=$(ip -4 addr 2>/dev/null | awk '/inet / && $2 !~ /^127\./ {sub(/\/.*/, "", $2); print $2; exit}')
fi
[ -n "$IP" ] || IP=$(ifconfig 2>/dev/null | awk '/inet addr:/ && !/127\.0\.0\.1/ {sub(/addr:/, "", $2); print $2; exit}')
[ -n "$IP" ] || IP="<receiver-ip>"

# ---------- 9. summary ----------
rm -f "$IPK_TMP"
echo
line
printf "${C_OK}  Installation completed successfully${C_OFF}\n"
line
printf "  Web panel    : ${C_INFO}http://%s:%s${C_OFF}\n" "$IP" "$PORT"
printf "  Link code    : ${C_INFO}%s${C_OFF}\n" "$LINK_CODE"
printf "  Config file  : %s\n" "$CONF"
printf "  Restart      : %s restart\n" "$SERVICE"
printf "  Uninstall    : opkg remove e2-panel\n"
line
printf "${C_DIM}  Open the web panel on any device in the same network,${C_OFF}\n"
printf "${C_DIM}  or enter the link code in the E2 Store page.${C_OFF}\n"
line
exit 0
