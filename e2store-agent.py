#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
E2 Store Agent - بيشتغل على الرسيفر نفسه.
- بيقدّم صفحة E2 Store على  http://<ip-الرسيفر>:8080
- بيحمّل store.json من GitHub وبينفّذ أمر أي عنصر منه على الرسيفر (بالرقم/الاسم فقط، مش أمر جاهز من المتصفح)
- بيرجّع مخرجات التثبيت للصفحة لحظة بلحظة
متوافق مع Python 2.7 و 3.
"""
import os, sys, json, time, re, select, subprocess, threading, socket

try:
    from http.server import BaseHTTPRequestHandler, HTTPServer
    from socketserver import ThreadingMixIn
except ImportError:  # python2
    from BaseHTTPServer import BaseHTTPRequestHandler, HTTPServer
    from SocketServer import ThreadingMixIn
try:
    from urllib.request import urlopen
except ImportError:
    from urllib2 import urlopen

VERSION = "1.0"
PORT = int(os.environ.get("E2S_PORT", "8080"))
BASE = os.environ.get("E2S_BASE", "https://major309robin.github.io/E2-Store").rstrip("/")
DIR = os.environ.get("E2S_DIR", "/etc/e2store")
CACHE_SECONDS = 600
INSTALL_TIMEOUT = 1500
LOCK = threading.Lock()

try:
    os.makedirs(DIR)
except OSError:
    pass


def b(s):
    return s if isinstance(s, bytes) else s.encode("utf-8")


def fetch(url):
    """تحميل ملف: urllib أولاً (من غير فحص الشهادة لأن الرسيفرات غالباً مفيهاش CA) وبعدين wget/curl."""
    try:
        try:
            import ssl
            ctx = ssl._create_unverified_context()
            return urlopen(url, timeout=25, context=ctx).read()
        except (ImportError, AttributeError, TypeError):
            return urlopen(url, timeout=25).read()
    except Exception:
        pass
    for cmd in (["wget", "--no-check-certificate", "-qO-", url], ["curl", "-k", "-sL", url]):
        try:
            out = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE).communicate()[0]
            if out:
                return out
        except Exception:
            continue
    return None


def get_file(name, force=False):
    path = os.path.join(DIR, name)
    fresh = os.path.exists(path) and (time.time() - os.path.getmtime(path) < CACHE_SECONDS)
    if fresh and not force:
        return open(path, "rb").read()
    data = fetch(BASE + "/" + name)
    if data:
        try:
            tmp = path + ".tmp"
            open(tmp, "wb").write(data)
            os.rename(tmp, path)
        except Exception:
            pass
        return data
    if os.path.exists(path):  # لو مفيش نت استخدم النسخة المحفوظة
        return open(path, "rb").read()
    return None


def get_catalog():
    raw = get_file("store.json")
    if not raw:
        return []
    data = json.loads(raw.decode("utf-8"))
    return data if isinstance(data, list) else (data.get("plugins") or data.get("items") or [])


def find_item(items, iid, title):
    def cmd_of(x):
        return x.get("cmd") or x.get("command") or x.get("install") or ""
    def t_of(x):
        return x.get("title") or x.get("name") or ""
    try:
        i = int(iid) - 1
        if 0 <= i < len(items) and (not title or t_of(items[i]) == title):
            return items[i], cmd_of(items[i])
    except (TypeError, ValueError):
        pass
    for x in items:
        if title and t_of(x) == title:
            return x, cmd_of(x)
    return None, None


PRIVATE = re.compile(r"^(127\.|10\.|192\.168\.|172\.(1[6-9]|2\d|3[01])\.|169\.254\.|::1$|fe80:|f[cd][0-9a-f]{2}:)", re.I)


def is_private(ip):
    ip = ip.replace("::ffff:", "")
    return bool(PRIVATE.match(ip))


def image_info():
    for p in ("/etc/image-version", "/etc/issue"):
        try:
            return open(p).read().strip().replace("\n", " | ")[:160]
        except Exception:
            continue
    return ""


class Server(ThreadingMixIn, HTTPServer):
    daemon_threads = True
    allow_reuse_address = True


class H(BaseHTTPRequestHandler):
    server_version = "E2StoreAgent/" + VERSION

    def log_message(self, *a):
        pass

    def cors(self):
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Headers", "Content-Type")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
        self.send_header("Access-Control-Allow-Private-Network", "true")

    def reply(self, code, body, ctype="application/json; charset=utf-8"):
        body = b(body)
        self.send_response(code)
        self.cors()
        self.send_header("Content-Type", ctype)
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Cache-Control", "no-store")
        self.end_headers()
        self.wfile.write(body)

    def allowed(self):
        if is_private(self.client_address[0]):
            return True
        self.reply(403, json.dumps({"ok": False, "error": "forbidden: LAN only"}))
        return False

    def do_OPTIONS(self):
        self.send_response(204)
        self.cors()
        self.end_headers()

    def do_GET(self):
        if not self.allowed():
            return
        path = self.path.split("?")[0]
        if path in ("/", "/index.html"):
            data = get_file("index.html")
            if data:
                return self.reply(200, data, "text/html; charset=utf-8")
            return self.reply(503, "مش قادر أحمّل الصفحة من GitHub ومفيش نسخة محفوظة.", "text/plain; charset=utf-8")
        if path == "/store.json":
            data = get_file("store.json")
            return self.reply(200, data, "application/json; charset=utf-8") if data else self.reply(503, "[]")
        if path == "/ping":
            return self.reply(200, json.dumps({"agent": True, "version": VERSION, "host": socket.gethostname(),
                                                "image": image_info(), "python": sys.version.split()[0]}))
        if path == "/refresh":
            get_file("store.json", True)
            get_file("index.html", True)
            return self.reply(200, json.dumps({"ok": True}))
        self.reply(404, json.dumps({"ok": False}))

    def do_POST(self):
        if not self.allowed():
            return
        if self.path.split("?")[0] != "/install":
            return self.reply(404, json.dumps({"ok": False}))
        try:
            n = int(self.headers.get("Content-Length", 0))
            req = json.loads(self.rfile.read(n).decode("utf-8") or "{}")
        except Exception:
            return self.reply(400, json.dumps({"ok": False, "error": "bad request"}))

        item, cmd = find_item(get_catalog(), req.get("id"), req.get("title"))
        if not item or not cmd:
            return self.reply(404, json.dumps({"ok": False, "error": "العنصر مش موجود في الكتالوج"}))

        if not LOCK.acquire(False):
            return self.reply(200, "فيه عملية تثبيت شغّالة دلوقتي، استنى تخلص.\n__EXIT__-2", "text/plain; charset=utf-8")
        try:
            self.send_response(200)
            self.cors()
            self.send_header("Content-Type", "text/plain; charset=utf-8")
            self.send_header("Cache-Control", "no-store")
            self.send_header("Connection", "close")
            self.end_headers()
            self.run(cmd)
        finally:
            LOCK.release()

    def emit(self, data):
        if self.alive:
            try:
                self.wfile.write(b(data))
                self.wfile.flush()
            except Exception:
                self.alive = False  # المتصفح قفل، كمّل التثبيت بدون إرسال

    def run(self, cmd):
        self.alive = True
        env = dict(os.environ)
        env["PATH"] = "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
        self.emit("$ " + cmd + "\n\n")
        try:
            p = subprocess.Popen(["/bin/sh", "-c", cmd], stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                                 stdin=open(os.devnull), env=env, close_fds=True)
        except Exception as e:
            self.emit("تعذّر تشغيل الأمر: %s\n__EXIT__-1" % e)
            return
        fd = p.stdout.fileno()
        start = time.time()
        while True:
            r, _, _ = select.select([fd], [], [], 0.5)
            if r:
                chunk = os.read(fd, 4096)
                if chunk:
                    self.emit(chunk)
                    continue
                if p.poll() is not None:
                    break
                # EOF لكن العملية لسه شغّالة
                time.sleep(0.2)
            if p.poll() is not None:
                # العملية خلصت: فضّي اللي فاضل (ومتستناش لو فيه عملية خلفية فاتحة الـ pipe)
                while True:
                    r, _, _ = select.select([fd], [], [], 0.3)
                    if not r:
                        break
                    chunk = os.read(fd, 4096)
                    if not chunk:
                        break
                    self.emit(chunk)
                break
            if time.time() - start > INSTALL_TIMEOUT:
                p.kill()
                self.emit("\n[انتهت المهلة وتم إيقاف الأمر]\n")
                break
        code = p.poll()
        self.emit("\n__EXIT__%s" % (code if code is not None else -1))


if __name__ == "__main__":
    srv = Server(("0.0.0.0", PORT), H)
    sys.stdout.write("E2 Store Agent %s on port %d\n" % (VERSION, PORT))
    sys.stdout.flush()
    try:
        srv.serve_forever()
    except KeyboardInterrupt:
        pass
