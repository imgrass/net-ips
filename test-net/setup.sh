#!/bin/bash
## test net struct

#----------------------------------------
# parameters
fe=$(ip netns | grep fee)
result="tmp.view"
echo "start test net ..." > $result
date >> $result
#----------------------------------------

function exec_cmd() {
	echo "xxx===================================" >> $result
	echo "$1" >> $result
	eval "$1" >> $result
	echo "" >> $result
	echo "" >> $result
}

function ip_ro_show_tables() {
	local offset=$1
	local mode=$2
	local ipv=$3
	local i=0
	local table
	local cmd

	echo "xxx===================================" >> $result
	until [ $i -ge $mode ]
	do
		let table=offset+i
		cmd="ip netns exec $fe ip $ipv route show table $table"
		echo "$cmd" >> $result
		eval "$cmd" >> $result
		let i=i+1
	done
	echo "" >> $result
	echo "" >> $result
}

exec_cmd "ip a"
exec_cmd "ip netns exec $fe ip a"

exec_cmd "iptables -t filter -nvL --line-number"
exec_cmd "ip6tables -t filter -nvL --line-number"

exec_cmd "ip netns exec $fe iptables -t mangle -nvL"
exec_cmd "ip netns exec $fe ip rule"
ip_ro_show_tables 2048 32

exec_cmd "ip netns exec $fe ip6tables -t mangle -nvL"
exec_cmd "ip netns exec $fe ip -6 rule"
ip_ro_show_tables 2048 32 -6

exec_cmd "ip netns exec $fe iptables -nvL --line-number"
exec_cmd "ip netns exec $fe ip6tables -nvL --line-number"


# tcpdump -t -i adc_tun_1 -v | grep IPIP
