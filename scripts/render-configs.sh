#!/usr/bin/env bash
# Fills config templates with values from config/env.sh -> build/
set -e
cd "$(dirname "$0")/.."
source config/env.sh
BREW_PREFIX="$(brew --prefix 2>/dev/null || echo /opt/homebrew)"
mkdir -p build
render() {
  sed -e "s|__TEAM__|$TEAM|g" -e "s|__MAC1_IP__|$MAC1_IP|g" -e "s|__MAC2_IP__|$MAC2_IP|g" \
      -e "s|__MAC3_IP__|$MAC3_IP|g" -e "s|__MAC4_IP__|$MAC4_IP|g" \
      -e "s|__PORT_A__|$PORT_A|g" -e "s|__PORT_B__|$PORT_B|g" \
      -e "s|__HTTP_PORT__|$HTTP_PORT|g" -e "s|__HTTPS_PORT__|$HTTPS_PORT|g" \
      -e "s|__PKI_DIR__|$PKI_DIR|g" -e "s|__BREW_PREFIX__|$BREW_PREFIX|g" "$1" > "$2"
}
render config/dnsmasq.conf.template build/dnsmasq.conf
render config/nginx/team1.conf.template build/${TEAM}.conf
echo "Rendered into build/. Install with:"
echo "  Mac 1: cp build/dnsmasq.conf \"$BREW_PREFIX/etc/dnsmasq.conf\" && sudo brew services restart dnsmasq"
echo "  Mac 2: cp build/${TEAM}.conf \"$BREW_PREFIX/etc/nginx/servers/${TEAM}.conf\" && sudo nginx -t && sudo nginx -s reload"
