#!/bin/bash

# ============================================================================
# STACK ANALYZER
# Analyzes stack usage and generates warnings
# ============================================================================

analyze_stack_usage() {
    # Requires: STACK_PERCENT
    
    export STACK_WARNING=""
    
    if [ $STACK_PERCENT -gt 75 ]; then
        STACK_WARNING="⚠ CRITICAL: Stack usage >75%!"
    elif [ $STACK_PERCENT -gt 50 ]; then
        STACK_WARNING="⚠ WARNING: Stack usage >50%"
    fi
    
    return 0
}