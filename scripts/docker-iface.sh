#/bin/bash
if [ "$#" -ne 6 ]; then
    echo "Illegal number of parameters"
    echo ""
    echo "Proper usage:"
    echo "docker-iface.sh <c_name> <gen_ip> <h_if_name> <br_name> <h_br_name> <h_ip>"
    echo ""
    echo "  c_name:     Name of the container"
    echo "  gen_ip:     IP to assign to the container in format 192.168.10.134/24"
    echo "  h_if_name:  Name of the network interface on the host system to bridge to (eth0)"
    echo "  br_name:    Name of the bridge adapter in the container (can be anything except h_br_name)"
    echo "  h_br_name:  Name of the bridge adapter in the host (can be anything except br_name)"
    echo "  h_ip:       IP to assign to the host in format 192.168.10.135/24"
    echo ""
    echo "Example usage:"
    echo "docker-iface.sh ubuntu 192.168.109.22/24 eth0 ubuntu-br0 dockerhost-br0 192.168.109.23/24"
    echo ""
    exit 1
fi

C_NAME="$1"
C_PID=`docker-pid.sh $C_NAME`
GEN_IP="$2"
H_IF_NAME="$3"
BR_NAME="$4"
H_BR_NAME="$5"
H_IP="$6"
ROUTE=`/sbin/ip route | awk '/default/ { print $3 }'`
GEN_IP_NOMASK=`echo $2 | cut -d \/ -f 1`

echo "ip link add $BR_NAME link $H_IF_NAME type macvlan mode bridge"
echo "ip link set netns $C_PID $BR_NAME"
echo "nsenter -t $C_PID -n ip link set $BR_NAME up"
echo "nsenter -t $C_PID -n ip route del default"
echo "nsenter -t $C_PID -n ip addr add $GEN_IP dev $BR_NAME"
echo "nsenter -t $C_PID -n ip route add default via $ROUTE dev $BR_NAME"
echo "ip link add $H_BR_NAME link $H_IF_NAME type macvlan mode bridge"
echo "ip link set $H_BR_NAME up"
echo "ip addr add $H_IP dev $H_BR_NAME"
echo "ip route add $GEN_IP_NOMASK dev $H_BR_NAME"

