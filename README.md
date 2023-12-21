sudo modprobe dummy
sudo ip link add name dummy0 type dummy
sudo ip addr add 172.28.0.1/24 dev dummy0
sudo ip link set dummy0 up

=> OK

persistence ?
