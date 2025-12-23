#!/usr/bin/env bash
# License: GPLv3
# Credits: Felipe Facundes

# Professional System Health Check Script
# Checks for zombie processes and memory usage

set -euo pipefail  # Exit on error, undefined variables, pipe failures

# Color codes for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Logging function
log() {
    local level=$1
    shift
    local message=$@
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    case $level in
        "INFO") echo -e "${GREEN}[INFO]${NC} $timestamp - $message" ;;
        "WARN") echo -e "${YELLOW}[WARN]${NC} $timestamp - $message" ;;
        "ERROR") echo -e "${RED}[ERROR]${NC} $timestamp - $message" ;;
        "DEBUG") echo -e "${BLUE}[DEBUG]${NC} $timestamp - $message" ;;
    esac
}

# Check for zombie processes
check_zombie_processes() {
    log "INFO" "Checking for zombie processes..."
    
    local zombie_count=$(ps aux | awk '$8 ~ /^[Zz]/' | wc -l)
    
    if [ "$zombie_count" -gt 0 ]; then
        log "WARN" "Found $zombie_count zombie process(es):"
        ps aux | awk '$8 ~ /^[Zz]/ {print "  PID: " $2 " - " $11}'
        return 1
    else
        log "INFO" "No zombie processes found"
        return 0
    fi
}

# Check memory usage
check_memory_usage() {
    log "INFO" "Checking system memory usage..."
    
    # Read memory information
    local mem_available=$(awk '/MemAvailable/{print $2}' /proc/meminfo)
    local mem_total=$(awk '/MemTotal/{print $2}' /proc/meminfo)
    
    if [ -z "$mem_available" ] || [ -z "$mem_total" ]; then
        log "ERROR" "Failed to read memory information"
        return 1
    fi
    
    # Calculate usage statistics
    local mem_used=$((mem_total - mem_available))
    local usage_percentage=$((mem_used * 100 / mem_total))
    
    # Convert to human readable format
    local mem_available_human=$(numfmt --from-unit=1024 --to=iec $mem_available 2>/dev/null || echo "${mem_available}KB")
    local mem_used_human=$(numfmt --from-unit=1024 --to=iec $mem_used 2>/dev/null || echo "${mem_used}KB")
    local mem_total_human=$(numfmt --from-unit=1024 --to=iec $mem_total 2>/dev/null || echo "${mem_total}KB")
    
    log "INFO" "Memory Usage: $mem_used_human used, $mem_available_human available, $mem_total_human total"
    
    # Warning thresholds
    if [ "$usage_percentage" -gt 90 ]; then
        log "ERROR" "Memory usage critical: ${usage_percentage}%"
        return 1
    elif [ "$usage_percentage" -gt 80 ]; then
        log "WARN" "Memory usage high: ${usage_percentage}%"
        return 0
    else
        log "INFO" "Memory usage normal: ${usage_percentage}%"
        return 0
    fi
}

# Display system information
display_system_info() {
    log "INFO" "System Health Check Report"
    log "INFO" "Hostname: $(hostname)"
    log "INFO" "Date: $(date)"
    log "INFO" "Uptime: $(uptime -p)"
}

# Main function
main() {
    local exit_code=0
    
    display_system_info
    echo
    
    if ! check_zombie_processes; then
        exit_code=1
    fi
    
    echo
    
    if ! check_memory_usage; then
        exit_code=1
    fi
    
    echo
    if [ "$exit_code" -eq 0 ]; then
        log "INFO" "System health check completed successfully"
    else
        log "WARN" "System health check completed with warnings/errors"
    fi
    
    exit $exit_code
}

# Script execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi