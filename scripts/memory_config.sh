#!/bin/bash

# ============================================================================
# MEMORY CONFIGURATION
# Hardware-specific memory constants and file paths
# ============================================================================

# Memory sizes (in bytes)
export FLASH_TOTAL=131072      # 128 KB
export RAM_TOTAL=32768         # 32 KB
export VECTOR_SIZE=512         # Vector table size in bytes

# Memory addresses
export FLASH_BASE=0x08000000
export FLASH_END=0x0801FFFF
export RAM_BASE=0x20000000
export RAM_END=0x20008000

# Box rendering
export BOX_WIDTH=60            # Width of each box INCLUDING borders

# File paths
export HISTORY_FILE="../.build_history"
export STARTUP_FILE="../STM32CubeG4/Drivers/CMSIS/Device/ST/STM32G4xx/Source/Templates/gcc/startup_stm32g431xx.s"

# Search paths
export SOURCE_DIRS=".."
export EXCLUDE_DIRS="STM32CubeG4 build"

# History management
export MAX_HISTORY_ENTRIES=10  # Keep last 10 builds (20 lines: FLASH + RAM per build)