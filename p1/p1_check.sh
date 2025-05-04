#!/bin/bash

# Script de test automatique pour p1 du projet Inception-of-Things

# Couleurs pour l'affichage
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Fonction d'affichage OK/KO
function ok() {
    echo -e "${GREEN}[OK]${NC} $1"
}

function ko() {
    echo -e "${RED}[KO]${NC} $1"
}

# Test 1 : VMs en fonctionnement
vagrant status | grep running | grep vfusterS &> /dev/null && ok "vfusterS running" || ko "vfusterS not running"
vagrant status | grep running | grep vfusterSW &> /dev/null && ok "vfusterSW running" || ko "vfusterSW not running"

# Test 2 : IPs des interfaces eth1
IP_SERVER=$(vagrant ssh vfusterS -c "ip -4 addr show eth1 | grep inet | awk '{print \$2}' | cut -d/ -f1" 2>/dev/null | tr -d '\r')
IP_WORKER=$(vagrant ssh vfusterSW -c "ip -4 addr show eth1 | grep inet | awk '{print \$2}' | cut -d/ -f1" 2>/dev/null | tr -d '\r')

[ "$IP_SERVER" = "192.168.56.110" ] && ok "vfusterS has correct IP 192.168.56.110" || ko "vfusterS IP incorrect: $IP_SERVER"
[ "$IP_WORKER" = "192.168.56.111" ] && ok "vfusterSW has correct IP 192.168.56.111" || ko "vfusterSW IP incorrect: $IP_WORKER"

# Test 3 : Hostnames
HN_SERVER=$(vagrant ssh vfusterS -c "hostname" 2>/dev/null | tr -d '\r')
HN_WORKER=$(vagrant ssh vfusterSW -c "hostname" 2>/dev/null | tr -d '\r')

[ "$HN_SERVER" = "vfusterS" ] && ok "Hostname vfusterS correct" || ko "Hostname vfusterS incorrect: $HN_SERVER"
[ "$HN_WORKER" = "vfusterSW" ] && ok "Hostname vfusterSW correct" || ko "Hostname vfusterSW incorrect: $HN_WORKER"

# Test 4 : K3s nodes
NODES=$(vagrant ssh vfusterS -c "sudo k3s kubectl get nodes -o wide" 2>/dev/null)
echo "$NODES"  # Afficher toujours les nodes pour information
if echo "$NODES" | grep vfusters &> /dev/null && echo "$NODES" | grep vfustersw &> /dev/null; then
    ok "Both nodes (vfusterS + vfusterSW) are part of the cluster"
else
    ko "Cluster nodes missing. Output:\n$NODES"
fi