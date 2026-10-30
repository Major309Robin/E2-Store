#!/bin/sh
# E2 Store Agent installer - شغّله مرة واحدة على الرسيفر
BASE="https://major309robin.github.io/E2-Store"
DIR=/usr/lib/e2store

echo "== تثبيت E2 Store Agent =="
mkdir -p $DIR /etc/e2store

dl() {
  wget --no-check-certificate -qO "$2" "$1" 2>/dev/null || curl -k -sL -o "$2" "$1" 2>/dev/null
  [ -s "$2" ]
}

dl "$BASE/e2store-agent.py" $DIR/agent.py || { echo "فشل تحميل agent.py (تأكد من النت ومن رفع الملف على GitHub)"; exit 1; }

cat > /etc/init.d/e2store-agent <<'INIT'
#!/bin/sh
PY=$(command -v python3 || command -v python)
case "$1" in
  start)
    [ -n "$PY" ] || { echo "python مش موجود"; exit 1; }
    if ! pidof -x agent.py >/dev/null 2>&1 && ! ps | grep -v grep | grep -q "e2store/agent.py"; then
      nohup $PY /usr/lib/e2store/agent.py >/tmp/e2store-agent.log 2>&1 &
    fi ;;
  stop)
    for p in $(ps | grep "e2store/agent.py" | grep -v grep | awk '{print $1}'); do kill $p; done ;;
  restart) $0 stop; sleep 1; $0 start ;;
esac
exit 0
INIT
chmod +x /etc/init.d/e2store-agent $DIR/agent.py

if command -v update-rc.d >/dev/null 2>&1; then
  update-rc.d -f e2store-agent remove >/dev/null 2>&1
  update-rc.d e2store-agent defaults 99 >/dev/null 2>&1
else
  for l in 2 3 4 5; do mkdir -p /etc/rc$l.d; ln -sf /etc/init.d/e2store-agent /etc/rc$l.d/S99e2store-agent; done
fi

/etc/init.d/e2store-agent restart
sleep 2
IP=$(ip route get 1 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i=="src") print $(i+1)}' | head -1)
[ -z "$IP" ] && IP=$(ifconfig 2>/dev/null | grep -o 'inet addr:[0-9.]*' | grep -v 127.0.0.1 | head -1 | cut -d: -f2)
echo ""
echo "تم. افتح من أي جهاز على الشبكة:  http://${IP:-<IP-الرسيفر>}:8080"
