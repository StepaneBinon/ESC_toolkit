# Setup 

Installations:
1. WSL
2. UsbIPD
3. Give root permission to the STLINK usb
4. OpenOCD
5. GNU toolchain (arm-none-eabi)

## 1. WSL

## 2. UsbIPD

Install usbIPD

winget install --interactive --exact dorssel.usbipd-win

Use UsbIPD
usbipd list
usbipd bind --busid 3-4
linux- > lsusb

## 3. Rules

To give access:

In etc/udev/rules.d/45-stlink.rules => Change idProduct

# STLINK V1
ATTRS{idProduct}=="3744", ATTRS{idVendor}=="0483", MODE="666", GROUP="plugdev"
# STLINK V2
ATTRS{idProduct}=="3748", ATTRS{idVendor}=="0483", MODE="666", GROUP="plugdev"
# STLINK V2-1 (Nucleo/Discovery Boards)
ATTRS{idProduct}=="374b", ATTRS{idVendor}=="0483", MODE="666", GROUP="plugdev"
# STLINK V3
ATTRS{idProduct}=="374e", ATTRS{idVendor}=="0483", MODE="666", GROUP="plugdev"

To update and trigger the changes
sudo udevadm control --reload-rules
sudo udevadm trigger

## OpenOCD

https://openocd.org/doc-release/README

## ST-Link driver

all needed pckg must be installed
https://github.com/stlink-org/stlink/blob/testing/doc/compiling.md
