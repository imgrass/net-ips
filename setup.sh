#!/bin/bash

## This script uses network namespace to build a virtual network 
## simulating docker bridge net.

#==============================================================
# define parameters
NS1="net0"
NS2="net1"

#***********************
# for veth
peer1="adc0_veth"
v_peer1="adc0_veth"
peer2="adc1_veth"
v_peer2="adc1_veth"

#***********************
# for macvlan
parent="enp6s0"
mv1="adc_macvlan0"
mv2="adc_macvlan1"
#==============================================================

switch="macvlan"
source ./func/sub_fun.sh
case $switch in
    "veth")
        build_ns="build_ns_with_veth\
                  $NS1 $NS2 $peer1 $v_peer1 $peer2 $v_peer2"
        ;;
    "macvlan")
        build_ns="build_ns_with_macvlan\
                  $NS1 $NS2 $parent $mv1 $mv2"
        ;;
    *)
        ;;
esac
#==============================================================

function exec_exit() {
    if [ $? -eq 0 ]; then
        return 0
    else
        echo $1
        exit 1
    fi
}

function exec_cmd() {
    echo -e "cmd <$1>"
    eval "$1"
    exec_exit "exec <$1> failed"
}

function del_ns() {
    ip netns del $NS1
    ip netns del $NS2
    ip link del dev br0
}

function cmd_stop() {
    ip netns | cut -d ' ' -f 1 | grep -E "^net[01]$"
    if [ $? -eq 0 ]; then
        echo "namespace already exist, delete it"
        del_ns
        exec_exit "----clear env failed----"
        echo "====clear env successfully===="
    fi
}

function cmd_start() {
    cmd_stop
    exec_cmd "$build_ns"
    exec_exit "----build env failed----"
    echo "====build env successfully===="
}

case "$1" in
    "start" )
        cmd_start
        ;;
    "stop"  ) 
        cmd_stop
        ;;
    *       ) 
        echo "Usage: setup.sh {start | stop}"
        ;;
esac
