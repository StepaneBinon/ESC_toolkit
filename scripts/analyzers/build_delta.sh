#!/bin/bash

# ============================================================================
# BUILD DELTA ANALYZER
# Tracks changes between builds and maintains history
# ============================================================================

load_previous_build() {
    # Requires: HISTORY_FILE
    
    export PREV_FLASH=0
    export PREV_RAM=0
    export FLASH_DELTA=0
    export RAM_DELTA=0
    
    if [ -f "$HISTORY_FILE" ]; then
        PREV_FLASH=$(grep "^FLASH:" "$HISTORY_FILE" | tail -1 | cut -d: -f2)
        PREV_RAM=$(grep "^RAM:" "$HISTORY_FILE" | tail -1 | cut -d: -f2)
        
        FLASH_DELTA=$((FLASH_USED - PREV_FLASH))
        RAM_DELTA=$((RAM_USED - PREV_RAM))
    fi
    
    return 0
}

save_current_build() {
    # Requires: HISTORY_FILE, FLASH_USED, RAM_USED, MAX_HISTORY_ENTRIES
    
    # Append current build
    echo "FLASH:$FLASH_USED" >> "$HISTORY_FILE"
    echo "RAM:$RAM_USED" >> "$HISTORY_FILE"
    
    # Keep only last N builds (each build = 2 lines)
    local max_lines=$((MAX_HISTORY_ENTRIES * 2))
    tail -n "$max_lines" "$HISTORY_FILE" > "${HISTORY_FILE}.tmp" && mv "${HISTORY_FILE}.tmp" "$HISTORY_FILE"
    
    return 0
}