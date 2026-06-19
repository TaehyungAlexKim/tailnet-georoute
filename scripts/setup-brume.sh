#!/bin/sh
# setup-brume.sh — install a gost SOCKS5 proxy on an OpenWrt / GL.iNet router
# (e.g. GL-MT2500 "Brume 2") and run it on boot, bound to the device's Tailscale IP.
#
# Each router becomes one egress endpoint. Run this on TWO routers in different
# locations/ISPs, then load-balance them from a central host (see ../balancer/).
#
# Usage:   ./setup-brume.sh <tailscale-ip> [port]
# Example: ./setup-brume.sh 100.64.0.10 1080   (use your router's real tailnet IP)
#
# Override the download if auto arch-detection is wrong:
#   GOST_URL=https://.../gost_2.12.0_linux_arm64.tar.gz ./setup-brume.sh 100.x.y.z
set -eu

TSIP="${1:-${TSIP:-}}"
PORT="${2:-${PORT:-1080}}"
GOST_VER="${GOST_VER:-2.12.0}"

[ -n "$TSIP" ] || { echo "usage: $0 <tailscale-ip> [port]"; exit 1; }

# --- pick gost release asset for this CPU --------------------------------------
arch="$(uname -m)"
case "$arch" in
  aarch64|arm64)  ga=arm64 ;;
  armv7l|armv7)   ga=armv7 ;;
  armv6l)         ga=armv6 ;;
  x86_64|amd64)   ga=amd64 ;;
  i386|i686)      ga=386 ;;
  mips)           ga=mips ;;
  mipsel|mipsle)  ga=mipsle ;;
  *) echo "unknown arch '$arch' — set GOST_URL manually"; [ -n "${GOST_URL:-}" ] || exit 1 ;;
esac
GOST_URL="${GOST_URL:-https://github.com/ginuerzh/gost/releases/download/v${GOST_VER}/gost_${GOST_VER}_linux_${ga}.tar.gz}"

# --- download + install gost ---------------------------------------------------
echo ">> installing gost ($GOST_URL)"
cd /tmp
if command -v curl >/dev/null 2>&1; then
  curl -fsSL -o gost.tar.gz "$GOST_URL"
else
  wget -qO gost.tar.gz "$GOST_URL"
fi
tar xzf gost.tar.gz
gbin="$(find . -maxdepth 2 -name gost -type f | head -1)"
[ -n "$gbin" ] || { echo "gost binary not found in archive"; exit 1; }
chmod +x "$gbin" && mv "$gbin" /usr/bin/gost
rm -f gost.tar.gz
/usr/bin/gost -V

# --- procd init service: wait for the Tailscale IP, then bind to it ------------
echo ">> installing /etc/init.d/gost-socks (bind ${TSIP}:${PORT})"
cat > /etc/init.d/gost-socks <<EOF
#!/bin/sh /etc/rc.common
START=99
STOP=10
USE_PROCD=1
TSIP="${TSIP}"
PORT="${PORT}"
start_service() {
    procd_open_instance
    procd_set_param command /bin/sh -c "until ip -4 addr show | grep -q \$TSIP; do sleep 2; done; exec /usr/bin/gost -L socks5://\$TSIP:\$PORT"
    procd_set_param respawn
    procd_close_instance
}
EOF
chmod +x /etc/init.d/gost-socks

killall gost 2>/dev/null || true
/etc/init.d/gost-socks enable
/etc/init.d/gost-socks start
sleep 2

echo ">> verifying egress (should print this router's public IP):"
if command -v curl >/dev/null 2>&1; then
  curl -fsS --socks5 "${TSIP}:${PORT}" https://api.ipify.org && echo
else
  echo "   curl not present; test from another host:  curl --socks5-hostname ${TSIP}:${PORT} https://api.ipify.org"
fi
echo ">> done. NOTE: a GL.iNet firmware (sysupgrade) may wipe /usr/bin/gost — re-run this script if so."
