# Memory Layout Box - Quick Reference

## What It Does

The Memory Layout Box provides a **detailed, symbol-level view** of your firmware's memory organization, showing:

### FLASH Memory Section
- **Vector Table**: Interrupt vector addresses and size
- **.text Section**: Top 5 largest functions with their addresses and sizes
- **.rodata Section**: Constants (embedded in .text)
- **Exact addresses**: Where each section starts and ends

### RAM Memory Section
- **.data Section**: Top 5 initialized variables with addresses and sizes
- **.bss Section**: Top 5 zero-initialized variables with addresses and sizes
- **HEAP**: Dynamic allocation area with malloc call count
- **STACK**: Stack region with top consumers
- **Exact addresses**: Complete memory map with boundaries

## What Information Is Displayed

### For Functions (FLASH):
```
0x08001234  main                         1024 B
│           │                             │
│           └─ Function name              └─ Size in bytes
└─ Address in FLASH memory
```

### For Variables (RAM):
```
0x20000000  systemConfig                 256 B
│           │                            │
│           └─ Variable name             └─ Size in bytes
└─ Address in RAM
```

## Requirements

### Essential
- Valid ELF file from your build

### For Full Symbol Details
- **Linker map file** (`.map`) generated during build
- Enable in CMakeLists.txt:
```cmake
target_link_options(${PROJECT_NAME}.elf PRIVATE
    -Wl,-Map=${PROJECT_NAME}.map
)
```

### Without Map File
The box will still display:
- Memory region boundaries
- Section sizes
- Top functions by size (from ELF)
- But NOT individual variable details

## How Parameters/Variables Are Extracted

The collector uses multiple methods:

### Method 1: Map File Parsing (Best)
```bash
# Extracts from linker .map file
awk '/^\.data\s+0x/ {flag=1} /^\./ && flag {exit} flag'
```
- Provides: Variable names, addresses, sizes
- Accuracy: Exact
- Limitation: Requires map file

### Method 2: ELF Symbol Table
```bash
arm-none-eabi-nm -S -n --size-sort firmware.elf
```
- Provides: Function/variable names, addresses, sizes
- Accuracy: Good
- Limitation: Less detail than map file

### Method 3: Debug Symbols (Future)
```bash
arm-none-eabi-readelf -w firmware.elf
```
- Could provide: Parameter types, local variables
- Status: Not yet implemented (would show function parameters)

## What's Currently Shown

✅ **Function Information**
- Function name
- Address in FLASH
- Size in bytes
- Top 5 largest functions

✅ **Global Variables**
- Variable name
- Address in RAM (.data or .bss)
- Size in bytes
- Top 5 per section

✅ **Memory Regions**
- Exact start/end addresses
- Section boundaries
- Heap and stack info

❌ **NOT Currently Shown**
- Function parameters (requires DWARF debug info parsing)
- Local variables (stack-allocated)
- Parameter types
- Struct field breakdown

## Can Function Parameters Be Displayed?

**Short Answer**: Yes, but not yet implemented.

**Long Answer**: Function parameters require parsing DWARF debug information from the ELF file:

```bash
# Would extract parameter info:
arm-none-eabi-readelf -wi firmware.elf | grep -A 10 "DW_TAG_formal_parameter"
```

This would show:
- Parameter names
- Parameter types
- Parameter sizes
- Stack offsets

**Implementation Complexity**: Medium
- Requires DWARF parsing
- Debug symbols must be enabled (`-g` flag)
- Output format is complex
- Would need significant parsing logic

## Example Output Interpretation

```
│ ┌─ 0x08000000  Vector Table (512 bytes)              │
```
↑ Vectors start at beginning of FLASH

```
│ │   0x08001234  ProcessData                   856 B │
```
↑ Function ProcessData is at 0x08001234 and takes 856 bytes

```
│ │   0x20000000  systemConfig                 256 B │
```
↑ Variable systemConfig is at start of RAM, 256 bytes

```
│ ├─ 0x200013C0  STACK (Grows Downward)                 │
│ │  Size: 2048 bytes, Used: 512 bytes (25%)                │
```
↑ Stack starts at 0x200013C0, 2KB allocated, 512B used

## Troubleshooting

### "No variables found or map file unavailable"
**Solution**: Enable map file generation:
```cmake
target_link_options(${PROJECT_NAME}.elf PRIVATE -Wl,-Map=${PROJECT_NAME}.map)
```

### "Map file: not found"
**Check**: Is `.map` file in same directory as `.elf`?
**Expected**: `firmware.elf` and `firmware.map` together

### Variables shown but no details
**Cause**: Map file format not recognized
**Check**: Ensure using GNU LD linker

### Want to see parameters
**Status**: Not yet implemented
**Workaround**: Use `arm-none-eabi-nm` manually or examine map file

## Future Enhancements

Potential additions:
1. ✨ Function parameter extraction from DWARF
2. ✨ Local variable display
3. ✨ Struct/union member breakdown
4. ✨ Global vs static variable distinction
5. ✨ Cross-reference: Which functions use which variables
6. ✨ Memory fragmentation analysis

## Summary

**YES, it's possible** to display parameters and functions:
- ✅ Functions: Already displayed with addresses and sizes
- ✅ Global variables: Already displayed with addresses and sizes
- ⏳ Function parameters: Possible but requires DWARF parsing (not yet implemented)
- ⏳ Local variables: Possible but requires DWARF parsing (not yet implemented)

The current implementation provides detailed function and global variable information. Adding parameter display would be a natural extension requiring DWARF debug info parsing.