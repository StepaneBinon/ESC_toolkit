# CMakeLists Params

 - CMAKE_SYSTEM_NAME: defines the OS used.
 - CMAKE_SYSTEM_PROCESSOR: defines the processor used.
 - TOOLCHAIN_PREFIX: define the toolchain path 

The compiling command
```bash
cat build/CMakeFiles/ESC_TOOLKIT_TARGET_STM32G431RB.elf.dir/link.txt
```

To see the stack consumption of all functions order by size
```bash
find build -name "*.su" -exec cat {} \; | sort -k2 -n -r
# To ignore STM32 Hal
find build -name "*.su" ! -path "*/STM32CubeG4/*" -exec cat {} \; | sort -k2 -n -r
```

To show all interupt handler compiled
```bash
arm-none-eabi-objdump -t build/ESC_TOOLKIT_TARGET_STM32G431RB.elf | grep "Handler$"
```