#!/usr/bin/env sh
# Chroma Audio Suite - Cross-Platform macOS / Linux CI/CD Discovery Slug
# Run cleanly from any Terminal:
#   curl -fsSL https://raw.githubusercontent.com/haidood/chroma-release/main/update.sh | sh
set -eu

REPO_RAW="https://raw.githubusercontent.com/haidood/chroma-release/main"
CACHE_BUST="$(date +%s)"
OS_NAME="$(uname -s)"
ARCH_NAME="$(uname -m)"

echo ""
echo "================================================================"
echo "  CHROMA AUDIO SUITE // CI/CD AUDIT & INSTALLER ($OS_NAME $ARCH_NAME)"
echo "================================================================"

MANIFEST_TMP="$(mktemp /tmp/chroma_manifest.XXXXXX.json)"
trap 'rm -f "$MANIFEST_TMP"' EXIT

if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$REPO_RAW/version_manifest.json?t=$CACHE_BUST" -o "$MANIFEST_TMP"
elif command -v wget >/dev/null 2>&1; then
    wget -qO "$MANIFEST_TMP" "$REPO_RAW/version_manifest.json?t=$CACHE_BUST"
else
    echo "[ERROR] Neither curl nor wget is installed."
    exit 1
fi

SUITE_VER="$(grep -o '"suite_version"[[:space:]]*:[[:space:]]*"[^"]*"' "$MANIFEST_TMP" | head -n1 | cut -d'"' -f4 || echo 'unknown')"
echo "[CI/CD] Live Manifest: Chroma Audio Suite v$SUITE_VER"

if [ "$OS_NAME" = "Darwin" ]; then
    DEFAULT_VST3="$HOME/Library/Audio/Plug-Ins/VST3"
    DEFAULT_AU="$HOME/Library/Audio/Plug-Ins/Components"
    SCAN_DIRS="/Library/Audio/Plug-Ins/VST3 $HOME/Library/Audio/Plug-Ins/VST3 /Library/Audio/Plug-Ins/Components $HOME/Library/Audio/Plug-Ins/Components /Library/Audio/Plug-Ins/VST $HOME/Library/Audio/Plug-Ins/VST"
else
    DEFAULT_VST3="$HOME/.vst3"
    DEFAULT_AU="$HOME/.vst"
    SCAN_DIRS="/usr/lib/vst3 /usr/local/lib/vst3 $HOME/.vst3 $HOME/.vst"
fi

echo ""
echo "--- EXISTING CHROMA PLUGIN AUDIT ---"
FOUND_ANY=0
for d in $SCAN_DIRS; do
    if [ -d "$d" ]; then
        MATCHES="$(find "$d" -maxdepth 2 -iname 'Chroma*' 2>/dev/null || true)"
        if [ -n "$MATCHES" ]; then
            FOUND_ANY=1
            echo "[FOUND in $d]:"
            echo "$MATCHES" | sed 's/^/  - /'
        fi
    fi
done
if [ "$FOUND_ANY" = "0" ]; then
    echo "  No existing Chroma Audio plugins found in standard user/system folders."
fi

echo ""
echo "Default target VST3 folder: $DEFAULT_VST3"
if [ "$OS_NAME" = "Darwin" ]; then
    echo "Default target AU folder  : $DEFAULT_AU"
fi

# Check if CI/CD has published macOS universal/arm64 artifacts yet
if command -v curl >/dev/null 2>&1; then
    MAC_CHECK_CODE="$(curl -s -o /dev/null -w '%{http_code}' "$REPO_RAW/precompiled/mac/mac_manifest.json?t=$CACHE_BUST" || echo '404')"
else
    MAC_CHECK_CODE="404"
fi

if [ "$MAC_CHECK_CODE" = "200" ]; then
    echo "[CI/CD] macOS Universal binaries detected on release CDN."
    printf "Press ENTER to use %s or enter custom VST3 folder path: " "$DEFAULT_VST3"
    read -r CUSTOM_VST3 </dev/tty || CUSTOM_VST3=""
    VST3_DIR="${CUSTOM_VST3:-$DEFAULT_VST3}"
    mkdir -p "$VST3_DIR"
    echo "[*] Syncing macOS VST3 bundles to $VST3_DIR..."
    # Download mac manifest list when published
    MAC_JSON="$(mktemp /tmp/chroma_mac.XXXXXX.json)"
    curl -fsSL "$REPO_RAW/precompiled/mac/mac_manifest.json?t=$CACHE_BUST" -o "$MAC_JSON"
    python3 - "$MAC_JSON" "$REPO_RAW/precompiled/mac" "$VST3_DIR" <<'PYEOF'
import json, sys, urllib.request, zipfile, io, os
m = json.load(open(sys.argv[1]))
base, dst = sys.argv[2], sys.argv[3]
for item in m.get("bundles", []):
    url = f"{base}/{item}"
    print(f"  [+] Installing {item}...")
    data = urllib.request.urlopen(url).read()
    if item.endswith(".zip"):
        with zipfile.ZipFile(io.BytesIO(data)) as zf:
            zf.extractall(dst)
PYEOF
    rm -f "$MAC_JSON"
    echo "[SUCCESS] macOS Chroma Audio Suite synced to $VST3_DIR"
else
    echo ""
    echo "[INFO] Current CI/CD release on haidood/chroma-release ships Windows x64 VST2/VST3 binaries (.dll / .vst3)."
    echo "       No macOS (.vst3/.component) build artifacts are published on CI/CD yet."
    echo "       On Windows, run the 1-line CI/CD updater slug in PowerShell:"
    echo "         irm $REPO_RAW/update.ps1 | iex"
    echo ""
fi
