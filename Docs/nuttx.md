# NuttX

## To build NuttX and falsh it

### Setup your board

Search for your board 
./tools/configure.sh -L | grep g4

Set the app folder and configure .config
```bash
# For nucleo-g431rb
./tools/configure.sh -l nucleo-g431rb:nsh
```

### Config the board

Show the menu config (/nuttxspace/nuttx)
sudo make menuconfig

Two clean a config
make distclean
then create a new .config
./tools/configure.sh -l nucleo-g431rb:nsh
and you can go again

To check the binary size
```bash
arm-none-eabi-size nuttx
# => FLASH text+data(+rodata)
# => RAM bss+data
#  - FLASH 128Kbytes (128*2^10: 131072bytes - binary shit/BS) in nucleo-STM32G431RB
#  - SRAM 32KBytes (128*2^10: 32768bytes) in nucleo-STM32G431RB 
``` 
To have a pretty render
```bash
arm-none-eabi-size nuttx | tail -1 | awk -v flash=131072 -v sram=32768 '{
  flash_used = $1 + $2;
  sram_used  = $2 + $(3);
  printf("Mem region    Used Size    Region Size    %%age Used\n");
  printf("    flash: %10d B       %5d KB      %6.2f%%\n", flash_used, flash/1024, 100*flash_used/flash);
  printf("     sram: %10d B       %5d KB      %6.2f%%\n", sram_used, sram/1024, 100*sram_used/sram);
}'
```

Size experience sharing for a stm32g431rb:
At first build of the OS the size is
```bash
Mem region    Used Size    Region Size    %age Used
    flash:     128420 B         128 KB       97.98%
     sram:       9504 B          32 KB       29.00%
```
We can deactivate the following:
 - `Application Configuration -> Testing -> OS test example`, so deactivate it (unsing `n` or `y`) not `space` (-44.13% flash/ -5.27% RAM)
 - `Application Configuration -> System Libraries and NSH Add-Ons -> system 'dd' command` (-3.61% flash/ -0.06% RAM)
 - `Application Configuration -> System Libraries and NSH Add-Ons -> readline() Support`
 - `Binary Loader -> Disable BINFMT support` (-0.08% flash/ -0.05% RAM)
 - You can go further, and its necessary for a finished app
It drops to
```bash
Mem region    Used Size    Region Size    %age Used
    flash:      70096 B         128 KB       53.48%
     sram:       9040 B          32 KB       27.59%
```
which can be used reliably. So test the OS perf and then deactivate it.

Usefull params experience for a stm32g431rb:
 - `Application Configuration -> System Libraries and NSH Add-Ons -> readline() Support`: can be used to activate nsh `tab`, `backspace`, ... 
 - `Build Setup -> Debug Options -> Define NDEBUG globally` to deactivate
 - `Build Setup -> Debug Options -> Stack coloration` 
 - `Build Setup -> Debug Options -> Generate stack usage information` 
 - `RTOS Features -> Stack BackTrace` This one and the 3 previous seems to take ~8-10%
Using these future, we are at
```bash
Mem region    Used Size    Region Size    %age Used
    flash:      84620 B         128 KB       64.56%
     sram:       9228 B          32 KB       28.16%
```

### Flash the board

Clean and build the RTOS with the given .config
sudo make clean
(-j is to allow parallel compiling)
sudo make -j
(to avoid logs)
sudo make -j > /dev/null

To connect to a board
```bash
openocd -f interface/stlink.cfg -f target/stm32g4x.cfg -c 'adapter speed 100' -c 'init' -c 'targets' -c 'shutdown'
```
=> In long term, a openOCD config file will be needed to automatically reduce speed

### To use the nuttshell to debug

Source
https://nuttx.apache.org/docs/latest/applications/nsh/nsh.html

Once Flashed, connect using 
```bash
picocom -b 115200 /dev/ttyACM0
```

Tips on picocom
```bash
ctrl+a   ->   ctrl+h
```

## To change the 'app' folder for 'custom_apps'

To tweak a kconfig parameter
sudo kconfig-tweak --set-str CONFIG_APPS_DIR ../custom_apps

When needed to change app directory
./tools/configure.sh -a ../custom_apps nucleo-g431rb:nsh