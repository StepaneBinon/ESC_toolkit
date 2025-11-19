#!/bin/bash

# ============================================================================
# LAYOUT MANAGER
# Handles horizontal and vertical box concatenation
# ============================================================================

# Concatenate boxes horizontally (side by side)
concat_horizontal() {
    # Store all function names passed as arguments
    local funcs=("$@")
    local num_boxes=${#funcs[@]}
    
    # Generate all boxes and store in arrays
    local max_lines=0
    
    for ((box_idx=0; box_idx<num_boxes; box_idx++)); do
        local func="${funcs[$box_idx]}"
        mapfile -t "box_${box_idx}_lines" < <($func)
        
        # Get reference to array
        local -n current_box="box_${box_idx}_lines"
        if [ ${#current_box[@]} -gt $max_lines ]; then
            max_lines=${#current_box[@]}
        fi
    done
    
    # Generate padding line (BOX_WIDTH spaces)
    local empty_line=$(printf "%${BOX_WIDTH}s" "")
    
    # Print line by line from all boxes
    for ((line_num=0; line_num<max_lines; line_num++)); do
        local output_line=""
        
        for ((box_idx=0; box_idx<num_boxes; box_idx++)); do
            local -n current_box="box_${box_idx}_lines"
            local line="${current_box[$line_num]}"
            
            # If line is empty or doesn't exist, use padding
            if [ -z "$line" ]; then
                line="$empty_line"
            fi
            
            # Add space separator between boxes (except for first box)
            if [ $box_idx -gt 0 ]; then
                output_line="$output_line "
            fi
            
            output_line="$output_line$line"
        done
        
        echo "$output_line"
    done
}

# Concatenate boxes vertically (one after another)
concat_vertical() {
    for func in "$@"; do
        $func
        echo ""
    done
}