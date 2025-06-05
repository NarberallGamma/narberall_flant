#!/bin/bash

SSH_CONFIG="$HOME/.ssh/config"

# IP-адреса
IPS=(
13.213.243.169
13.251.204.11
175.41.166.131
18.138.0.69
18.138.181.248
3.121.55.124
3.124.59.48
3.125.139.218
3.126.100.196
3.127.161.202
3.127.97.148
3.70.127.49
3.71.226.161
35.156.164.2
52.220.229.188
52.220.55.89
52.221.20.130
52.29.86.208
52.74.136.235
52.74.26.190
52.77.39.35
54.151.151.68
54.151.242.115
54.251.238.171
)

# Временный файл для хранения IP -> Host
TEMP_FILE=$(mktemp)

current_host=""
while IFS= read -r line; do
    if [[ "$line" =~ ^[[:space:]]*Host[[:space:]]+(.+) ]]; then
        current_host="${BASH_REMATCH[1]}"
    elif [[ "$line" =~ ^[[:space:]]*Hostname[[:space:]]+([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+) ]]; then
        hostname="${BASH_REMATCH[1]}"
        echo "$hostname $current_host" >> "$TEMP_FILE"
    fi
done < "$SSH_CONFIG"

# Заголовок
printf "%-16s | %-10s | %s\n" "IP" "Match" "Host Alias"
printf "%s\n" "------------------|------------|----------------"

# Проверка
for ip in "${IPS[@]}"; do
    match=$(grep "^$ip " "$TEMP_FILE")
    if [[ -n "$match" ]]; then
        alias=$(echo "$match" | awk '{print $2}')
        printf "%-16s | %-10s | %s\n" "$ip" "Yes" "$alias"
    else
        printf "%-16s | %-10s | %s\n" "$ip" "No" "-"
    fi
done

# Удаление временного файла
rm -f "$TEMP_FILE"
