#!/bin/bash

# ============================================================================
# FLASH COLLECTOR
# Calculates FLASH memory usage, addresses, and breakdown
# ============================================================================

collect_flash_data() {
    # Requires: TEXT, DATA, VECTOR_SIZE, FLASH_TOTAL, FLASH_BASE
    
    # FLASH calculations
    export FLASH_USED=$((TEXT + DATA))
    export FLASH_FREE=$((FLASH_TOTAL - FLASH_USED))
    export FLASH_PERCENT=$((FLASH_USED * 100 / FLASH_TOTAL))
    export FLASH_END=$((FLASH_BASE + FLASH_USED))
    
    # Code section breakdown
    export CODE_SIZE=$((TEXT - VECTOR_SIZE))
    export VECTOR_END=$((FLASH_BASE + VECTOR_SIZE))
    
    return 0
}