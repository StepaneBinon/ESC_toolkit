#!/bin/bash

# ============================================================================
# BOX RENDERER
# Core utilities for drawing ASCII boxes
# ============================================================================

# Draw top border
box_top() {
    echo "┌──────────────────────────────────────────────────────────┐"
}

# Draw bottom border
box_bottom() {
    echo "└──────────────────────────────────────────────────────────┘"
}

# Draw separator line
box_separator() {
    echo "├──────────────────────────────────────────────────────────┤"
}

# Draw title line (centered)
box_title() {
    local title="$1"
    printf "│ %-58s │\n" "$title"
}

# Draw data line
box_line() {
    local content="$1"
    printf "│ %-58s │\n" "$content"
}

# Draw empty line
box_empty() {
    echo "│                                                          │"
}