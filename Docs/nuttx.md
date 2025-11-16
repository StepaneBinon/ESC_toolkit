# NuttX

## To build NuttX and falsh it

### Setup your board

Search for your board 
./tools/configure.sh -L | grep g4

Set the app folder and configure .config
For nucleo-g431rb
./tools/configure.sh -l nucleo-g431rb:nsh

### Config the board

Show the menu config (/nuttxspace/nuttx)
sudo make menuconfig

Two clean a config
make distclean
then create a new .config
./tools/configure.sh -l nucleo-g431rb:nsh
and you can go again

To check the binary size
arm-none-eabi-size nuttx    => text+data(+rodata)
 - FLASH 128KBytes in nucleo-STM32G431RB
 - SRAM 32KBytes in nucleo-STM32G431RB

### Flash the board

Clean and build the RTOS with the given .config
sudo make clean
sudo make -j (-j is to allow parallel compiling)

To connect to a board
openocd -f interface/stlink.cfg -f target/stm32g4x.cfg -c 'adapter speed 100' -c 'init' -c 'targets' -c 'shutdown'
=> In long term, a openOCD config file will be needed to automatically reduce speed

### To use the nuttshell to debug

Source
https://nuttx.apache.org/docs/latest/applications/nsh/nsh.html

Once Flashed, connect using 
picocom -b 115200 /dev/ttyACM0

## To change the 'app' folder for 'custom_apps'

To tweak a kconfig parameter
sudo kconfig-tweak --set-str CONFIG_APPS_DIR ../custom_apps

When needed to change app directory
./tools/configure.sh -a ../custom_apps nucleo-g431rb:nsh