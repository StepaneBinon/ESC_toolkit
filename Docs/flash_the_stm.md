# Flash the STM

Connect using OpenOCD
```bash
openocd -f interface/stlink.cfg -f target/stm32g4x.cfg -c 'adapter speed 100'
```

Flash the STM 
```bash
gdb-multiarch
# OR
gdb-multiarch a.out (directly)
```


```bash
target remote localhost:3333
# Halt just after reset ensure that the program counter is set to the reset vector and that the CPU is stopped before any application can be executed
monitor reset halt 
symbol-file a.out
```