#!/bin/bash

# Main Function
user_activity() {
  echo "---------------------"
  echo "LOADING REPORT FOR $1"
  echo "---------------------"

  # Checks if option -n is present
  if [ $2 -eq 1 ]; then
    # Lists last connections in the past week, filters the current user, and counts the lines in the output
    echo "Number of connections in the last week for $1: $(last -w | grep "$1" | wc -l)"
    # Does the same as before, but calculates the login time and sums it
    echo "Connection time for $1 in the past week: $(last -w | grep "$1" | awk '{print $(NF)}' | grep -v "+\|-\|in" | tr -d "()" | awk '{sum += $1+$2/60} END {print sum}') hour(s)"
  fi
  # Checks if option -a is present
  if [ $3 -eq 1 ]; then
    sudo find / -user $1 -mtime -1
  fi
}

if [[ $(whoami | grep 'root') != "root" ]]; then
  echo "Error: script must be run as root" && exit 1
fi

if [[ $# -eq 0 ]]; then
    echo "Usage: $0 [-a] [-n] [-u user]"  
    exit 1
fi

users=$(awk -F: '$3 >= 1000 && $1 != "nobody" {print $1}' /etc/passwd)
n=0
a=0

while getopts "u:na" opt; do  
    case $opt in  
        u)
          users=${OPTARG}
          if ! id "$users" &>/dev/null; then  
            echo "User $users not found" && exit 1
          fi;;
        n)
          n=1;;
        a)
          a=1
    esac
done

for user in $users
do
  report_dir="/root/reports/$user-$(date '+%Y-%m-%d-%H-%M-%S')"
  mkdir -p "$report_dir"
  user_activity $user $n $a 2>&1 | tee -a "$report_dir/report.txt"
done
