#!/bin/bash

# Variables
IP="10.10.100.248"
LOGFILE="./switch_port_status.txt"
SNMPWALK="/usr/bin/snmpwalk"  # make sure snmpwalk is installed
OID_IFOPERSTATUS=".1.3.6.1.2.1.2.2.1.8"
COMMUNITY="aapico"

declare -A result
declare -A record

while true; do
    # Get port status via SNMP
    status=$($SNMPWALK -v2c -c "$COMMUNITY" "$IP" "$OID_IFOPERSTATUS")

    # Parse the SNMP output and fill the result array
    while read -r line; do
        if [[ $line =~ IF-MIB::ifOperStatus\.([0-9]+)[[:space:]]*=[[:space:]]*INTEGER:[[:space:]]*([a-zA-Z]+)\([0-9]+\) ]]; then
            port="${BASH_REMATCH[1]}"
            state="${BASH_REMATCH[2]}"
            result[$port]="$state"
        fi
    done <<< "$status"

    # Initialize record if empty
    if [ ${#record[@]} -eq 0 ]; then
        for key in "${!result[@]}"; do
            record[$key]="${result[$key]}"
        done
        echo "Initial port statuses recorded at $(date '+%Y-%m-%d %H:%M:%S')" >> "$LOGFILE"
        for key in "${!record[@]}"; do
            echo "Port $key: ${record[$key]}" >> "$LOGFILE"
        done
        sleep 30
        continue
    fi

    # Check for changes
    for key in "${!result[@]}"; do
        if [ "${record[$key]}" != "${result[$key]}" ]; then
            msg="Port $key status changed from ${record[$key]} to ${result[$key]} at $(date '+%Y-%m-%d %H:%M:%S')"
            echo -e "\e[36m$msg\e[0m"  # Cyan color
            echo "$msg" >> "$LOGFILE"
            record[$key]="${result[$key]}"
        fi
    done

    sleep 30
done
