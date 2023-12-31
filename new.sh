sudo modprobe dummy
sudo ip link add name docker2 type dummy
sudo ip addr add 172.28.0.1/24 dev docker2
sudo ip link set docker2 up
