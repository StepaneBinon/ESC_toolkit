#!/bin/bash

# ============================================================================
# RAM BOX RENDERER
# Renders RAM memory usage visualization
# ============================================================================

generate_ram_box() {
    box_top
    printf "│                    RAM USAGE (32 KB)                     │\n"
    box_separator
    printf "│ Used: %6d bytes (%2d%%)   Free: %6d bytes            │\n" $RAM_USED $RAM_PERCENT $RAM_FREE
    
    if [ $PREV_RAM -ne 0 ]; then
        local delta_str=$(format_delta $RAM_DELTA)
        printf "│ Delta: %7s bytes (from previous build)               │\n" "$delta_str"
    fi
    
    box_separator
    printf "│ 0x20000000 ┌───────────┐                                 │\n"
    printf "│            │   .data   │ Init data: %5d bytes          │\n" $DATA
    printf "│ 0x%08x ├───────────┤                                 │\n" $DATA_END
    printf "│            │   .bss    │ Zero data: %5d bytes          │\n" $BSS
    printf "│ 0x%08x ├───────────┤                                 │\n" $BSS_END
    printf "│            │   HEAP    │ Alloc: %4d bytes (%d calls)     │\n" $HEAP_SIZE_DEC $MALLOC_CALLS
    printf "│ 0x%08x ├───────────┤                                 │\n" $HEAP_END
    printf "│            │   STACK   │ Size: %4d  Used: %4d (%2d%%)    │\n" $STACK_SIZE_DEC $STACK_USED $STACK_PERCENT
    printf "│ 0x%08x └───────────┘                                 │\n" $STACK_END
    printf "│            │   FREE    │                                 │\n"
    printf "│ 0x20008000 └───────────┘                                 │\n"
    
    if [ -n "$STACK_WARNING" ]; then
        box_separator
        printf "│ %-58s │\n" "$STACK_WARNING"
    fi
    
    box_separator
    printf "│ Top 3 Stack Consumers (STM32 HAL excluded):              │\n"
    
    if [ -n "$LARGEST_FUNCS" ]; then
        while IFS= read -r line; do
            local func_name=$(echo "$line" | awk -F: '{print $4}' | awk '{print $1}' | cut -c1-28)
            local stack_size=$(echo "$line" | awk '{print $2}')
            printf "│  %-30s %6d bytes             │\n" "$func_name" $stack_size
        done <<< "$LARGEST_FUNCS"
    else
        printf "│  (none found)                                            │\n"
    fi
    
    box_bottom
}