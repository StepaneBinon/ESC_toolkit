# Flash the STM

arm-none-eabi-gcc -mcpu=cortex-m4 -mthumb -O0 -g3 -ffunction-sections -fdata-sections --specs=nosys.specs main.cpp


openocd -f interface/stlink.cfg -f target/stm32g4x.cfg


arm-none-eabi-gdb     or     arm-none-eabi-gdb a.out (directly)



target remote localhost:3333
monitor reset halt => Halt just after reset ensure that the program counter is set to the reset vector and that the CPU is stopped before any application can be executed
symbol-file a.out