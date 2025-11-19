# Setup 

Installations:
1. WSL
2. UsbIPD
3. Give root permission to the STLINK usb
4. OpenOCD
5. GNU toolchain (arm-none-eabi)

## 1. WSL

Install Ubuntu 22.04

To check how much memory is available for your distro
```bash
# Check memory (should show ~16GB)
free -h
# Check CPU cores (should show 12)
nproc
# Or run the provided script in this folder
check-wsl-config.sh
```

## 2. UsbIPD

Install usbipd (in windows powershell)
```bash
winget install --interactive --exact dorssel.usbipd-win
```

Use usbipd (in windows powershell)
```bash
usbipd list
# To share an usb
usbipd bind --busid 3-4
# To attach an usb
usbipd attach --wsl --busid 3-4
```
In linux check that it has connected
```bash
lsusb
ls /dev/tty* # Look for ttyUSB0 / ttyACM0
```

## 3. Rules

To give access:

In etc/udev/rules.d/45-stlink.rules => Change idProduct
```bash
# STLINK V1
ATTRS{idProduct}=="3744", ATTRS{idVendor}=="0483", MODE="666", GROUP="plugdev"
# STLINK V2
ATTRS{idProduct}=="3748", ATTRS{idVendor}=="0483", MODE="666", GROUP="plugdev"
# STLINK V2-1 (Nucleo/Discovery Boards)
ATTRS{idProduct}=="374b", ATTRS{idVendor}=="0483", MODE="666", GROUP="plugdev"
# STLINK V3
ATTRS{idProduct}=="374e", ATTRS{idVendor}=="0483", MODE="666", GROUP="plugdev"
```

To update and trigger the changes
```bash
sudo udevadm control --reload-rules
sudo udevadm trigger
```

## OpenOCD

Build from source or use simple command
```bash
sudo apt install openocd
```
https://openocd.org/doc-release/README

## GNU toolchain

https://developer.arm.com/downloads/-/gnu-rm

Install tarball in WSL and extract it

And GDB seems to need `sudo apt install libncurses5` to work.

Install `arm-none-eabi-gdb`
```bash
sudo apt install gdb-multiarch
# Then arm-none-eabi-gdb is called by gdb-multiarch on Linux
```

## Install the HAL/RTOS

### --------- RTOS: NuttX

https://nuttx.apache.org/docs/latest/quickstart/index.html

Create a `/nuttxspace/` and clone inside
```bash
git clone https://github.com/apache/nuttx.git nuttx
git clone https://github.com/apache/nuttx-apps apps
```
Go to `nuttx.md` 

Uzinp seems neeeded sometimes bu Nuttx so install it
```bash
sudo apt install unzip
```

### --------- HAL: 


## STM32CubeProgrammer

Download it from https://www.st.com/en/development-tools/stm32cubeprog.html

Then we install Java 8
```bash
sudo apt install openjdk-8-jre
```

And finally the STM32Programmer from the unziped folder
```bash
# Give permissions
chmod +x ./SetupSTM32CubeProgrammer-2.21.0.linux
chmod +x ./jre/bin/java
# Run the installer (default install at /usr/local/STMicroelectronics/STM32Cube/STM32CubeProgrammer)
sudo ./SetupSTM32CubeProgrammer-2.21.0.linux
```

Connect and use the CLI/GUI
```bash
# Get the USB device path
ls /dev/tty*
# Add the folder to the PATH
# Open it using the CLI
export PATH=/usr/local/STMicroelectronics/STM32Cube/STM32CubeProgrammer/bin:$PATH
STM32_Programmer_CLI -l /dev/ttyACM0

# Open it using the GUI
STM32CubeProgrammer
```

```bash
```

```bash
```

```bash
```

```bash
```
