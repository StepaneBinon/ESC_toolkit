#!/bin/bash

# ============================================================================
# ANALYSIS BOX RENDERER
# Renders code analysis visualization
# ============================================================================

generate_code_analysis_box() {
    box_top
    printf "│                   CODE ANALYSIS                          │\n"
    box_separator
    printf "│ Interrupt Vectors:                                       │\n"
    printf "│   Total vectors:        %3d                              │\n" $TOTAL_VECTORS
    printf "│   Custom handlers:      %3d                              │\n" $CUSTOM_HANDLERS
    printf "│   Default handlers:     %3d                              │\n" $((TOTAL_VECTORS - CUSTOM_HANDLERS))
    box_separator
    printf "│ Functions in Binary:                                     │\n"
    printf "│   Total functions:      %3d                              │\n" $TOTAL_FUNCTIONS
    printf "│   User functions:       %3d                              │\n" $USER_FUNCTIONS
    printf "│   HAL/CMSIS functions:  %3d                              │\n" $((TOTAL_FUNCTIONS - USER_FUNCTIONS))
    box_separator
    printf "│ Linker GC removed:      %3d sections                     │\n" $REMOVED_SECTIONS
    box_bottom
}