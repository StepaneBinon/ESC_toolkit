#!/bin/bash

# ============================================================================
# CODE ANALYSIS COLLECTOR
# Analyzes interrupt vectors, functions, and linker optimizations
# ============================================================================

collect_code_analysis() {
    local elf_file=$1
    
    # Interrupt vector analysis
    export TOTAL_VECTORS=$(grep -c "\.word" "$STARTUP_FILE" 2>/dev/null || echo "0")
    export CUSTOM_HANDLERS=$(arm-none-eabi-nm "$elf_file" | grep -v " [Uw] " | grep -E "_IRQHandler|_Handler" | grep -v "Default_Handler\|Reset_Handler" | wc -l)
    
    # Function count
    export TOTAL_FUNCTIONS=$(arm-none-eabi-nm "$elf_file" | grep " [Tt] " | wc -l)
    export USER_FUNCTIONS=$(arm-none-eabi-nm "$elf_file" | grep " [Tt] " | grep -v "STM32CubeG4" | wc -l)
    
    # Code density (bytes per user function)
    if [ $USER_FUNCTIONS -gt 0 ]; then
        export CODE_DENSITY=$((CODE_SIZE / USER_FUNCTIONS))
    else
        export CODE_DENSITY=0
    fi
    
    # Linker garbage collection effectiveness
    local map_file="${elf_file%.elf}.map"
    if [ -f "$map_file" ]; then
        export REMOVED_SECTIONS=$(grep "Discarded input sections" "$map_file" -A 1000 | grep "\.text\." | wc -l)
    else
        export REMOVED_SECTIONS=0
    fi
    
    return 0
}