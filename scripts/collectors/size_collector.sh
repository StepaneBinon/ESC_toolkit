#!/bin/bash

# ============================================================================
# SIZE COLLECTOR
# Extracts basic size information from ELF file using arm-none-eabi-size
# ============================================================================

collect_size_data() {
    local elf_file=$1
    
    if [ ! -f "$elf_file" ]; then
        echo "Error: ELF file not found: $elf_file" >&2
        return 1
    fi
    
    # Get size data from ELF file
    local size_output=$(arm-none-eabi-size "$elf_file")
    
    # Export section sizes
    export TEXT=$(echo "$size_output" | tail -1 | awk '{print $1}')
    export DATA=$(echo "$size_output" | tail -1 | awk '{print $2}')
    export BSS=$(echo "$size_output" | tail -1 | awk '{print $3}')
    
    # Validate data
    if [ -z "$TEXT" ] || [ -z "$DATA" ] || [ -z "$BSS" ]; then
        echo "Error: Failed to extract size data from ELF file" >&2
        return 1
    fi
    
    return 0
}