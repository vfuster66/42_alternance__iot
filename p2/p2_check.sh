#!/bin/bash

# Script de test pour la partie 2 du projet Inception-of-Things

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

ok() {
    echo -e "${GREEN}[OK]${NC} $1"
}

ko() {
    echo -e "${RED}[KO]${NC} $1"
}

# Test 1 : IP eth1
IP=$(vagrant ssh vfusterS -c "ip a show eth1 | grep 'inet ' | awk '{print \$2}' | cut -d/ -f1" 2>/dev/null | tr -d '\r')
[ "$IP" = "192.168.56.110" ] && ok "eth1 IP is correct: $IP" || ko "eth1 IP is incorrect: $IP"

# Test 2 : Hostname
HN=$(vagrant ssh vfusterS -c "hostname" 2>/dev/null | tr -d '\r')
[ "$HN" = "vfusterS" ] && ok "Hostname is correct: $HN" || ko "Hostname is incorrect: $HN"

# Test 3 : K3s server running
vagrant ssh vfusterS -c "sudo k3s kubectl get nodes -o wide" 2>/dev/null | grep Ready &> /dev/null \
    && ok "K3s node is Ready" || ko "K3s node not Ready"

# Test 4 : Deployments and replicas
DEPLOY=$(vagrant ssh vfusterS -c "sudo k3s kubectl get deployments" 2>/dev/null)

echo "$DEPLOY" | grep app1 &>/dev/null && ok "Deployment app1 exists" || ko "Deployment app1 missing"
echo "$DEPLOY" | grep app2 &>/dev/null && ok "Deployment app2 exists" || ko "Deployment app2 missing"
echo "$DEPLOY" | grep app3 &>/dev/null && ok "Deployment app3 exists" || ko "Deployment app3 missing"

REPLICAS=$(echo "$DEPLOY" | grep app2 | awk '{print $2}')
[ "$REPLICAS" = "3/3" ] && ok "app2 has 3 replicas" || ko "app2 does not have 3 replicas (has $REPLICAS)"

# Test 5 : Ingress rules
INGRESS=$(vagrant ssh vfusterS -c "sudo k3s kubectl get ingress" 2>/dev/null)
echo "$INGRESS" | grep app-ingress &>/dev/null && ok "Ingress is deployed" || ko "Ingress is missing"

# Test 6 : curl with Host headers
for APP in app1 app2 app3
  do
    RESP=$(curl -s -H "Host: $APP.com" http://192.168.56.110)
    echo "$RESP" | grep "Hello from App${APP: -1}" &>/dev/null \
      && ok "Response for $APP.com is correct" \
      || ko "Incorrect or no response for $APP.com"
  done

# Test 7 : Default route (fallback to app3)
RESP_DEFAULT=$(curl -s http://192.168.56.110)
echo "$RESP_DEFAULT" | grep "Hello from App3" &>/dev/null \
    && ok "Default ingress route is App3" \
    || ko "Default ingress route is not App3 (got: $RESP_DEFAULT)"