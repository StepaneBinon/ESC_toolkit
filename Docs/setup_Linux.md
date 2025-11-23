# Setup 

Installations:
1. WSL
2. UsbIPD
3. Give root permission to the STLINK usb
4. OpenOCD
5. GNU toolchain (arm-none-eabi)

## 1. WSL

Install Ubuntu 22.04 using powershell as **ADMIN**
```bash
# Install WSL2
wsl --install
# Reboot (required)
Restart-Computer
# After reboot, set WSL2 as default
wsl --set-default-version 2
# Check distro available
wsl --list --online
# Install a distro (Ubuntu by default, or specify)
wsl --install -d Ubuntu-22.04
# Check status
wsl --list --verbose
```

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

## OpenOCD

Use the command
```bash
sudo apt install openocd
```

And give to openOCD the rights to connect to the ST-Link 
```bash
# Create a rule file for st-link
sudo touch /etc/udev/rules.d/45-stlink.rules
sudo nano /etc/udev/rules.d/45-stlink.rules
```

And copy the following content inside
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

Apply the rules (restart also work)
```bash
sudo udevadm control --reload-rules 
sudo udevadm trigger # Reload all connected device as if they where plug in again
```

Or build from source: https://openocd.org/doc-release/README

## GNU toolchain

Install tarball in WSL and extract it: https://developer.arm.com/downloads/-/gnu-rm
```bash
sudo apt-get update && sudo apt-get install bzip2
tar -xjf gcc-arm-none-eabi-10.3-2021.10-x86_64-linux.tar.bz2
sudo mv gcc-arm-none-eabi-10.3-2021.10 /opt/
echo 'export PATH=/opt/gcc-arm-none-eabi-10.3-2021.10/bin:$PATH' >> ~/.bashrc
source ~/.bashrc
```
GDB seems to need `sudo apt install libncurses5` to work.

Then, install the debugger `arm-none-eabi-gdb` using `gdb-multiarch`
```bash
sudo apt install gdb-multiarch
sudo apt install binutils-multiarch
# arm-none-eabi-gdb is called by gdb-multiarch on Linux
```

## Cmake

To get access to the CMakeLists tool
```bash
sudo apt install cmake
source ~/.bashrc
```

## VS Code extensions

 - Cortex debug (and the extensions it relies on)
 - C/C++ Extension
 - Git graph

launch.json
```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Cortex Debug (OpenOCD)",
            "cwd": "${workspaceFolder}",
            "executable": "${workspaceFolder}/ESC_TOOLKIT_TARGET_STM32G431RB/build/ESC_TOOLKIT_TARGET_STM32G431RB.elf",
            "request": "launch",
            "type": "cortex-debug",
            "runToEntryPoint": "main",
            "servertype": "openocd",
            "device": "STM32G431RB",
            "configFiles": [
            "interface/stlink.cfg",
            "target/stm32g4x.cfg"
            ],
            // "preLaunchTask": "Build",  // This runs before debugging starts
            // "showDevDebugOutput": "raw"
        }
    ]
}
```

settings.json
```json
{
    "cortex-debug.gdbPath": "gdb-multiarch",
    "cortex-debug.stlinkPath": null,
    // "cmake.cmakePath": "/usr/bin/cmake",
}
```


## Install the HAL/RTOS (optionnal)

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


## STM32CubeProgrammer (optionnal)

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
