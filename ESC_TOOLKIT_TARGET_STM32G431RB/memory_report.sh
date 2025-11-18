#!/bin/bash

ELF_FILE=$1
HISTORY_FILE="../.build_history"

# Get size data
SIZE_OUTPUT=$(arm-none-eabi-size $ELF_FILE)
TEXT=$(echo "$SIZE_OUTPUT" | tail -1 | awk '{print $1}')
DATA=$(echo "$SIZE_OUTPUT" | tail -1 | awk '{print $2}')
BSS=$(echo "$SIZE_OUTPUT" | tail -1 | awk '{print $3}')

# FLASH calculations
FLASH_USED=$((TEXT + DATA))
FLASH_TOTAL=131072
FLASH_FREE=$((FLASH_TOTAL - FLASH_USED))
FLASH_PERCENT=$((FLASH_USED * 100 / FLASH_TOTAL))
FLASH_END=$((0x08000000 + FLASH_USED))

# RAM calculations
RAM_TOTAL=32768
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

# Get vector table size
VECTOR_SIZE=512
CODE_SIZE=$((TEXT - VECTOR_SIZE))
VECTOR_END=$((0x08000000 + VECTOR_SIZE))

# Build delta tracking
PREV_FLASH=0
PREV_RAM=0
FLASH_DELTA=0
RAM_DELTA=0
DELTA_SYMBOL=""

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

# Stack margin warning
STACK_WARNING=""
if [ $STACK_PERCENT -gt 75 ]; then
    STACK_WARNING="⚠ CRITICAL: Stack usage >75%!"
elif [ $STACK_PERCENT -gt 50 ]; then
    STACK_WARNING="⚠ WARNING: Stack usage >50%"
fi

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

echo   "┌──────────────────────────────────────────────────────────┐"
echo   "│                   FLASH USAGE (128 KB)                   │"
echo   "├──────────────────────────────────────────────────────────┤"
printf "│ Used: %6d bytes (%2d%%)   Free: %6d bytes            │\n" $FLASH_USED $FLASH_PERCENT $FLASH_FREE
if [ $PREV_FLASH -ne 0 ]; then
    printf "│ Delta: %7s bytes (from previous build)              │\n" "$FLASH_DELTA_STR"
fi
echo   "├──────────────────────────────────────────────────────────┤"
printf "│ 0x08000000 ┌───────────┐                                 │\n"
printf "│            │  .isr_vec │ Vectors: %4d bytes             │\n" $VECTOR_SIZE
printf "│ 0x%08x ├───────────┤                                 │\n" $VECTOR_END
printf "│            │   .text   │ Code: %6d bytes              │\n" $CODE_SIZE
printf "│            │  .rodata  │ Const: (included)               │\n"
printf "│ 0x%08x └───────────┘                                 │\n" $FLASH_END
printf "│            │   FREE    │                                 │\n"
printf "│ 0x0801FFFF └───────────┘                                 │\n"
echo   "└──────────────────────────────────────────────────────────┘"
echo ""
echo   "┌──────────────────────────────────────────────────────────┐"
echo   "│                    RAM USAGE (32 KB)                     │"
echo   "├──────────────────────────────────────────────────────────┤"
printf "│ Used: %6d bytes (%2d%%)   Free: %6d bytes            │\n" $RAM_USED $RAM_PERCENT $RAM_FREE
if [ $PREV_RAM -ne 0 ]; then
    printf "│ Delta: %7s bytes (from previous build)              │\n" "$RAM_DELTA_STR"
fi
echo   "├──────────────────────────────────────────────────────────┤"
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
    echo   "├──────────────────────────────────────────────────────────┤"
    printf "│ %-58s │\n" "$STACK_WARNING"
fi

echo   "├──────────────────────────────────────────────────────────┤"
echo   "│ Top 3 Stack Consumers (STM32 Hal excluded):              │"

if [ -n "$LARGEST_FUNCS" ]; then
    echo "$LARGEST_FUNCS" | while read line; do
        FUNC_NAME=$(echo "$line" | awk -F: '{print $4}' | awk '{print $1}' | cut -c1-28)
        STACK_SIZE=$(echo "$line" | awk '{print $2}')
        printf "│  %-30s %6d bytes             │\n" "$FUNC_NAME" $STACK_SIZE
    done
else
    printf "│  (none found)                                            │\n"
fi

echo "└──────────────────────────────────────────────────────────┘"
echo ""
echo   "┌──────────────────────────────────────────────────────────┐"
echo   "│                   CODE ANALYSIS                          │"
echo   "├──────────────────────────────────────────────────────────┤"
printf "│ Interrupt Vectors:                                       │\n"
printf "│   Total vectors:        %3d                              │\n" $TOTAL_VECTORS
printf "│   Custom handlers:      %3d                              │\n" $CUSTOM_HANDLERS
printf "│   Default handlers:     %3d                              │\n" $((TOTAL_VECTORS - CUSTOM_HANDLERS))
echo   "├──────────────────────────────────────────────────────────┤"
printf "│ Functions in Binary:                                     │\n"
printf "│   Total functions:      %3d                              │\n" $TOTAL_FUNCTIONS
printf "│   User functions:       %3d                              │\n" $USER_FUNCTIONS
printf "│   HAL/CMSIS functions:  %3d                              │\n" $((TOTAL_FUNCTIONS - USER_FUNCTIONS))
echo   "├──────────────────────────────────────────────────────────┤"
printf "│ Code Density:           %4d bytes/function (user)       │\n" $CODE_DENSITY
printf "│ Linker GC removed:      %3d sections                     │\n" $REMOVED_SECTIONS
echo   "└──────────────────────────────────────────────────────────┘"