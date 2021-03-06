#!/bin/bash

declare -i duration=1
declare hasTimestamp=""
declare hasUrl=""
declare runLoop=""
declare endpoint

usage() {
    cat <<END
    polling.sh [-t] [-i] [-l] [-h] endpoint
    
    Report the health status of the endpoint
    -t: include timestamp
    -i: include Uri for the format
    -l: run in the loop
    -h: help
END
}

while getopts "tilh" opt; do
    case $opt in
    t)
        hasTimestamp=true
        ;;
    i)
        hasUrl=true
        ;;
    l)
        runLoop=true
        ;;
    h)
        usage
        exit 0
        ;;
    \?)
        echo "Unknown option: -${OPTARG}" >&2
        exit 1
        ;;
    esac
done

shift $((OPTIND - 1))

if [[ $1 ]]; then
    endpoint=$1
else
    echo "Please specify the endpoint."
    usage
    exit 1
fi

healthcheck() {
    declare url=$1
    result=$(curl -i $url 2>/dev/null | grep HTTP/2)
    echo $result
}

while [[ true ]]; do
    result=$(healthcheck $endpoint)
    declare status
    if [[ -z $result ]]; then
        status="N/A"
    else
        status=${result:7:3}
    fi

    if [[ -z $hasTimestamp ]]; then
        return=${status}
    else
        timestamp=$(date "+%Y%m%d-%H%M%S")
        return="${timestamp} | ${status}"
    fi

    if [[ -n $hasUrl ]]; then
        return="${return} | ${endpoint}"
    fi

    if [[ -z $runLoop ]]; then
        echo ${return}
        exit 0
    else
        echo ${return}
        sleep $duration
    fi
done
