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

Verify the installation:

```bash
opkg info e2-panel | grep Version
wget -qO- http://127.0.0.1:8765/ping
```

You should see `Version: 2.0.1` and `"agent": true`.

---

## 🌐 Usage

1. Access the interface using your receiver's IP address:
```
http://<receiver-IP>:8765
```
2. Click on ⚙️ **Settings**, enter your receiver's IP address, and save.
3. Select the desired command and click **Install**.
4. The output will appear in the terminal; if successful, the receiver will automatically restart.

> 💡 If you open the page from a local file (`file://`) or via `https`, your browser may block the connection to the receiver. Solution: Access it via `http://IP:8765`.

---

## ➕ Adding a New Command

All commands are stored in the **`store.json`** file. Add a new entry to the end of the list as follows:

```json
{
"title": "Command Name",
"author": "Developer Name",
"category": "tools",
"desc": "A short description of the command",
"cmd": "opkg update && opkg install package-name"
}
```

**Available Categories (`category`):**

| Value | Display Name |
|---|---|
| `fast` | Fast Order |
| `panels` | Panels |
| `tools` | Tools Plugins |
| `backup` | Backup & Restore |
| `softcams` | SoftCams Plugins |
| `audio` | Audio Plugins |
| `subtitles` | Subtitle Plugins |
| `epg` | EPG Plugins |
| `iptv` | IPTV Plugins |
| `skins` | Skins |
| `picons` | Picons |
| `bootlogos` | Boot Logos & Spinners |
| `others` | Other Plugins |

Once you commit the file, open the page; the new command will appear automatically, and the counter will update. ---

## 🗂️ Project Structure

```
E2-Store/
├── index.html              # Store interface
├── store.json              # All commands (single source of truth)
├── logo.png                # Logo
├── install-link.sh         # Panel installation script
├── Panel_2.0.1_all.ipk     # Panel package for the receiver
└── README.md
```

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

## 🩺 Troubleshooting

| Issue | Solution |
|---|---|
| Page fails to connect to the receiver | Ensure the page is accessed via `http://IP:8765` and that the receiver responds to `ping` |
| Commands do not appear | Ensure that `store.json` has been uploaded to GitHub and contains no JSON syntax errors. |
| Installation failed | Check the **[ERROR]** section in the terminal; it contains the exit code and the reason for the failure. |
| The receiver does not restart | The installation must complete without any errors. |
| The card contains an outdated version | Perform a full refresh (`Ctrl+F5`) or download the latest file. |

---

## 🤝 Contributing

1. Fork the project.
2. Add the command to `store.json` following the required format.
3. Submit a Pull Request, including a description of the command and its source.

> ⚠️ **Warning:** Commands are executed directly on the receiver. Read the command description before installation, and back up your settings if the command modifies system files.

---

## 📜 License

The code is licensed under the **MIT** license. The commands and add-ons listed belong to their respective original owners; this repository provides them for personal use only.

---

<div align="center">

**Created with love for the Enigma2 community ❤️**

</div>
