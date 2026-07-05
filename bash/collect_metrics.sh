#!/bin/bash

# =============================================================================================================================================================
# System Health Pipeline 
# Phase 1 - Bash Collector 
# Reads SystemHealthMonitor events from syslog and generates a structured csv file.
#===============================================================================================================================================================

INPUT_LOG="/var/log/syslog"
OUTPUT_FILE="../data/metrics.csv"
HOSTNAME=$(hostname)

# Crear encabezado del CSV
echo "timestamp,hostname,log_level,cpu_usage,disk_usage,ram_free" > "$OUTPUT_FILE"

# Buscar únicamente los eventos del proyecto
grep "SystemHealthMonitor" "$INPUT_LOG" | while read -r line
do
    TIMESTAMP=$(echo "$line" | awk '{print $1" "$2" "$3}')
    LEVEL=$(echo "$line" | grep -oE "INFO|WARNING|CRITICAL")
    CPU=$(echo "$line" | grep -oP 'CPU_USAGE=\K[0-9]+')
    DISK=$(echo "$line" | grep -oP 'DISK_USAGE=\K[0-9]+')
    RAM=$(echo "$line" | grep -oP 'RAM_FREE=\K[0-9]+')

    echo "$TIMESTAMP,$HOSTNAME,$LEVEL,$CPU,$DISK,$RAM" >> "$OUTPUT_FILE"
done

echo "CSV generated successfully."
echo "Output file: $OUTPUT_FILE"
