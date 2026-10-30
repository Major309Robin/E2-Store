#!/usr/bin/env python3
"""
E2 Store Bridge - جسر بين صفحة E2 Store والرسيفر (SSH).
التشغيل:
    pip install paramiko
    python bridge.py
ثم افتح E2_Store_Pro.html. الجسر يسمع على 127.0.0.1:8765 فقط (جهازك أنت).
"""
import json
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
import paramiko

HOST, PORT = "127.0.0.1", 8765

def connect(d):
    c = paramiko.SSHClient()
    c.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    c.connect(d["host"], port=int(d.get("port") or 22), username=d.get("user") or "root",
              password=d.get("password") or "", timeout=10, allow_agent=False, look_for_keys=False)
    return c

class H(BaseHTTPRequestHandler):
    def _cors(self):
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Headers", "Content-Type")
        self.send_header("Access-Control-Allow-Methods", "POST, OPTIONS")
        self.send_header("Access-Control-Allow-Private-Network", "true")

    def do_OPTIONS(self):
        self.send_response(204); self._cors(); self.end_headers()

    def _body(self):
        return json.loads(self.rfile.read(int(self.headers.get("Content-Length", 0))) or b"{}")

    def do_POST(self):
        d = self._body()
        if self.path == "/test":
            try:
                c = connect(d)
                _, o, _ = c.exec_command("uname -n; cat /etc/image-version 2>/dev/null | head -3")
                info = o.read().decode(errors="ignore").strip().replace("\n", " | ")
                c.close()
                out = {"ok": True, "info": info}
            except Exception as e:
                out = {"ok": False, "error": str(e)}
            raw = json.dumps(out, ensure_ascii=False).encode()
            self.send_response(200); self._cors()
            self.send_header("Content-Type", "application/json; charset=utf-8")
            self.send_header("Content-Length", str(len(raw))); self.end_headers(); self.wfile.write(raw)

        elif self.path == "/install":
            self.send_response(200); self._cors()
            self.send_header("Content-Type", "text/plain; charset=utf-8")
            self.send_header("Cache-Control", "no-cache"); self.end_headers()
            try:
                c = connect(d)
                ch = c.get_transport().open_session()
                ch.set_combine_stderr(True)
                ch.exec_command(d["command"])
                while True:
                    if ch.recv_ready():
                        self.wfile.write(ch.recv(4096)); self.wfile.flush()
                    elif ch.exit_status_ready():
                        while ch.recv_ready():
                            self.wfile.write(ch.recv(4096))
                        break
                    else:
                        import time; time.sleep(0.1)
                code = ch.recv_exit_status()
                self.wfile.write(f"\n__EXIT__{code}".encode()); c.close()
            except Exception as e:
                self.wfile.write(f"خطأ: {e}\n__EXIT__-1".encode())
        else:
            self.send_response(404); self.end_headers()

    def log_message(self, *a): pass

if __name__ == "__main__":
    print(f"E2 Store bridge شغّال على http://{HOST}:{PORT}  (Ctrl+C للإيقاف)")
    ThreadingHTTPServer((HOST, PORT), H).serve_forever()
