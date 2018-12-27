#!/bin/bash
# add log for all iptables chains of all ns

#================================================
#get all ns in the host
str=$(ip netns | cut -d ' ' -f 1)
namespace_arr=($str)
#================================================

function set_log_by_table() {

	local ns table version 

	while getopts  "n:t:v" arg
	do
		case "$arg" in
		    n)
			ns="$OPTARG"
			;;
		    t)
			table="$OPTARG"
			;;
		    v)
			version=6
			;;
		    ?)
			;;
		esac
	done
	OPTIND=1

	str=$(printf "ip netns exec %s ip%stables -t %s -nL |\
		      grep -E "^Chain" | cut -d ' ' -f 2"\
		      "$ns" "$version" "$table")
	cmd=$(eval $str)
	local chain_arr=($cmd)

	local i
	for i in ${chain_arr[@]}
	do
		echo "$i" | grep ".*:.*"
		if [ $? -eq 0 ]; then
			continue
		fi
		local prefix="x<${version}-${ns}-${table}-${i}>"
		echo "$prefix"

		#---------------------------
		# clear old 
		# str=$(printf "ip netns exec %s ip%stables -t %s -D \"%s\" 1" "$ns" "$version" "$table" "$i")
		# echo "$str"
		# eval "$str"
		#---------------------------

		str=$(printf "ip netns exec %s ip%stables -t %s -I \"%s\" -j LOG --log-level 4 --log-prefix \"%s\"" "$ns" "$version" "$table"  "$i" "$prefix")
		echo "$str"
		eval "$str"
	done
}

function set_iptables_log() {
	local ns="$1"
	local table_arr=(raw mangle nat filter)

	local i
	for i in ${table_arr[@]} 
	do
		echo "-----------------------------"
		echo "--$ns -> $i "
		echo "ipv4 +++"
		set_log_by_table -n "$ns" -t "$i" -v
		printf "\nipv6 +++\n"
		set_log_by_table -n "$ns" -t "$i" 
		echo ""
	done
}
#================================================
# start...

for i in ${namespace_arr[@]}
do
	# todo set log for iptables
	echo "xxx===================================" 
	echo "in namespace $i"
	set_iptables_log "$i"
	echo ""
done

