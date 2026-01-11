#!/bin/bash

# ============================================================================
# MEMORY LAYOUT COLLECTOR
# Extracts detailed memory layout: symbols, parameters, functions
# ============================================================================

collect_memory_layout() {
    local elf_file=$1
    local map_file="${elf_file%.elf}.map"
    
    # Arrays to store section details
    export -a DATA_SYMBOLS=()
    export -a BSS_SYMBOLS=()
    export -a RODATA_SYMBOLS=()
    export -a TEXT_SYMBOLS=()
    
    # Extract .data section symbols with addresses and sizes
    if [ -f "$map_file" ]; then
        # Parse .data section from map file
        DATA_SECTION=$(awk '/^\.data\s+0x/ {flag=1; print; next} /^\./ && flag {exit} flag' "$map_file")
        
        # Parse individual data symbols
        while IFS= read -r line; do
            if echo "$line" | grep -qE "^\s+0x[0-9a-f]+\s+0x[0-9a-f]+\s+"; then
                local addr=$(echo "$line" | awk '{print $1}')
                local size=$(echo "$line" | awk '{print $2}')
                local symbol=$(echo "$line" | awk '{print $3}')
                
                # Filter out linker symbols and ensure valid hex values
                if [ -n "$symbol" ] && [ "$size" != "0x0" ] && \
                   ! echo "$symbol" | grep -qE "^(_s|_e|\.)" && \
                   ! echo "$symbol" | grep -qE "CMakeFiles|build/" && \
                   echo "$size" | grep -qE "^0x[0-9a-fA-F]+$"; then
                    DATA_SYMBOLS+=("$addr|$size|$symbol")
                fi
            fi
        done <<< "$DATA_SECTION"
        
        # Parse .bss section
        BSS_SECTION=$(awk '/^\.bss\s+0x/ {flag=1; print; next} /^\./ && flag {exit} flag' "$map_file")
        
        while IFS= read -r line; do
            if echo "$line" | grep -qE "^\s+0x[0-9a-f]+\s+0x[0-9a-f]+\s+"; then
                local addr=$(echo "$line" | awk '{print $1}')
                local size=$(echo "$line" | awk '{print $2}')
                local symbol=$(echo "$line" | awk '{print $3}')
                
                # Filter out linker symbols and ensure valid hex values
                if [ -n "$symbol" ] && [ "$size" != "0x0" ] && \
                   ! echo "$symbol" | grep -qE "^(_s|_e|\.)" && \
                   ! echo "$symbol" | grep -qE "CMakeFiles|build/" && \
                   echo "$size" | grep -qE "^0x[0-9a-fA-F]+$"; then
                    BSS_SYMBOLS+=("$addr|$size|$symbol")
                fi
            fi
        done <<< "$BSS_SECTION"
    fi
    
    # Extract function information from ELF using nm
    # Format: address type name
    export FUNCTION_LIST=$(arm-none-eabi-nm -S -n --size-sort "$elf_file" | grep " [Tt] " | grep -v "STM32CubeG4")
    
    # Extract top functions by size
    export TOP_FUNCTIONS=$(arm-none-eabi-nm -S --size-sort "$elf_file" | grep " [Tt] " | grep -v "STM32CubeG4" | tail -10 | tac)
    
    # Extract parameter information from DWARF debug info if available
    # This requires debug symbols to be present
    if command -v arm-none-eabi-readelf &> /dev/null; then
        # Get section headers
        export SECTION_HEADERS=$(arm-none-eabi-readelf -S "$elf_file")
        
        # Get symbol table with sizes
        export SYMBOL_TABLE=$(arm-none-eabi-readelf -s "$elf_file")
    fi
    
    # Count important metrics
    export DATA_SYMBOL_COUNT=${#DATA_SYMBOLS[@]}
    export BSS_SYMBOL_COUNT=${#BSS_SYMBOLS[@]}
    
    return 0
}

# Helper function to format size from hex to decimal
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

# Helper to extract section details
get_section_info() {
    local section_name=$1
    local elf_file=$2
    
    arm-none-eabi-readelf -S "$elf_file" | grep "$section_name" | awk '{print $3, $4, $5}'
}