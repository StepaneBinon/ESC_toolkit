#!/bin/bash

# ============================================================================
# METRICS BOX RENDERER
# Renders code metrics visualization
# ============================================================================

generate_code_metrics_box() {
    box_top
    printf "│                   CODE METRICS                           │\n"
    box_separator
    printf "│ Lines of Code (LOC):                                     │\n"
    printf "│   Total (with comments):     %6d lines                │\n" $LOC_TOTAL
    printf "│   Source only (SLOC):        %6d lines                │\n" $SLOC_TOTAL
    printf "│   Effective (ELOC):          %6d lines                │\n" $ELOC_TOTAL
    
    if [ $USER_FUNCTIONS -gt 0 ]; then
        local avg_eloc=$(echo "scale=1; $ELOC_TOTAL / $USER_FUNCTIONS" | bc)
        printf "│   ELOC per function:         %6.1f lines (avg)          │\n" $avg_eloc
    else
        printf "│   ELOC per function:            N/A                     │\n"
    fi
    
    printf "│   ELOC range:                %3d - %3d lines             │\n" $ELOC_MIN $ELOC_MAX
    box_separator
    printf "│ Functions:                   %3d total                   │\n" $TOTAL_FUNCTIONS
    printf "│   User functions:            %3d                         │\n" $USER_FUNCTIONS
    printf "│   Code density:              %4d bytes/function (user)  │\n" $CODE_DENSITY
    box_bottom
}