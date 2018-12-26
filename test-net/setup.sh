#!/bin/bash
## test net struct

#----------------------------------------
# parameters
fe=$(ip netns | grep fee)
echo "start test net ..." > tmp.view
date >> tmp.view
#----------------------------------------

function exec_cmd() {
	echo "xxx===================================" >> tmp.view
	echo "$1" >> tmp.view
	eval "$1" >> tmp.view
	echo "" >> tmp.view
	echo "" >> tmp.view
}

exec_cmd "ip a"
exec_cmd "ip netns exec $fe ip a"

exec_cmd "iptables -t filter -nvL"
exec_cmd "ip6tables -t filter -nvL"

exec_cmd "ip netns exec $fe iptables -t mangle -nvL"
exec_cmd "ip netns exec $fe ip rule"

exec_cmd "ip netns exec $fe ip6tables -t mangle -nvL"
exec_cmd "ip netns exec $fe ip -6 rule"


# exec_cmd "ip netns exec $fe ping 10.21.0.4"
# exec_cmd "ip netns exec $fe ping 10.21.0.4 -I adc_tun_1"
# iptables -I INPUT -i alb1 -j ACCEPT
# ip6tables -I INPUT -i adc_ipvlan0 -j ACCEPT
