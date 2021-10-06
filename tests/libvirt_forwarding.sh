#!/bin/bash

# copy to /etc/libvirt/hooks/qemu and restart libvirtd

function manage_ports() 
{
   local GUEST_IP=$1
   local GUEST_PORT=$2
   local HOST_PORT=$3
   local OP=$4

   if [ "${OP}" = "stopped" ] || [ "${OP}" = "reconnect" ]; then
	/sbin/iptables -D FORWARD -o virbr1 -p tcp -d $GUEST_IP --dport $GUEST_PORT -j ACCEPT
	/sbin/iptables -t nat -D PREROUTING -p tcp --dport $HOST_PORT -j DNAT --to $GUEST_IP:$GUEST_PORT
   fi
   if [ "${OP}" = "start" ] || [ "${OP}" = "reconnect" ]; then
	/sbin/iptables -I FORWARD -o virbr1 -p tcp -d $GUEST_IP --dport $GUEST_PORT -j ACCEPT
	/sbin/iptables -t nat -I PREROUTING -p tcp --dport $HOST_PORT -j DNAT --to $GUEST_IP:$GUEST_PORT
   fi
}

VM_NAME="${1}"
OP="${2}"
GUEST_IP=192.168.121.243

# IMPORTANT: Change the "VM NAME" string to match your actual VM Name.
# In order to create rules to other VMs, just duplicate the below block and configure
# it accordingly.
[ "${VM_NAME}" = "nextcloudpi_default" ] || exit 0

manage_ports "${GUEST_IP}" 80 80 "${OP}"
manage_ports "${GUEST_IP}" 443 443 "${OP}"
manage_ports "${GUEST_IP}" 4443 4443 "${OP}"

# these are for SMB
manage_ports "${GUEST_IP}" 137 137 "${OP}"
manage_ports "${GUEST_IP}" 138 138 "${OP}"
manage_ports "${GUEST_IP}" 139 139 "${OP}"
manage_ports "${GUEST_IP}" 445 445 "${OP}"
manage_ports "${GUEST_IP}" 900 900 "${OP}"
