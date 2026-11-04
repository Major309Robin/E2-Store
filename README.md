<div align="center">

<img src="logo.png" alt="E2 Store" width="180" />

# E2 Store

**مكتبة أوامر وإضافات Enigma2 في مكان واحد**
*Enigma2 Full Command & Plugin Database*

[![Version](https://img.shields.io/badge/version-2.0.1-06b6d4?style=for-the-badge)](#)
[![Platform](https://img.shields.io/badge/platform-Enigma2-8b5cf6?style=for-the-badge)](#)
[![Commands](https://img.shields.io/badge/commands-324-f59e0b?style=for-the-badge)](#)
[![License](https://img.shields.io/badge/license-MIT-10b981?style=for-the-badge)](#)

[تصفح المتجر](https://major309robin.github.io/E2-Store/) · [الإبلاغ عن مشكلة](../../issues) · [طلب ميزة](../../issues)

</div>

---

## ✨ المميزات

- 📚 **324 أمر** موزعين على 12 تصنيف، بتتحمّل من ملف `store.json` واحد.
- 🔍 **بحث فوري** بالاسم أو المطوّر أو الوصف أو الأمر نفسه.
- 🗂️ **تصنيفات واضحة**: Fast Order، Panels، Tools، SoftCams، Audio، Subtitles، EPG، IPTV، Skins، Picons، Boot Logos، Backup، Other.
- 📡 **ربط مباشر بالرسيفر** بالـ IP، من غير أي كود.
- 🔗 **ربط بكود ntfy** للتحكم من خارج الشبكة المحلية.
- 🖥️ **ترمينال حي**: الخرج بيظهر سطر بسطر زي الترمينال الحقيقي.
- 🚨 **خانة أخطاء** منفصلة لو التثبيت فشل، وبتقولك السبب.
- 🔄 **إعادة تشغيل تلقائية** للرسيفر بعد التثبيت الناجح، مع عد تنازلي.
- 🌓 **وضع داكن وفاتح**، وتصميم متجاوب للموبايل والكمبيوتر.
- 🌍 **تعدد اللغات**: عربي، إنجليزي، فرنسي.

---

## 📦 التثبيت على الرسيفر

شغّل الأمر ده على التيرمنال (Telnet أو SSH) وأنت root:

```bash
cd /tmp && wget --no-check-certificate -O Panel_2.0.1_all.ipk https://major309robin.github.io/E2-Store/Panel_2.0.1_all.ipk && opkg install --force-reinstall Panel_2.0.1_all.ipk
```

التحقق من التثبيت:

```bash
opkg info e2-panel | grep Version
wget -qO- http://127.0.0.1:8765/ping
```

لازم يظهر `Version: 2.0.1` ويظهر `"agent": true`.

---

## 🌐 الاستخدام

1. افتح الصفحة من عنوان الرسيفر:
   ```
   http://IP-الرسيفر:8765
   ```
2. اضغط على ⚙️ **الإعدادات** وادخل IP الرسيفر واحفظ.
3. اختار الأمر اللي عايزه واضغط **Install**.
4. الخرج هيظهر في الترمينال، ولو نجح الرسيفر هيعمل restart لوحده.

> 💡 لو فتحت الصفحة من ملف محلي (`file://`) أو من `https`، المتصفح ممكن يمنع الاتصال بالرسيفر. الحل: افتحها من `http://IP:8765`.

---

## ➕ إضافة أمر جديد

كل الأوامر في ملف **`store.json`**. ضيف عنصر جديد في آخر القايمة بالشكل ده:

```json
{
  "title": "اسم الأمر",
  "author": "اسم المطوّر",
  "category": "tools",
  "desc": "وصف قصير للأمر",
  "cmd": "opkg update && opkg install package-name"
}
```

**التصنيفات المتاحة (`category`):**

| القيمة | الاسم في الصفحة |
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

بعد ما تعمل Commit للملف، افتح الصفحة وهيظهر الأمر الجديد تلقائي، والعداد بيزيد.

---

## 🗂️ هيكل المشروع

```
E2-Store/
├── index.html              # صفحة المتجر
├── store.json              # كل الأوامر (المصدر الوحيد)
├── logo.png                # اللوجو
├── install-link.sh         # سكريبت تثبيت البانل
├── Panel_2.0.1_all.ipk     # حزمة البانل للرسيفر
└── README.md
```

---

## 🛠️ البانل على الرسيفر

البانل ده بيشتغل على الرسيفر كخدمة (`e2ipkpanel`) على المنفذ **8765**:

| الملف | الوظيفة |
|---|---|
| `/usr/bin/e2ipkpanel` | السيرفر اللي بيستقبل الأوامر وبينفذها |
| `/usr/share/e2ipkpanel/index.html` | صفحة المتجر |
| `/etc/init.d/e2ipkpanel` | تشغيل وإيقاف الخدمة |
| `/etc/e2ipkpanel.conf` | الإعدادات (المنفذ، رابط الكتالوج، كود الربط) |

أوامر الإدارة:

```bash
/etc/init.d/e2ipkpanel start      # تشغيل
/etc/init.d/e2ipkpanel stop       # إيقاف
/etc/init.d/e2ipkpanel restart    # إعادة تشغيل
opkg remove e2-panel              # إزالة البانل
```

---

## 🩺 حل المشاكل

| المشكلة | الحل |
|---|---|
| الصفحة مش بتتصل بالرسيفر | تأكد إن الصفحة مفتوحة من `http://IP:8765` وإن `ping` بيرد |
| الأوامر مش بتظهر | تأكد إن `store.json` اترفع على GitHub ومفيهوش أخطاء JSON |
| التثبيت فشل | شوف خانة **[ERROR]** تحت الترمينال، فيها كود الخروج والسبب |
| الرسيفر مش بيعمل restart | لازم التثبيت يخلص من غير أخطاء |
| الكارت فيه نسخة قديمة | اعمل تحديث كامل `Ctrl+F5` أو نزّل الملف الجديد |

---

## 🤝 المساهمة

1. اعمل Fork للمشروع.
2. ضيف الأمر في `store.json` بالشكل المطلوب.
3. اعمل Pull Request مع وصف للأمر ومصدره.

> ⚠️ **تنبيه:** الأوامر بتتنفذ على الرسيفر مباشرة. اقرأ وصف الأمر قبل ما تثبته، وخد نسخة احتياطية من إعداداتك لو الأمر بيعدّل ملفات النظام.

---

## 📜 الترخيص

الكود مرخص تحت رخصة **MIT**. الأوامر والإضافات المذكورة ملك لأصحابها الأصليين، والمستودع بيوفرها للاستخدام الشخصي فقط.

---

<div align="center">

**صُنع بحب لمجتمع Enigma2 ❤️**

</div>
