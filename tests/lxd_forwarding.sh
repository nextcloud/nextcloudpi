#!/bin/bash

GUEST_IP="${1}"
OP="${2}"
IFACE=lxdbr0

function manage_ports() 
{
   local GUEST_IP=$1
   local GUEST_PORT=$2
   local HOST_PORT=$3
   local OP=$4

   if [ "${OP}" = "stopped" ] || [ "${OP}" = "reconnect" ]; then
	/sbin/iptables -D FORWARD -o "${IFACE}" -p tcp -d $GUEST_IP --dport $GUEST_PORT -j ACCEPT
	/sbin/iptables -t nat -D PREROUTING -p tcp --dport $HOST_PORT -j DNAT --to $GUEST_IP:$GUEST_PORT
   fi
   if [ "${OP}" = "start" ] || [ "${OP}" = "reconnect" ]; then
	/sbin/iptables -I FORWARD -o "${IFACE}" -p tcp -d $GUEST_IP --dport $GUEST_PORT -j ACCEPT
	/sbin/iptables -t nat -I PREROUTING -p tcp --dport $HOST_PORT -j DNAT --to $GUEST_IP:$GUEST_PORT
   fi
}

manage_ports "${GUEST_IP}" 80 80 "${OP}"
manage_ports "${GUEST_IP}" 443 443 "${OP}"
manage_ports "${GUEST_IP}" 4443 4443 "${OP}"

# these are for SMB
manage_ports "${GUEST_IP}" 137 137 "${OP}"
manage_ports "${GUEST_IP}" 138 138 "${OP}"
manage_ports "${GUEST_IP}" 139 139 "${OP}"
manage_ports "${GUEST_IP}" 445 445 "${OP}"
manage_ports "${GUEST_IP}" 900 900 "${OP}"
