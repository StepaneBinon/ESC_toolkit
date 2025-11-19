#!/bin/bash

# ============================================================================
# CODE METRICS COLLECTOR
# Calculates lines of code metrics (LOC, SLOC, ELOC)
# ============================================================================

collect_code_metrics() {
    # Initialize counters
    local loc_total=0
    local sloc_total=0
    local eloc_total=0
    local eloc_max=0
    local eloc_min=999999
    
    # Count total and source lines (LOC and SLOC)
    for file in $(find "$SOURCE_DIRS" -name "*.c" -o -name "*.cpp" -o -name "*.h" -o -name "*.hpp" | grep -v "STM32CubeG4" | grep -v "build"); do
        # Source lines only (no comments, no blanks)
        local file_sloc=$(grep -v "^\s*$" "$file" | grep -v "^\s*//" | grep -v "^\s*/\*" | grep -v "^\s*\*" | wc -l)
        sloc_total=$((sloc_total + file_sloc))
        
        # Total lines including comments
        local file_loc=$(wc -l < "$file")
        loc_total=$((loc_total + file_loc))
    done
    
    # Count effective lines (ELOC) - executable code in function bodies
    for file in $(find "$SOURCE_DIRS" -name "*.c" -o -name "*.cpp" | grep -v "STM32CubeG4" | grep -v "build"); do
        local func_lines=$(awk '/^[^ \t].*\{/{flag=1; next} /^\}/{flag=0} flag && !/^\s*$/ && !/^\s*\/\// && !/^\s*\/\*/ && !/^\s*\*/' "$file" | wc -l)
        eloc_total=$((eloc_total + func_lines))
        
        # Track min/max
        if [ $func_lines -gt 0 ]; then
            if [ $func_lines -gt $eloc_max ]; then
                eloc_max=$func_lines
            fi
            if [ $func_lines -lt $eloc_min ]; then
                eloc_min=$func_lines
            fi
        fi
    done
    
    # Handle edge case
    if [ $eloc_min -eq 999999 ]; then
        eloc_min=0
    fi
    
    # Export metrics
    export LOC_TOTAL=$loc_total
    export SLOC_TOTAL=$sloc_total
    export ELOC_TOTAL=$eloc_total
    export ELOC_MAX=$eloc_max
    export ELOC_MIN=$eloc_min
    
    return 0
}