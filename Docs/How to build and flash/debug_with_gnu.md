# GDB Commands

GDB stands for Gnu DeBuger and is used to dynamically debug C and C++ programs (flash, breakpoints, ect). To used it with an embedded system, we must first connect it using a server, like OpenOCD.

Starts GDB + precise which program to load, this is important to get the symbol associations (function name and all), as when flashing a.out, the higher level metadatas are not transefered to the MCU. This is exposed in from build to flash.

Interresting GDB commands
```bash
# Print code
l
# Insert breakpoint at a given line number
b line_number
# Continue after break
c # Or continue
# Print disassembly
disas
# Print the value of a given memory adress
x 0x08000226

```


```bash
```