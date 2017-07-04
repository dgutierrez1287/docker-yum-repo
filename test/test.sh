#!/bin/bash

## constants
imageName="dgutierrez1287/yum-repo"

## command line args


##
# installTestDeps()
# args: containerID
# This will install dependencies needed
# to test that aren't installed on the container
##
function installTestDeps() {
    local _containerID=$1

    
}

##
# findUnusedPort()
# This will return the number of an unused port
##
function findUnusedPort() {

    local _lowerPort=$(cat /proc/sys/net/ipv4/ip_local_port_range | awk '{print $1}')
    local _upperPort=$(cat /proc/sys/net/ipv4/ip_local_port_range | awk '{print $2}')
    local _port

    while :; do
        for ((  _port = _lowerPort; port <= _upperPort ; _port++ )); do
            local _test
            _test=$(netstat -ant | grep $_port)
            if [[ -z $_test ]]; then
                break 2
            fi
        done
    done
    echo $_port
}

##
# startTestContainer()
# This will start the test container
##
function startTestContainer() {
    local _port=$1


}

## MAIN() ##

testingPort=$(findUnusedPort)


