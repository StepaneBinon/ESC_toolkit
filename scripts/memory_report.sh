#!/bin/bash

# ============================================================================
# MEMORY REPORT - Main Orchestrator
# Generates comprehensive memory and code analysis reports
# ============================================================================

set -e  # Exit on error

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ============================================================================
# PARSE ARGUMENTS
# ============================================================================
ELF_FILE=$1
LAYOUT=${2:-vertical}  # Default to vertical

if [ -z "$ELF_FILE" ]; then
    echo "Usage: $0 <elf_file> [layout]"
    echo "  layout: 'vertical' (default) or 'horizontal'"
    exit 1
fi

if [ ! -f "$ELF_FILE" ]; then
    echo "Error: ELF file not found: $ELF_FILE"
    exit 1
fi

# ============================================================================
# SOURCE ALL MODULES
# ============================================================================

# Configuration
source "$SCRIPT_DIR/memory_config.sh"

# Collectors
source "$SCRIPT_DIR/collectors/size_collector.sh"
source "$SCRIPT_DIR/collectors/flash_collector.sh"
source "$SCRIPT_DIR/collectors/ram_collector.sh"
source "$SCRIPT_DIR/collectors/stack_collector.sh"
source "$SCRIPT_DIR/collectors/code_metrics_collector.sh"
source "$SCRIPT_DIR/collectors/code_analysis_collector.sh"
source "$SCRIPT_DIR/collectors/memory_layout_collector.sh"

# Analyzers
source "$SCRIPT_DIR/analyzers/build_delta.sh"
source "$SCRIPT_DIR/analyzers/stack_analyzer.sh"

# Renderers
source "$SCRIPT_DIR/renderers/box_renderer.sh"
source "$SCRIPT_DIR/renderers/flash_box.sh"
source "$SCRIPT_DIR/renderers/ram_box.sh"
source "$SCRIPT_DIR/renderers/metrics_box.sh"
source "$SCRIPT_DIR/renderers/analysis_box.sh"
source "$SCRIPT_DIR/renderers/memory_layout_box.sh"

# Utils
source "$SCRIPT_DIR/utils/formatters.sh"
source "$SCRIPT_DIR/utils/layout.sh"

# ============================================================================
# DATA COLLECTION PHASE
# ============================================================================

# Collect all data
collect_size_data "$ELF_FILE"
collect_flash_data
collect_ram_data
collect_stack_data
collect_code_metrics
collect_code_analysis "$ELF_FILE"
collect_memory_layout "$ELF_FILE"

# ============================================================================
# ANALYSIS PHASE
# ============================================================================

load_previous_build
analyze_stack_usage
save_current_build

# ============================================================================
# RENDERING PHASE
# ============================================================================

if [ "$LAYOUT" = "horizontal" ]; then
    # All boxes side by side (requires ~250 char wide terminal for 4 boxes)
    concat_horizontal generate_flash_box generate_ram_box generate_code_metrics_box generate_code_analysis_box
    echo ""
    echo ""
    # Memory layout box shown separately due to its detail
    # generate_memory_layout_box
else
    # All vertical (default)
    concat_vertical generate_flash_box generate_ram_box generate_code_metrics_box generate_code_analysis_box generate_memory_layout_box
fi