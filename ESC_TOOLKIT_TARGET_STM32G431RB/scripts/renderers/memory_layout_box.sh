#!/bin/bash

# ============================================================================
# MEMORY LAYOUT BOX RENDERER
# Renders detailed memory layout with symbols, parameters, and functions
# ============================================================================

generate_memory_layout_box() {
    box_top
    printf "│              DETAILED MEMORY LAYOUT                      │\n"
    box_separator
    
    # FLASH Layout Section
    printf "│ FLASH MEMORY (0x%08x - 0x%08x)                │\n" $FLASH_BASE $((FLASH_BASE + FLASH_TOTAL - 1))
    box_separator
    
    printf "│ ┌─ 0x%08x  Vector Table (%d bytes)              │\n" $FLASH_BASE $VECTOR_SIZE
    printf "│ │                                                          │\n"
    printf "│ ├─ 0x%08x  .text (Code Section)                   │\n" $VECTOR_END
    
    # Show top 5 largest functions in FLASH
    if [ -n "$TOP_FUNCTIONS" ]; then
        printf "│ │  Top Functions by Size:                                │\n"
        local count=0
        while IFS= read -r line && [ $count -lt 5 ]; do
            local addr=$(echo "$line" | awk '{print $1}')
            local size=$(echo "$line" | awk '{print $2}')
            local name=$(echo "$line" | awk '{print $4}' | cut -c1-25)
            
            if [ -n "$name" ] && [ "$size" != "00000000" ]; then
                local size_dec=$((0x$size))
                printf "│ │   0x%s  %-25s %5d B │\n" "$addr" "$name" "$size_dec"
                count=$((count + 1))
            fi
        done <<< "$TOP_FUNCTIONS"
    fi
    
    printf "│ │                                                          │\n"
    printf "│ ├─ 0x%08x  .rodata (Constants)                    │\n" $FLASH_END
    printf "│ │  (Read-only data included in .text)                     │\n"
    printf "│ └─ 0x%08x  End of used FLASH                      │\n" $FLASH_END
    
    box_separator
    
    # RAM Layout Section
    printf "│ RAM MEMORY (0x%08x - 0x%08x)                  │\n" $RAM_BASE $((RAM_BASE + RAM_TOTAL - 1))
    box_separator
    
    printf "│ ┌─ 0x%08x  .data (Initialized Data)               │\n" $RAM_BASE
    
    # Show .data symbols (top 5 by size)
    if [ ${#DATA_SYMBOLS[@]} -gt 0 ]; then
        printf "│ │  Initialized Variables:                                │\n"
        local count=0
        for symbol_info in "${DATA_SYMBOLS[@]}"; do
            if [ $count -ge 5 ]; then break; fi
            
            IFS='|' read -r addr size name <<< "$symbol_info"
            local size_dec=$(hex_to_dec "$size")
            
            # Only display if conversion succeeded and size is valid
            if [ "$size_dec" -gt 0 ] 2>/dev/null; then
                printf "│ │   %s  %-25s %5d B │\n" "$addr" "${name:0:25}" "$size_dec"
                count=$((count + 1))
            fi
        done
        
        if [ $count -eq 0 ]; then
            printf "│ │   (No valid variables found)                            │\n"
        elif [ ${#DATA_SYMBOLS[@]} -gt 5 ]; then
            printf "│ │   ... and %d more variables                            │\n" $((DATA_SYMBOL_COUNT - count))
        fi
    else
        printf "│ │   (No variables found or map file unavailable)          │\n"
    fi
    
    printf "│ ├─ 0x%08x  .bss (Zero-initialized Data)           │\n" $DATA_END
    
    # Show .bss symbols (top 5 by size)
    if [ ${#BSS_SYMBOLS[@]} -gt 0 ]; then
        printf "│ │  Zero-init Variables:                                  │\n"
        local count=0
        for symbol_info in "${BSS_SYMBOLS[@]}"; do
            if [ $count -ge 5 ]; then break; fi
            
            IFS='|' read -r addr size name <<< "$symbol_info"
            local size_dec=$(hex_to_dec "$size")
            
            # Only display if conversion succeeded and size is valid
            if [ "$size_dec" -gt 0 ] 2>/dev/null; then
                printf "│ │   %s  %-25s %5d B │\n" "$addr" "${name:0:25}" "$size_dec"
                count=$((count + 1))
            fi
        done
        
        if [ $count -eq 0 ]; then
            printf "│ │   (No valid variables found)                            │\n"
        elif [ ${#BSS_SYMBOLS[@]} -gt 5 ]; then
            printf "│ │   ... and %d more variables                            │\n" $((BSS_SYMBOL_COUNT - count))
        fi
    else
        printf "│ │   (No variables found or map file unavailable)          │\n"
    fi
    
    printf "│ ├─ 0x%08x  HEAP (Dynamic Allocation)              │\n" $BSS_END
    printf "│ │  Size: %d bytes, Malloc calls: %d                     │\n" $HEAP_SIZE_DEC $MALLOC_CALLS
    
    printf "│ ├─ 0x%08x  STACK (Grows Downward)                 │\n" $HEAP_END
    printf "│ │  Size: %d bytes, Used: %d bytes (%d%%)                │\n" $STACK_SIZE_DEC $STACK_USED $STACK_PERCENT
    
    if [ -n "$LARGEST_FUNCS" ]; then
        printf "│ │  Stack Consumers:                                      │\n"
        local count=0
        while IFS= read -r line && [ $count -lt 3 ]; do
            local func_name=$(echo "$line" | awk -F: '{print $4}' | awk '{print $1}' | cut -c1-28)
            local stack_size=$(echo "$line" | awk '{print $2}')
            printf "│ │   %-30s %6d B │\n" "$func_name" $stack_size
            count=$((count + 1))
        done <<< "$LARGEST_FUNCS"
    fi
    
    printf "│ └─ 0x%08x  End of RAM                             │\n" $STACK_END
    
    box_separator
    printf "│ Summary:                                                 │\n"
    printf "│  Total RAM sections: .data(%d) + .bss(%d) + heap + stack  │\n" $DATA_SYMBOL_COUNT $BSS_SYMBOL_COUNT
    printf "│  Map file: %-46s │\n" "$([ -f "${ELF_FILE%.elf}.map" ] && echo "available" || echo "not found")"
    
    box_bottom
}