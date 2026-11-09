#!/bin/sh
# Usage: ./make_update.sh e2-panel_3.0.1_all.ipk 3.0.1 "Short release notes"
# Writes update.json next to the ipk. Upload BOTH files to the repo (same folder), then the
# "Update panel" button and the automatic check on every open will offer the new version.
IPK="$1"; VER="$2"; NOTES="$3"
[ -f "$IPK" ] && [ -n "$VER" ] || { echo "usage: $0 file.ipk version [notes]"; exit 1; }
BASE="https://raw.githubusercontent.com/Major309Robin/E2-Store/refs/heads/main"
SHA=$(sha256sum "$IPK" | cut -d' ' -f1)
printf '{\n  "version": "%s",\n  "ipk": "%s/%s",\n  "sha256": "%s",\n  "notes": "%s"\n}\n' "$VER" "$BASE" "$(basename "$IPK")" "$SHA" "$NOTES" > update.json
cat update.json
