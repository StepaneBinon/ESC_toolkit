# GDB Commands

GDB stands for Gnu DeBuger and is used to dynamically debug C and C++ programs (flash, breakpoints, ect). To used it with an embedded system, we must first connect it using a server, like OpenOCD.

Starts GDB + precise which program to load at startup, this is important to get the symbol associations (function name and all), as when flashing a.out, the higher level metadatas are not transefered to the MCU
```bash
arm-none-eabi-gdb a.out
# or if want association after flashing
arm-none-eabi-gdb
target remote :3333
symbol-file out.a
``` 

To flash a given ELF file (Executable and Likable Format - `a.out`) on the MCU
```bash
target remote :3333 # Change the access port if needed
``` 

To connect to a given MCU
```bash
load
``` 