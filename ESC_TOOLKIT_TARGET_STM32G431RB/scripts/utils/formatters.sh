#!/bin/bash

# ============================================================================
# FORMATTERS
# Utility functions for formatting numbers and deltas
# ============================================================================

format_delta() {
    local delta=$1
    
    if [ $delta -gt 0 ]; then
        echo "+$delta"
    elif [ $delta -lt 0 ]; then
        echo "$delta"
    else
        echo "0"
    fi
}

format_bytes() {
    local bytes=$1
    printf "%6d" "$bytes"
}

format_percent() {
    local percent=$1
    printf "%2d" "$percent"
}

format_hex() {
    local addr=$1
    printf "0x%08x" "$addr"
}