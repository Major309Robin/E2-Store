<div align="center">

<img src="logo.png" alt="E2 Store" width="180" />

# E2 Store

**A comprehensive library of Enigma2 commands and plugins in one place**
*Enigma2 Full Command & Plugin Database*

[![Version](https://img.shields.io/badge/version-2.0.1-06b6d4?style=for-the-badge)](#)
[![Platform](https://img.shields.io/badge/platform-Enigma2-8b5cf6?style=for-the-badge)](#)
[![Commands](https://img.shields.io/badge/commands-324-f59e0b?style=for-the-badge)](#)
[![License](https://img.shields.io/badge/license-MIT-10b981?style=for-the-badge)](#)

[Browse the Store](https://major309robin.github.io/E2-Store/) · [Report an Issue](../../issues) · [Request a Feature](../../issues)

</div>

---

## ✨ Features

- 📚 **324 commands** organized into 12 categories, all loaded from a single `store.json` file.
- 🔍 **Instant search** by name, developer, description, or the command itself.
- 🗂️ **Clear categories**: Fast Order, Panels, Tools, SoftCams, Audio, Subtitles, EPG, IPTV, Skins, Picons, Boot Logos, Backup, and Other.
- 📡 **Direct connection** to your receiver via IP address—no extra code required.
- 🔗 **Integration with `ntfy`** for remote control from outside your local network.
- 🖥️ **Live terminal**: Command output is displayed line-by-line, just like a real terminal. - 🚨 **Dedicated error section** that displays the specific reason if an installation fails.
- 🔄 **Automatic receiver restart** following a successful installation, accompanied by a countdown.
- 🌓 **Dark and light modes**, with a responsive design for both mobile and desktop.
- 🌍 **Multi-language support**: Arabic, English, and French.

---

## 📦 Installation on the Receiver

Run the following command in your terminal (via Telnet or SSH) while logged in as `root`:

```bash
cd /tmp && wget --no-check-certificate -O Panel_2.0.1_all.ipk https://major309robin.github.io/E2-Store/Panel_2.0.1_all.ipk && opkg install --force-reinstall Panel_2.0.1_all.ipk
```
2. Click on ⚙️ ** **, enter your receiver's IP address, and save.
3. Select the desired command and click **Install**.
4. The output will appear in the terminal; if successful, the receiver will automatically restart.

> 💡 If you open the page from a local file (`file://`) or via `https`, your browser may block the connection to the receiver. Solution: Access it via `http://IP:8765`.

---
**Available Categories (`category`):**

 Display Name |
|---|---|
| Fast Order 
| Panels 
| Tools
| SoftCam
| Audio
| Subtitle
| EPG
| IPTV
| Skins 
| Others

---

## 🛠️ Panel on the Receiver

The panel runs on the receiver as a service (`e2ipkpanel`) on port **8765**:

| File | Function |
|---|---|
| `/usr/bin/e2ipkpanel` | Server that receives and executes commands |
| `/usr/share/e2ipkpanel/index.html` | Store interface |
| `/etc/init.d/e2ipkpanel` | Service control (start/stop) |
| `/etc/e2ipkpanel.conf` | Configuration (port, catalog URL, linking code) |

Management commands:

```bash
/etc/init.d/e2ipkpanel start      # Start
/etc/init.d/e2ipkpanel stop       # Stop
/etc/init.d/e2ipkpanel restart    # Restart
opkg remove e2-panel              # Remove the panel
```

---

## 📜 License

The code is licensed under the **MIT** license. The commands and add-ons listed belong to their respective original owners; this repository provides them for personal use only.

---

<div align="center">

**Created with love for the Enigma2 community ❤️**

</div>
