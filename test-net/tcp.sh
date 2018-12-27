#!/bin/bash
fe=$(ip netns | grep fe)
echo "" >> tcp.pcap

case $1 in
    1)
	ip netns exec $fe tcpdump -i eth3.116 -vvv -n host 10.21.0.4 #-w eth3_116.pcap
	;;
    2)
	ip netns exec $fe tcpdump -i adc_tun_1 -vvv -n #-w tcp_tun.pcap
	;;
    3)
	tcpdump -i adc_ipvlan0 -vvv -n #-w tcp_ipvlan.pcap
	;;
    4)
	tcpdump -i alb1 -vvv -n #-w tcp_alb1.pcap
	;;
    *)
	echo "no reply"
	;;
esac

