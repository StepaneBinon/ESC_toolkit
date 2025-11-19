#!/bin/bash

# ============================================================================
# RAM COLLECTOR
# Calculates RAM usage including heap and stack allocations from linker script
# ============================================================================

collect_ram_data() {
    # Requires: DATA, BSS, RAM_TOTAL, RAM_BASE
    
    # Data + BSS
    export DATA_BSS=$((DATA + BSS))
    
    # Extract heap size from linker script
    local heap_size_hex=$(grep -A 1 "_heap_start" ../linker_minimal.ld | grep "\. = \. +" | grep -oE "0x[0-9a-fA-F]+" | head -1)
    export HEAP_SIZE_DEC=$((heap_size_hex))
    
    # Extract stack size from linker script
    local stack_size_hex=$(grep -A 1 "_stack_start" ../linker_minimal.ld | grep "\. = \. +" | grep -oE "0x[0-9a-fA-F]+" | head -1)
    export STACK_SIZE_DEC=$((stack_size_hex))
    
    # Check for dynamic allocation calls
    export MALLOC_CALLS=$(grep -rE "\b(malloc|calloc|realloc|new)\s*\(" ../*.cpp ../*.c 2>/dev/null | wc -l)
    
    # Calculate RAM addresses
    export DATA_END=$((RAM_BASE + DATA))
    export BSS_END=$((DATA_END + BSS))
    export HEAP_START=$BSS_END
    export HEAP_END=$((HEAP_START + HEAP_SIZE_DEC))
    export STACK_START=$HEAP_END
    export STACK_END=$((RAM_BASE + RAM_TOTAL))
    
    # Total RAM usage
    export RAM_USED=$((DATA_BSS + HEAP_SIZE_DEC + STACK_SIZE_DEC))
    export RAM_FREE=$((RAM_TOTAL - RAM_USED))
    export RAM_PERCENT=$((RAM_USED * 100 / RAM_TOTAL))
    
    return 0
}