# Commands to use with the building toolchain

To gain basic knowledge about the compilation process, relies on [2]. For this project we rely on the famous `gnu` toolkit. The following image sum-it up.

![alt text](.\Images\Gnu_DeBuger\toolchain.png)

The toolchain we use for the project is `arm-none-eabi-gcc`: 

 - arm: MCU architecture
 - none: No operating system (bare metal)
 - eabi: Embedded Application Binary Interface
 - nosys.specs: No system (will loop indefinitly)

It is used to compile the code automatically to the coherent format needed by the hardware. The documentation cqn be found in [1].

Command to build the main without an OS (Embedded) for arm architecture, all C++ tags can be added (refer to the doc expliciting existing tags).
```bash
arm-none-eabi-gcc \
  -mcpu=cortex-m4 -mthumb \
  -std=c++17 -O0 -g \
  -ffreestanding -nostdlib \
  -c main.cpp -o main.o
# -mcpu=cortex-m4 : generate code for Cortex-M4.
# -mthumb : use Thumb instruction set (what Cortex-M actually runs).
# -O0 : no optimizations, so the assembly is “literal” and easier to read.
# -g : include debug info (handy later with GDB).
# -ffreestanding : tell the compiler there is no hosted OS, no normal main/argc/argv conventions.
# -nostdlib : don’t try to link libc, libstdc++, etc.
```

You can get the assembly code by disassembling the object file
```bash
arm-none-eabi-objdump -d -S main.o > main.asm
```



Command to connect GDB to OpenOCD


Command to read an ELF file
```bash
# all
arm-none-eabi-readelf -a a.out 
# headers/sections/segments
arm-none-eabi-readelf -h -S -l a.out   
```

Command to disassembly (binary -> assembly)

## Ressources

[1] https://manpages.debian.org/testing/binutils-arm-none-eabi/index.html

[2] Compilation process: https://www.geeksforgeeks.org/cpp/how-to-compile-a-cpp-program-using-gcc/ 