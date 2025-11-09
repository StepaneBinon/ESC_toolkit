# Commands to use with the building toolchain

To gain basic knowledge about the compilation process, relies on [2]. For this project we rely on the famous `gnu` toolkit. The following image sum-it up.

![alt text](.\Images\Gnu_DeBuger\toolchain.png)

The toolchain we use for the project is `arm-none-eabi-gcc`: 

 - arm: MCU architecture
 - none: No operating system (bare metal)
 - eabi: Embedded Application Binary Interface
 - nosys.specs: No system (will loop indefinitly)

It is used to compile the code automatically to the coherent format needed by the hardware. The documentation cqn be found in [1].

Command to build the main without an OS (Embedded), all C++ tags can be added (refer to the doc expliciting existing tags).
```bash
arm-none-eabi-gcc main.cpp --specs=nosys.specs
# to specify the mcu architecture, this is useless if architecture have be precised during making of a.out
arm-none-eabi-gcc -mcpu=cortex-m4
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