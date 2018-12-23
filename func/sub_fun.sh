#!/bin/bash

## this script is used to create actual network, it should be
## invoked by ../setup.sh

function build_ns_with_veth() {
    # parse $@
    NS1=$1
    NS2=$2
    peer1=$3
    v_peer1=$4
    peer2=$5
    v_peer2=$6

    ip link add br0 type bridge
    ip link set dev br0 up

    ip netns add $NS1
    ip link add type veth peer name $peer1
    ip link set dev veth0 netns $NS1
    ip netns exec $NS1 ip link set dev veth0 name $v_peer1
    ip netns exec $NS1 ip addr add 10.0.1.1/24 dev $v_peer1
    ip netns exec $NS1 ip link set dev $v_peer1 up
    ip link set dev $peer1 master br0
    ip link set dev $peer1 up

    ip netns add $NS2
    ip link add type veth peer name $peer2
    ip link set dev veth0 netns $NS2
    ip netns exec $NS2 ip link set dev veth0 name $v_peer2
    ip netns exec $NS2 ip addr add 10.0.1.2/24 dev $v_peer2
    ip netns exec $NS2 ip link set dev $v_peer2 up
    ip link set dev $peer2 master br0
    ip link set dev $peer2 up
}

function build_ns_with_macvlan() {
    # parse $@
    NS1=$1
    NS2=$2
    parent=$3
    mv1=$4
    mv2=$5

    ip netns add $NS1
    ip netns add $NS2

    # create the macvlan link attaching it to the parent host if
    ip link add $mv1 link $parent type macvlan mode bridge
    ip link add $mv2 link $parent type macvlan mode bridge

    # move the new if mv1/mv2 to the new ns
    ip link set $mv1 netns $NS1
    ip link set $mv2 netns $NS2

    # set ip address
    ip netns exec $NS1 ip addr add 10.0.1.1/24 dev $mv1
    ip netns exec $NS2 ip addr add 10.0.1.2/24 dev $mv2

    # bring the two if up
    ip netns exec $NS1 ip link set dev $mv1 up
    ip netns exec $NS2 ip link set dev $mv2 up
}
