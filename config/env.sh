# EDIT THESE, then run: ./scripts/render-configs.sh
export TEAM="team1"
export MAC1_IP="192.168.1.11"   # DNS + test client
export MAC2_IP="192.168.1.12"   # Edge (nginx)
export MAC3_IP="192.168.1.13"   # Backend A
export MAC4_IP="192.168.1.14"   # Backend B
export PORT_A="3001"
export PORT_B="3002"
export HTTP_PORT="80"           # use 8080 if 80 is not allowed
export HTTPS_PORT="443"         # use 8443 if 443 is not allowed
export PKI_DIR="$HOME/${TEAM}-pki"
