# Setup 

Installations:
1. WSL
2. UsbIPD
3. Give root permission to the STLINK usb
4. OpenOCD
5. GNU toolchain (arm-none-eabi)

## 1. WSL

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

## Install the HAL/RTOS

### --------- RTOS: NuttX

https://nuttx.apache.org/docs/latest/quickstart/index.html

Create a /nuttxspace/ and clone inside
```bash
git clone https://github.com/apache/nuttx.git nuttx
git clone https://github.com/apache/nuttx-apps apps
```
Go to `nuttx.md` 

### --------- HAL: 



## Other

Uzinp seems neeeded sometimes bu Nuttx
```bash
sudo apt install unzip
```
