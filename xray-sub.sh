#!/usr/bin/env bash
set -euo pipefail
# Script for managing Xray subscriptions
# Author: PooyaDustDar
# License: MIT

# Constants
DEFAULT_OUTPUT="/etc/xray/config.json"
LOG_FILE="/var/log/xray_sub.log"

# Function for logging
log() {
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $1" | tee -a "$LOG_FILE"
}

# Function to check required commands
check_requirements() {
    local requirements=("curl" "jq")
    for cmd in "${requirements[@]}"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            log "Error: Required command '$cmd' not found. Please install it first."
            exit 1
        fi
    done
}

# Function to display usage
usage() {
    cat << EOF
Usage: $(basename "$0") [-u URL] [-o OUTPUT_FILE]
Options:
    -u URL          Subscription URL
    -o OUTPUT_FILE  Output file path (default: $DEFAULT_OUTPUT)
    -h             Show this help message
EOF
    exit 1
}

# Function to validate URL
validate_url() {
    local url=$1
    if [[ ! $url =~ ^https?:// ]]; then
        log "Error: Invalid URL format"
        exit 1
    fi
}

# Function to validate JSON
validate_json() {
    local json=$1
    if ! echo "$json" | jq empty >/dev/null 2>&1; then
        log "Error: Invalid JSON received from subscription URL"
        exit 1
    fi
}

# Function to check write permissions
check_write_permission() {
    local output_file=$1
    local output_dir
    output_dir=$(dirname "$output_file")
    
    if [[ ! -w "$output_dir" ]]; then
        log "Error: No write permission for directory: $output_dir"
        exit 1
    fi
}

# Main function
main() {
    local url=""
    local output_file="$DEFAULT_OUTPUT"

    # Parse command line options
    while getopts ":u:o:h" opt; do
        case $opt in
            u)
                url="$OPTARG"
                ;;
            o)
                output_file="$OPTARG"
                ;;
            h)
                usage
                ;;
            \?)
                log "Error: Invalid option -$OPTARG"
                usage
                ;;
            :)
                log "Error: Option -$OPTARG requires an argument"
                usage
                ;;
        esac
    done

    # Check requirements first
    check_requirements

    # If URL is not provided, ask for it
    if [[ -z $url ]]; then
        echo "Please enter the JSON subscription URL:"
        read -r url
    fi

    # Validate URL
    validate_url "$url"

    # Check write permissions
    check_write_permission "$output_file"

    # Fetch subscription
    log "Fetching subscription from $url"
    local response
    response=$(curl -s -f "$url") || {
        log "Error: Failed to fetch subscription from $url"
        exit 1
    }

    # Validate JSON response
    validate_json "$response"

    # Display available configs
    echo "Available configurations:"
    echo "$response" | jq -r '.[].remarks' | nl -s' - ' -w1 -nln

    # Get user selection
    echo "Please select the configuration number:"
    local config_number
    read -r config_number

    # Validate input
    if ! [[ "$config_number" =~ ^[0-9]+$ ]]; then
        log "Error: Invalid input. Please enter a number."
        exit 1
    fi

    # Adjust for zero-based array index
    config_number=$((config_number - 1))

    # Get total number of configs
    local total_configs
    total_configs=$(echo "$response" | jq '. | length')

    # Validate selection
    if [ "$config_number" -lt 0 ] || [ "$config_number" -ge "$total_configs" ]; then
        log "Error: Invalid selection. Please choose a number between 1 and $total_configs"
        exit 1
    fi

    # Extract and save selected config
    log "Saving selected configuration to $output_file"
    echo "$response" | jq ".[$config_number]" > "$output_file"

    # Verify file was written
    if [[ -f "$output_file" ]]; then
        log "Configuration successfully saved to $output_file"
        # Restart Xray service if running as root
        if [[ $EUID -eq 0 ]] && systemctl is-active xray >/dev/null 2>&1; then
            log "Restarting Xray service..."
            systemctl restart xray
        fi
    else
        log "Error: Failed to write configuration file"
        exit 1
    fi
}

# Start script
main "$@"
