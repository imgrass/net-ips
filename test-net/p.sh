#!/bin/bash
fe=$(ip netns | grep fe)

function exec_cmd() {
	echo "xxx===================================" 
	echo "$1" 
	eval "$1"
	echo ""
}

cmd="ip netns  exec $fe ping 10.21.0.4 $1"
exec_cmd "$cmd"
