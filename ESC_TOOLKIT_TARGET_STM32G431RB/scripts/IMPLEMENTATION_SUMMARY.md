# Memory Layout Box - Implementation Summary

## ✅ What Was Added

### New Files Created:

1. **`collectors/memory_layout_collector.sh`**
   - Extracts detailed symbol information from ELF and map files
   - Parses .data and .bss sections for variables
   - Collects function information with sizes and addresses
   - Exports arrays of symbols with address|size|name format

2. **`renderers/memory_layout_box.sh`**
   - Renders complete memory layout visualization
   - Shows FLASH: Vector table → .text (top 5 functions) → .rodata
   - Shows RAM: .data (top 5 vars) → .bss (top 5 vars) → heap → stack
   - Displays exact addresses for all sections
   - Integrated with existing metrics (stack consumers, malloc calls)

3. **`MEMORY_LAYOUT_GUIDE.md`**
   - Comprehensive documentation
   - Explains what's shown and how to interpret it
   - Details requirements (map file)
   - Discusses parameter display (possible, not yet implemented)

### Modified Files:

1. **`memory_report.sh`**
   - Added sourcing of memory_layout_collector.sh
   - Added sourcing of memory_layout_box.sh
   - Added collect_memory_layout() call
   - Added generate_memory_layout_box() to both layouts
   - Memory layout box shown last (most detailed)

2. **`README.md`**
   - Updated feature list
   - Added memory layout section to features
   - Added example output
   - Added map file requirement
   - Updated directory structure

## 🎯 What It Displays

### Functions (FLASH Memory)
- ✅ Function names
- ✅ Addresses in FLASH
- ✅ Size in bytes
- ✅ Top 5 largest functions
- ❌ Parameters (not implemented - requires DWARF parsing)

### Variables (RAM Memory)
- ✅ Variable names
- ✅ Addresses in RAM (.data/.bss sections)
- ✅ Size in bytes
- ✅ Top 5 per section
- ❌ Local/stack variables (not implemented)

### Memory Layout
- ✅ Complete address map
- ✅ Section boundaries
- ✅ Heap/stack regions with usage
- ✅ Vector table location

## 📋 Requirements

### To See Functions & Variables:
- Valid ELF file (already required)
- Functions work without map file
- Variables require map file for full details

### To Generate Map File:
Add to CMakeLists.txt:
```cmake
target_link_options(${PROJECT_NAME}.elf PRIVATE
    -Wl,-Map=${PROJECT_NAME}.map
)
```

## 🔍 Technical Details

### Data Sources:
1. **ELF file** (`arm-none-eabi-nm`):
   - Function symbols and sizes
   - Global symbol table
   - Works always

2. **Map file** (`.map` from linker):
   - Detailed variable layout
   - Precise addresses
   - Section information
   - Optional but recommended

3. **Stack usage files** (`.su`):
   - Already collected
   - Reused for stack consumer display

### Parsing Strategy:
```bash
# Extract .data section from map file
awk '/^\.data\s+0x/ {flag=1; print; next} /^\./ && flag {exit} flag'

# Get functions with sizes from ELF
arm-none-eabi-nm -S --size-sort firmware.elf | grep " [Tt] "
```

## ❓ About Function Parameters

### Can They Be Displayed?
**YES**, but requires additional implementation:

### What's Needed:
1. Enable debug symbols (`-g` flag)
2. Parse DWARF debug info from ELF
3. Extract DW_TAG_formal_parameter entries
4. Display parameter names, types, sizes

### Example DWARF Data:
```
<1><123>: Abbrev Number: 5 (DW_TAG_subprogram)
    DW_AT_name        : ProcessData
 <2><456>: Abbrev Number: 6 (DW_TAG_formal_parameter)
    DW_AT_name        : input_buffer
    DW_AT_type        : <0x789>
```

### Implementation Complexity:
- **Medium**: DWARF format is well-documented
- **Tools**: `arm-none-eabi-readelf -wi` provides data
- **Parsing**: Regex/awk can extract info
- **Display**: Would fit in current box format

### Why Not Implemented Yet:
- Requires debug symbols (increases ELF size)
- DWARF parsing adds complexity
- Most users care about memory usage, not parameter details
- Can be added as enhancement if needed

## 🚀 Usage

Same as before:
```bash
bash scripts/memory_report.sh firmware.elf vertical
bash scripts/memory_report.sh firmware.elf horizontal
```

The memory layout box appears automatically as the 5th box.

## 📊 Example Output

```
┌──────────────────────────────────────────────────────────┐
│              DETAILED MEMORY LAYOUT                      │
├──────────────────────────────────────────────────────────┤
│ FLASH MEMORY (0x08000000 - 0x0801FFFF)                │
├──────────────────────────────────────────────────────────┤
│ ┌─ 0x08000000  Vector Table (512 bytes)              │
│ │                                                          │
│ ├─ 0x08000200  .text (Code Section)                   │
│ │  Top Functions by Size:                                │
│ │   0x08001234  main                         1024 B │
│ │   0x08001634  ProcessData                   856 B │
│ │   0x08001934  ISR_Handler                   512 B │
│ │   0x08001b34  InitSystem                    384 B │
│ │   0x08001cb4  ReadSensor                    256 B │
│ │                                                          │
│ ├─ 0x08003039  .rodata (Constants)                    │
│ └─ 0x08003039  End of used FLASH                      │
├──────────────────────────────────────────────────────────┤
│ RAM MEMORY (0x20000000 - 0x20008000)                  │
├──────────────────────────────────────────────────────────┤
│ ┌─ 0x20000000  .data (Initialized Data)               │
│ │  Initialized Variables:                                │
│ │   0x20000000  g_systemConfig              256 B │
│ │   0x20000100  g_sensorData                128 B │
│ │   0x20000180  g_statusReg                  32 B │
│ ├─ 0x200001a0  .bss (Zero-initialized Data)           │
│ │  Zero-init Variables:                                  │
│ │   0x200001a0  g_dataBuffer                512 B │
│ │   0x200003a0  g_tempArray                 256 B │
│ ├─ 0x200004a0  HEAP (Dynamic Allocation)              │
│ │  Size: 4096 bytes, Malloc calls: 3                     │
│ ├─ 0x200014a0  STACK (Grows Downward)                 │
│ │  Size: 2048 bytes, Used: 512 bytes (25%)                │
│ │  Stack Consumers:                                      │
│ │   ProcessData                        256 B │
│ │   ReadSensor                         128 B │
│ └─ 0x20008000  End of RAM                             │
├──────────────────────────────────────────────────────────┤
│ Summary:                                                 │
│  Total RAM sections: .data(12) + .bss(8) + heap + stack │
│  Map file: available                                     │
└──────────────────────────────────────────────────────────┘
```

## ✨ Summary

### What Works Now:
- ✅ Complete memory address map
- ✅ Function names, addresses, sizes
- ✅ Variable names, addresses, sizes
- ✅ Top consumers in each section
- ✅ Integrated with existing metrics

### What Could Be Added:
- ⏳ Function parameters (DWARF parsing)
- ⏳ Local variables
- ⏳ Parameter types and sizes
- ⏳ Struct member breakdown
- ⏳ Cross-references

### Bottom Line:
**YES, parameters and functions CAN be displayed.**
- Functions are already shown with full details
- Global variables are already shown
- Function parameters would require DWARF debug info parsing
- This is technically feasible but not yet implemented