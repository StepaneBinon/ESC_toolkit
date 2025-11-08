# Commands to use with the toolchain

The toolchain we use for the project is `arm-none-eabi`: 

 - arm: MCU architecture
 - none: No operating system (bare metal)
 - eabi: Embedded Application Binary Interface
 - nosys.specs: No system (will loop indefinitly)

It is used to compile the code automatically to the coherent format needed by the hardware. The documentation is here: https://manpages.debian.org/testing/binutils-arm-none-eabi/index.html.

Command to build the main without an OS (Embedded)
```bash
arm-none-eabi-gcc main.cpp --specs=nosys.specs
# arm: MCU architecture
# none: No operating system (bare metal)
# eabi: Embedded Application Binary Interface
# nosys.specs: No system (will loop indefinitly)
```

Command to read an ELF file
```bash
# all
arm-none-eabi-readelf -a a.out 
# headers/sections/segments
arm-none-eabi-readelf -h -S -l a.out   
```

Command to disassembly (binary -> assembly)