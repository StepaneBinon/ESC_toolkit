#!/bin/bash

# ============================================================================
# CONFIGURATION VARIABLES
# ============================================================================
FLASH_TOTAL=131072      # 128 KB
RAM_TOTAL=32768         # 32 KB
VECTOR_SIZE=512         # Vector table size in bytes
BOX_WIDTH=60            # Width of each box INCLUDING borders (┌─┐│)

ELF_FILE=$1
LAYOUT=${2:-vertical}  # Default to vertical, can be "vertical" or "horizontal"
HISTORY_FILE="../.build_history"

# Get size data
SIZE_OUTPUT=$(arm-none-eabi-size $ELF_FILE)
TEXT=$(echo "$SIZE_OUTPUT" | tail -1 | awk '{print $1}')
DATA=$(echo "$SIZE_OUTPUT" | tail -1 | awk '{print $2}')
BSS=$(echo "$SIZE_OUTPUT" | tail -1 | awk '{print $3}')

# FLASH calculations
FLASH_USED=$((TEXT + DATA))
FLASH_FREE=$((FLASH_TOTAL - FLASH_USED))
FLASH_PERCENT=$((FLASH_USED * 100 / FLASH_TOTAL))
FLASH_END=$((0x08000000 + FLASH_USED))

# RAM calculations
DATA_BSS=$((DATA + BSS))

# Heap/Stack from linker script
HEAP_SIZE=$(grep -A 1 "_heap_start" ../linker_minimal.ld | grep "\. = \. +" | grep -oE "0x[0-9a-fA-F]+" | head -1)
HEAP_SIZE_DEC=$((HEAP_SIZE))

STACK_SIZE=$(grep -A 1 "_stack_start" ../linker_minimal.ld | grep "\. = \. +" | grep -oE "0x[0-9a-fA-F]+" | head -1)
STACK_SIZE_DEC=$((STACK_SIZE))

# Stack usage analysis
STACK_USED=$(find . -name "*.su" ! -path "*/STM32CubeG4/*" -exec awk '{sum+=$2} END {print sum}' {} + 2>/dev/null)
STACK_USED=${STACK_USED:-0}
STACK_FREE=$((STACK_SIZE_DEC - STACK_USED))
STACK_PERCENT=$((STACK_USED * 100 / STACK_SIZE_DEC))

# Dynamic allocation check
MALLOC_CALLS=$(grep -rE "\b(malloc|calloc|realloc|new)\s*\(" ../*.cpp ../*.c 2>/dev/null | wc -l)

# RAM addresses
RAM_START=0x20000000
DATA_END=$((RAM_START + DATA))
BSS_END=$((DATA_END + BSS))
HEAP_START=$BSS_END
HEAP_END=$((HEAP_START + HEAP_SIZE_DEC))
STACK_START=$HEAP_END
STACK_END=$((RAM_START + RAM_TOTAL))

RAM_USED=$((DATA_BSS + HEAP_SIZE_DEC + STACK_SIZE_DEC))
RAM_FREE=$((RAM_TOTAL - RAM_USED))
RAM_PERCENT=$((RAM_USED * 100 / RAM_TOTAL))

# Largest stack functions
LARGEST_FUNCS=$(find . -name "*.su" ! -path "*/STM32CubeG4/*" -exec cat {} \; 2>/dev/null | sort -k2 -n -r | head -3)

# Get vector table size and code size
CODE_SIZE=$((TEXT - VECTOR_SIZE))
VECTOR_END=$((0x08000000 + VECTOR_SIZE))

# Build delta tracking
PREV_FLASH=0
PREV_RAM=0
FLASH_DELTA=0
RAM_DELTA=0

if [ -f "$HISTORY_FILE" ]; then
    PREV_FLASH=$(grep "^FLASH:" "$HISTORY_FILE" | tail -1 | cut -d: -f2)
    PREV_RAM=$(grep "^RAM:" "$HISTORY_FILE" | tail -1 | cut -d: -f2)
    FLASH_DELTA=$((FLASH_USED - PREV_FLASH))
    RAM_DELTA=$((RAM_USED - PREV_RAM))
fi

# Save current build
echo "FLASH:$FLASH_USED" >> "$HISTORY_FILE"
echo "RAM:$RAM_USED" >> "$HISTORY_FILE"

# Keep only last 10 builds
tail -20 "$HISTORY_FILE" > "${HISTORY_FILE}.tmp" && mv "${HISTORY_FILE}.tmp" "$HISTORY_FILE"

# Format delta
format_delta() {
    local delta=$1
    if [ $delta -gt 0 ]; then
        echo "+$delta"
    elif [ $delta -lt 0 ]; then
        echo "$delta"
    else
        echo "0"
    fi
}

FLASH_DELTA_STR=$(format_delta $FLASH_DELTA)
RAM_DELTA_STR=$(format_delta $RAM_DELTA)

# Interrupt vector analysis
STARTUP_FILE="../STM32CubeG4/Drivers/CMSIS/Device/ST/STM32G4xx/Source/Templates/gcc/startup_stm32g431xx.s"
TOTAL_VECTORS=$(grep -c "\.word" "$STARTUP_FILE" 2>/dev/null || echo "0")
CUSTOM_HANDLERS=$(arm-none-eabi-nm $ELF_FILE | grep -v " [Uw] " | grep -E "_IRQHandler|_Handler" | grep -v "Default_Handler\|Reset_Handler" | wc -l)

# Linker garbage collection effectiveness
MAP_FILE="${ELF_FILE%.elf}.map"
if [ -f "$MAP_FILE" ]; then
    REMOVED_SECTIONS=$(grep "Discarded input sections" "$MAP_FILE" -A 1000 | grep "\.text\." | wc -l)
else
    REMOVED_SECTIONS=0
fi

# Dead code detection (functions in binary)
TOTAL_FUNCTIONS=$(arm-none-eabi-nm $ELF_FILE | grep " [Tt] " | wc -l)
USER_FUNCTIONS=$(arm-none-eabi-nm $ELF_FILE | grep " [Tt] " | grep -v "STM32CubeG4" | wc -l)

# Code density (bytes per user function)
if [ $USER_FUNCTIONS -gt 0 ]; then
    CODE_DENSITY=$((CODE_SIZE / USER_FUNCTIONS))
else
    CODE_DENSITY=0
fi

# Lines of Code metrics (exclude HAL/CMSIS, comments, blanks)
LOC_TOTAL=0
SLOC_TOTAL=0
ELOC_TOTAL=0
ELOC_MAX=0
ELOC_MIN=999999

for file in $(find .. -name "*.c" -o -name "*.cpp" -o -name "*.h" -o -name "*.hpp" | grep -v "STM32CubeG4" | grep -v "build"); do
    FILE_SLOC=$(grep -v "^\s*$" "$file" | grep -v "^\s*//" | grep -v "^\s*/\*" | grep -v "^\s*\*" | wc -l)
    SLOC_TOTAL=$((SLOC_TOTAL + FILE_SLOC))
    
    FILE_LOC=$(wc -l < "$file")
    LOC_TOTAL=$((LOC_TOTAL + FILE_LOC))
done

for file in $(find .. -name "*.c" -o -name "*.cpp" | grep -v "STM32CubeG4" | grep -v "build"); do
    FUNC_LINES=$(awk '/^[^ \t].*\{/{flag=1; next} /^\}/{flag=0} flag && !/^\s*$/ && !/^\s*\/\// && !/^\s*\/\*/ && !/^\s*\*/' "$file" | wc -l)
    ELOC_TOTAL=$((ELOC_TOTAL + FUNC_LINES))
    
    if [ $FUNC_LINES -gt 0 ]; then
        if [ $FUNC_LINES -gt $ELOC_MAX ]; then
            ELOC_MAX=$FUNC_LINES
        fi
        if [ $FUNC_LINES -lt $ELOC_MIN ]; then
            ELOC_MIN=$FUNC_LINES
        fi
    fi
done

if [ $ELOC_MIN -eq 999999 ]; then
    ELOC_MIN=0
fi

# Stack warning check
STACK_WARNING=""
if [ $STACK_PERCENT -gt 75 ]; then
    STACK_WARNING="⚠ CRITICAL: Stack usage >75%!"
elif [ $STACK_PERCENT -gt 50 ]; then
    STACK_WARNING="⚠ WARNING: Stack usage >50%"
fi

# ============================================================================
# BOX GENERATION FUNCTIONS
# ============================================================================

# Generate FLASH usage box (returns array of lines)
generate_flash_box() {
    echo "┌──────────────────────────────────────────────────────────┐"
    echo "│              FLASH USAGE (128 KB)                        │"
    echo "├──────────────────────────────────────────────────────────┤"
    printf "│ Used: %6d bytes (%2d%%)   Free: %6d bytes            │\n" $FLASH_USED $FLASH_PERCENT $FLASH_FREE
    if [ $PREV_FLASH -ne 0 ]; then
        printf "│ Delta: %7s bytes (from previous build)               │\n" "$FLASH_DELTA_STR"
    fi
    echo "├──────────────────────────────────────────────────────────┤"
    echo "│ 0x08000000 ┌───────────┐                                 │"
    printf "│            │  .isr_vec │ Vectors: %4d bytes             │\n" $VECTOR_SIZE
    printf "│ 0x%08x ├───────────┤                                 │\n" $VECTOR_END
    printf "│            │   .text   │ Code: %6d bytes              │\n" $CODE_SIZE
    echo "│            │  .rodata  │ Const: (included)               │"
    printf "│ 0x%08x └───────────┘                                 │\n" $FLASH_END
    echo "│            │   FREE    │                                 │"
    echo "│ 0x0801FFFF └───────────┘                                 │"
    echo "└──────────────────────────────────────────────────────────┘"
}

# Generate RAM usage box
generate_ram_box() {
    echo "┌──────────────────────────────────────────────────────────┐"
    echo "│                    RAM USAGE (32 KB)                     │"
    echo "├──────────────────────────────────────────────────────────┤"
    printf "│ Used: %6d bytes (%2d%%)   Free: %6d bytes            │\n" $RAM_USED $RAM_PERCENT $RAM_FREE
    if [ $PREV_RAM -ne 0 ]; then
        printf "│ Delta: %7s bytes (from previous build)               │\n" "$RAM_DELTA_STR"
    fi
    echo "├──────────────────────────────────────────────────────────┤"
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
        echo "├──────────────────────────────────────────────────────────┤"
        printf "│ %-58s │\n" "$STACK_WARNING"
    fi
    
    echo "├──────────────────────────────────────────────────────────┤"
    echo "│ Top 3 Stack Consumers (STM32 Hal excluded):              │"
    
    if [ -n "$LARGEST_FUNCS" ]; then
        while IFS= read -r line; do
            FUNC_NAME=$(echo "$line" | awk -F: '{print $4}' | awk '{print $1}' | cut -c1-28)
            STACK_SIZE=$(echo "$line" | awk '{print $2}')
            printf "│  %-30s %6d bytes             │\n" "$FUNC_NAME" $STACK_SIZE
        done <<< "$LARGEST_FUNCS"
    else
        printf "│  (none found)                                            │\n"
    fi
    
    echo "└──────────────────────────────────────────────────────────┘"
}

# Generate code metrics box
generate_code_metrics_box() {
    echo "┌──────────────────────────────────────────────────────────┐"
    echo "│                   CODE METRICS                           │"
    echo "├──────────────────────────────────────────────────────────┤"
    printf "│ Lines of Code (LOC):                                     │\n"
    printf "│   Total (with comments):     %6d lines                │\n" $LOC_TOTAL
    printf "│   Source only (SLOC):        %6d lines                │\n" $SLOC_TOTAL
    printf "│   Effective (ELOC):          %6d lines                │\n" $ELOC_TOTAL
    printf "│   ELOC per function:         %6.1f lines (avg)          │\n" $(echo "scale=1; $ELOC_TOTAL / $USER_FUNCTIONS" | bc)
    printf "│   ELOC range:                %3d - %3d lines             │\n" $ELOC_MIN $ELOC_MAX
    echo "├──────────────────────────────────────────────────────────┤"
    printf "│ Functions:                   %3d total                   │\n" $TOTAL_FUNCTIONS
    printf "│   User functions:            %3d                         │\n" $USER_FUNCTIONS
    printf "│   Code density:              %4d bytes/function (user)  │\n" $CODE_DENSITY
    echo "└──────────────────────────────────────────────────────────┘"
}

# Generate code analysis box
generate_code_analysis_box() {
    echo "┌──────────────────────────────────────────────────────────┐"
    echo "│                   CODE ANALYSIS                          │"
    echo "├──────────────────────────────────────────────────────────┤"
    printf "│ Interrupt Vectors:                                       │\n"
    printf "│   Total vectors:        %3d                              │\n" $TOTAL_VECTORS
    printf "│   Custom handlers:      %3d                              │\n" $CUSTOM_HANDLERS
    printf "│   Default handlers:     %3d                              │\n" $((TOTAL_VECTORS - CUSTOM_HANDLERS))
    echo "├──────────────────────────────────────────────────────────┤"
    printf "│ Functions in Binary:                                     │\n"
    printf "│   Total functions:      %3d                              │\n" $TOTAL_FUNCTIONS
    printf "│   User functions:       %3d                              │\n" $USER_FUNCTIONS
    printf "│   HAL/CMSIS functions:  %3d                              │\n" $((TOTAL_FUNCTIONS - USER_FUNCTIONS))
    echo "├──────────────────────────────────────────────────────────┤"
    printf "│ Linker GC removed:      %3d sections                     │\n" $REMOVED_SECTIONS
    echo "└──────────────────────────────────────────────────────────┘"
}

# ============================================================================
# BOX CONCATENATION FUNCTIONS
# ============================================================================

# Concatenate boxes horizontally (side by side)
concat_horizontal() {
    # Store all function names passed as arguments
    local funcs=("$@")
    local num_boxes=${#funcs[@]}
    
    # Generate all boxes and store in arrays
    local -a all_box_lines
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

# ============================================================================
# MAIN LAYOUT GENERATION
# ============================================================================

# Display based on layout choice
if [ "$LAYOUT" = "horizontal" ]; then
    # All boxes side by side (requires ~250 char wide terminal for 4 boxes)
    concat_horizontal generate_flash_box generate_ram_box generate_code_metrics_box generate_code_analysis_box
else
    # All vertical
    concat_vertical generate_flash_box generate_ram_box generate_code_metrics_box generate_code_analysis_box
fi