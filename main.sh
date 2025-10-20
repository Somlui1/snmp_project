
IP="10.10.100.248"
LOGFILE="./switch_port_status.txt"
SNMPWALK="/usr/bin/snmpwalk"
OID_IFOPERSTATUS=".1.3.6.1.2.1.2.2.1.8"
COMMUNITY="aapico"

declare -A result
declare -A record

while true; do
    status=$($SNMPWALK -v2c -c "$COMMUNITY" "$IP" "$OID_IFOPERSTATUS")

    while read -r line; do
        # Match iso.3.6.1.2.1.2.2.1.8.<ifIndex> = INTEGER: <state>
        if [[ $line =~ \.([0-9]+)[[:space:]]*=[[:space:]]*INTEGER:\ ([0-9]+) ]]; then
            port="${BASH_REMATCH[1]}"
            state="${BASH_REMATCH[2]}"
            # Convert state number to human-readable
            case $state in
                1) state_text="up" ;;
                2) state_text="down" ;;
                3) state_text="testing" ;;
                *) state_text="unknown" ;;
            esac
            result[$port]="$state_text"
        fi
    done <<< "$status"

    # Initialize record
    if [ ${#record[@]} -eq 0 ]; then
    for key in "${!result[@]}"; do
        record[$key]="${result[$key]}"
    done

    echo "Initial port statuses recorded at $(date '+%Y-%m-%d %H:%M:%S')" | tee -a "$LOGFILE"

    for key in "${!record[@]}"; do
        echo "Port $key: ${record[$key]}" | tee -a "$LOGFILE"
    done

    sleep 30
    continue
fi

    # Check for changes
    for key in "${!result[@]}"; do
        if [ "${record[$key]}" != "${result[$key]}" ]; then
            msg="Port $key status changed from ${record[$key]} to ${result[$key]} at $(date '+%Y-%m-%d %H:%M:%S')"
            echo -e "\e[36m$msg\e[0m"
            echo "$msg" >> "$LOGFILE"
            record[$key]="${result[$key]}"
        fi
    done

    sleep 30
done
