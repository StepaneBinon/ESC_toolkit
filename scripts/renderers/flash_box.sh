#!/bin/bash

# ============================================================================
# FLASH BOX RENDERER
# Renders FLASH memory usage visualization
# ============================================================================

generate_flash_box() {
    box_top
    printf "│              FLASH USAGE (128 KB)                        │\n"
    box_separator
    printf "│ Used: %6d bytes (%2d%%)   Free: %6d bytes            │\n" $FLASH_USED $FLASH_PERCENT $FLASH_FREE
    
    if [ $PREV_FLASH -ne 0 ]; then
        local delta_str=$(format_delta $FLASH_DELTA)
        printf "│ Delta: %7s bytes (from previous build)               │\n" "$delta_str"
    fi
    
    box_separator
    printf "│ 0x08000000 ┌───────────┐                                 │\n"
    printf "│            │  .isr_vec │ Vectors: %4d bytes             │\n" $VECTOR_SIZE
    printf "│ 0x%08x ├───────────┤                                 │\n" $VECTOR_END
    printf "│            │   .text   │ Code: %6d bytes              │\n" $CODE_SIZE
    printf "│            │  .rodata  │ Const: (included)               │\n"
    printf "│ 0x%08x └───────────┘                                 │\n" $FLASH_END
    printf "│            │   FREE    │                                 │\n"
    printf "│ 0x0801FFFF └───────────┘                                 │\n"
    box_bottom
}