cmake_minimum_required(VERSION 3.10)
project(ESC_TOOLKIT_TARGET_STM32G431RB C CXX ASM)

# --- Toolchain and Architecture Configuration ---
set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR arm)

# Specify the path to your ARM GCC toolchain
# You might need to adjust this path based on your system (e.g., C:/...)
set(TOOLCHAIN_PREFIX "arm-none-eabi")

# Compiler/Linker executables
set(CMAKE_C_COMPILER ${TOOLCHAIN_PREFIX}-gcc)
set(CMAKE_CXX_COMPILER ${TOOLCHAIN_PREFIX}-g++)
set(CMAKE_ASM_COMPILER ${TOOLCHAIN_PREFIX}-gcc)
set(CMAKE_OBJCOPY ${TOOLCHAIN_PREFIX}-objcopy)
set(CMAKE_SIZE ${TOOLCHAIN_PREFIX}-size)

# Target MCU specific settings (STM32G431RB/RE)
set(MCU_NAME "stm32g431xx")
set(CORTEX_ARCH "cortex-m4")

# Flags for the C/C++ compiler
set(COMMON_CFLAGS
    -mcpu=${CORTEX_ARCH}
    -mthumb
    -mfpu=fpv4-sp-d16
    -mfloat-abi=hard
    -Wall
    -fdata-sections
    -ffunction-sections
    -g
)
set(CMAKE_C_FLAGS "${COMMON_CFLAGS} -std=gnu11" CACHE STRING "C compiler flags")
set(CMAKE_CXX_FLAGS "${COMMON_CFLAGS} -fno-exceptions -fno-rtti -std=gnu++17" CACHE STRING "CXX compiler flags")
set(CMAKE_ASM_FLAGS "${COMMON_CFLAGS} -x assembler-with-cpp" CACHE STRING "ASM compiler flags")

# Target preprocessor Definitions for STM32G431RB
set(MCU_DEFINITIONS
    ${MCU_NAME}
    STM32G431xx
    __CORTEX_M4
    ARM_MATH_CM4
    USE_HAL_DRIVER
    DEBUG
)
add_compile_definitions(${MCU_DEFINITIONS})

# --- Source Files and Include Directories ---
set(CUBE_ROOT ${CMAKE_SOURCE_DIR}/STM32CubeG4)

# 1. HAL Driver Sources
set(HAL_DRIVER_DIR ${CUBE_ROOT}/Drivers/STM32G4xx_HAL_Driver)
set(HAL_SOURCES
    ${HAL_DRIVER_DIR}/Src/stm32g4xx_hal.c
    ${HAL_DRIVER_DIR}/Src/stm32g4xx_hal_rcc.c
    # Add other HAL sources as needed the project (e.g., GPIO, UART, etc.)
    # For a minimal project, stm32g4xx_hal_rcc is often needed for clock config.
)

# 2. CMSIS and Device Sources
set(CMSIS_DEVICE_DIR ${CUBE_ROOT}/Drivers/CMSIS/Device/ST/STM32G4xx)
set(CMSIS_CORE_DIR ${CUBE_ROOT}/Drivers/CMSIS/Core/Include)
set(DEVICE_STARTUP_DIR ${CMSIS_DEVICE_DIR}/Source/Templates/gcc)
set(DEVICE_SYSTEM_DIR ${CMSIS_DEVICE_DIR}/Source/Templates)

set(DEVICE_SOURCES
    # System Initialization (defines SystemInit)
    ${DEVICE_SYSTEM_DIR}/system_stm32g4xx.c
    # Assembly Startup file (defines Reset_Handler)
    ${DEVICE_STARTUP_DIR}/startup_stm32g431xx.s
)

# 3. Project Sources
set(PROJECT_SOURCES
    main.cpp
    # main.asm
    ${DEVICE_SOURCES}
    ${HAL_SOURCES}
)

# 4. Include Paths
include_directories(
    ${CUBE_ROOT}
    ${CUBE_ROOT}/Drivers/CMSIS/Include
    ${CMSIS_DEVICE_DIR}/Include
    ${HAL_DRIVER_DIR}/Inc
    ${CMAKE_SOURCE_DIR}/Inc # For config files
    ${CMAKE_SOURCE_DIR} # For main.hpp
)

# --- Linker Configuration ---
# Use the provided linker.ld. The file content is defined in the "Helper Files" section below.
set(LINKER_SCRIPT ${CMAKE_SOURCE_DIR}/linker_minimal.ld)
set(LINKER_FLAGS
    -T${LINKER_SCRIPT}
    -nostdlib
    -Wl,--gc-sections
    -Wl,-Map=${PROJECT_NAME}.map
)
set(CMAKE_EXE_LINKER_FLAGS "${LINKER_FLAGS}" CACHE STRING "Linker flags")

# --- Build the Executable ---
add_executable(${PROJECT_NAME}.elf ${PROJECT_SOURCES})

# --- Post-Build Steps (Generate .hex and .bin for flashing) ---
add_custom_command(
    TARGET ${PROJECT_NAME}.elf POST_BUILD
    COMMAND ${CMAKE_OBJCOPY} -O ihex $<TARGET_FILE:${PROJECT_NAME}.elf> ${PROJECT_NAME}.hex
    COMMAND ${CMAKE_OBJCOPY} -O binary $<TARGET_FILE:${PROJECT_NAME}.elf> ${PROJECT_NAME}.bin
    COMMAND ${CMAKE_SIZE} $<TARGET_FILE:${PROJECT_NAME}.elf>
    COMMENT "Generating .hex, .bin, and printing size report"
)