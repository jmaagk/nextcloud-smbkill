#!/bin/bash

# This script should be run with superuser privileges to actually allow process killing.

# Getting the PIDs of all /usr/bin/smbclient processes
# and exiting if none are currently running.
if ! pids=$(pidof /usr/bin/smbclient); then
    echo "No SMB processes are currently running, nothing to do, exiting"
    exit 0
fi


# Using the previously gotten PIDs to call ps to get the total time since the processes
# were started as well as their cumulative CPU times.
#                                                                  removing the leading spaces of ps's output
readarray process_lines <<< $(ps -o pid=,etimes=,times= -p $pids | awk '{$1=$1}1')

for process_line in "${process_lines[@]}"; do
    # removing unnecessary newlines
    process_line=$(echo $process_line | tr -d '\n')

    # splitting the current line into its parts (separated by a single space)
    read -a split_process_line <<< $process_line

    pid=${split_process_line[0]}
    elapsed=${split_process_line[1]}
    cpu_time=${split_process_line[2]}

    # If the current process has been running for 60 seconds or more,
    # it's a possible candidate for a dead-end process. This value could also be lower.
    # If the difference between the elapsed time and the CPU time is less
    # than a certain amount (5 seconds in this case), the process has been
    # using the CPU for most of its lifetime. This is a definite indicator for the type of
    # process this script is supposed to kill.
    if [ $elapsed -ge 60 ] && [ $(($elapsed - $cpu_time)) -le 5 ]; then
        # a dead-end process has been found; killing it here
        echo "Killing process $pid"
        kill $pid
    fi
done
