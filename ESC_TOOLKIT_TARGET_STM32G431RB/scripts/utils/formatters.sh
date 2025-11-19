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

hex_to_dec() {
    local hex_val=$1
    
    # Validate hex input
    if ! echo "$hex_val" | grep -qE "^0x[0-9a-fA-F]+$"; then
        echo "0"
        return 1
    fi
    
    # Convert to decimal
    printf "%d" "$hex_val" 2>/dev/null || echo "0"
}