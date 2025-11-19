# Memory Report System

A modular bash script system for analyzing STM32 embedded firmware memory usage, code metrics, and build statistics.

## Overview

This system provides comprehensive analysis of:
- **FLASH Memory**: Usage breakdown, vector table, code sections
- **RAM Memory**: Data/BSS/Heap/Stack allocation with address mapping
- **Stack Analysis**: Usage tracking, top consumers, warning thresholds
- **Code Metrics**: Lines of code (LOC, SLOC, ELOC), function counts
- **Code Analysis**: Interrupt vectors, linker optimizations, dead code detection
- **Build Tracking**: Delta comparison between builds

## Directory Structure

```
scripts/
├── memory_report.sh              # Main orchestrator
├── memory_config.sh              # Hardware configuration
├── collectors/                   # Data collection modules
│   ├── size_collector.sh         # Extract ELF size data
│   ├── flash_collector.sh        # FLASH calculations
│   ├── ram_collector.sh          # RAM calculations
│   ├── stack_collector.sh        # Stack usage analysis
│   ├── code_metrics_collector.sh # LOC/SLOC/ELOC metrics
│   └── code_analysis_collector.sh # Vectors, functions, GC stats
├── analyzers/                    # Data analysis modules
│   ├── build_delta.sh            # Build-to-build tracking
│   └── stack_analyzer.sh         # Stack warnings
├── renderers/                    # Visualization modules
│   ├── box_renderer.sh           # Core box drawing
│   ├── flash_box.sh              # FLASH visualization
│   ├── ram_box.sh                # RAM visualization
│   ├── metrics_box.sh            # Code metrics display
│   └── analysis_box.sh           # Code analysis display
├── utils/                        # Helper utilities
│   ├── formatters.sh             # Number/delta formatting
│   └── layout.sh                 # Horizontal/vertical layout
└── README.md                     # This file
```

## Usage

### Basic Usage

```bash
# From CMakeLists.txt post-build step:
bash scripts/memory_report.sh build/firmware.elf

# Direct invocation:
bash scripts/memory_report.sh path/to/firmware.elf [layout]
```

### Layout Options

**Vertical Layout** (default):
```bash
bash scripts/memory_report.sh firmware.elf vertical
```
Displays all boxes stacked vertically. Best for standard terminal widths (80+ chars).

**Horizontal Layout**:
```bash
bash scripts/memory_report.sh firmware.elf horizontal
```
Displays all boxes side-by-side. Requires wide terminal (250+ chars).

### CMakeLists.txt Integration

```cmake
add_custom_command(
    TARGET ${PROJECT_NAME}.elf POST_BUILD
    COMMAND bash ${CMAKE_SOURCE_DIR}/scripts/memory_report.sh 
            $<TARGET_FILE:${PROJECT_NAME}.elf> vertical
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
    COMMENT "Generating memory report"
)
```

## Configuration

Edit `memory_config.sh` to customize:

```bash
# Memory sizes (bytes)
FLASH_TOTAL=131072      # 128 KB
RAM_TOTAL=32768         # 32 KB
VECTOR_SIZE=512         # Vector table size

# Memory addresses
FLASH_BASE=0x08000000
RAM_BASE=0x20000000

# File paths
HISTORY_FILE="../.build_history"
STARTUP_FILE="../path/to/startup.s"

# Display
BOX_WIDTH=60            # ASCII box width
```

## Requirements

### Tools
- `arm-none-eabi-size` - Extract section sizes from ELF
- `arm-none-eabi-nm` - Symbol table analysis
- `arm-none-eabi-objcopy` - Binary format conversion
- `bc` - Floating point calculations
- Standard Unix tools: `awk`, `grep`, `find`, `wc`

### Build System
- GCC with `-fstack-usage` flag enabled (generates .su files)
- Linker map file generation enabled
- Linker script with `_heap_start` and `_stack_start` symbols

## Features

### FLASH Analysis
- Total usage and free space
- Percentage utilization
- Vector table size
- Code section size
- Build-to-build delta tracking

### RAM Analysis
- `.data` (initialized data)
- `.bss` (zero-initialized data)
- Heap allocation size and malloc call count
- Stack size, usage, and percentage
- Memory address mapping
- Build-to-build delta tracking

### Stack Analysis
- Actual stack usage from .su files
- Top 3 stack-consuming functions
- Warning thresholds (50%, 75%)
- Excludes STM32 HAL functions

### Code Metrics
- **LOC** (Lines of Code): Total including comments
- **SLOC** (Source LOC): Excluding comments and blanks
- **ELOC** (Effective LOC): Executable code in function bodies
- ELOC per function (average)
- ELOC range (min-max)
- Function count (total and user-defined)
- Code density (bytes per function)

### Code Analysis
- Interrupt vector usage (total/custom/default)
- Function analysis (total/user/HAL-CMSIS)
- Linker garbage collection effectiveness
- Dead code detection

### Build Tracking
- Maintains `.build_history` file
- Tracks FLASH and RAM usage per build
- Shows delta from previous build
- Keeps last 10 builds

## Output Examples

### Vertical Layout
```
┌──────────────────────────────────────────────────────────┐
│              FLASH USAGE (128 KB)                        │
├──────────────────────────────────────────────────────────┤
│ Used:  12345 bytes (9%)   Free: 118727 bytes            │
│ Delta:    +256 bytes (from previous build)               │
├──────────────────────────────────────────────────────────┤
│ 0x08000000 ┌───────────┐                                 │
│            │  .isr_vec │ Vectors:  512 bytes             │
│ 0x08000200 ├───────────┤                                 │
│            │   .text   │ Code:  11833 bytes              │
│            │  .rodata  │ Const: (included)               │
│ 0x08003039 └───────────┘                                 │
│            │   FREE    │                                 │
│ 0x0801FFFF └───────────┘                                 │
└──────────────────────────────────────────────────────────┘
```

### Horizontal Layout
Displays all four boxes side-by-side (requires 250+ char terminal).

## Extending the System

### Adding a New Collector

1. Create `collectors/my_collector.sh`:
```bash
#!/bin/bash
collect_my_data() {
    # Collect data
    export MY_METRIC=$((some_calculation))
    return 0
}
```

2. Source in `memory_report.sh`:
```bash
source "$SCRIPT_DIR/collectors/my_collector.sh"
```

3. Call in data collection phase:
```bash
collect_my_data
```

### Adding a New Box

1. Create `renderers/my_box.sh`:
```bash
#!/bin/bash
generate_my_box() {
    box_top
    printf "│              MY BOX TITLE                                │\n"
    box_separator
    printf "│ My Metric: %6d                                        │\n" $MY_METRIC
    box_bottom
}
```

2. Source in `memory_report.sh`:
```bash
source "$SCRIPT_DIR/renderers/my_box.sh"
```

3. Add to layout:
```bash
concat_vertical generate_flash_box generate_ram_box generate_my_box
```

### Adding a New Analyzer

1. Create `analyzers/my_analyzer.sh`:
```bash
#!/bin/bash
analyze_my_data() {
    # Perform analysis
    export MY_RESULT=$((some_analysis))
    return 0
}
```

2. Source and call in analysis phase

## Troubleshooting

### "arm-none-eabi-size: command not found"
Install ARM GCC toolchain for your platform.

### "No .su files found"
Enable stack usage in CMakeLists.txt:
```cmake
add_compile_options(-fstack-usage)
```

### "Cannot extract heap/stack size"
Ensure linker script defines `_heap_start` and `_stack_start` with size allocations.

### Build history not tracking
Check that `HISTORY_FILE` path is writable and parent directory exists.

## License

Part of STM32 embedded firmware project toolchain.