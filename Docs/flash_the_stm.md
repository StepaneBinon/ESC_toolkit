# Flash the STM

Connect using OpenOCD
```bash
openocd -f interface/stlink.cfg -f target/stm32g4x.cfg -c 'adapter speed 100'
```

Flash the STM
```bash
arm-none-eabi-gdb
#OR
arm-none-eabi-gdb a.out (directly)
```



target remote localhost:3333
monitor reset halt => Halt just after reset ensure that the program counter is set to the reset vector and that the CPU is stopped before any application can be executed
symbol-file a.out