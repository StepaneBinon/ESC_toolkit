cmake_minimum_required(VERSION 3.10)

# --- Toolchain and Architecture Configuration ---
set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR arm)
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

set(TOOLCHAIN_PREFIX "arm-none-eabi")

set(CMAKE_C_COMPILER ${TOOLCHAIN_PREFIX}-gcc)
set(CMAKE_CXX_COMPILER ${TOOLCHAIN_PREFIX}-g++)
set(CMAKE_ASM_COMPILER ${TOOLCHAIN_PREFIX}-gcc)
set(CMAKE_OBJCOPY ${TOOLCHAIN_PREFIX}-objcopy)
set(CMAKE_SIZE ${TOOLCHAIN_PREFIX}-size)

project(ESC_TOOLKIT_TARGET_STM32G431RB C CXX ASM)

# Target MCU settings
set(MCU_NAME "stm32g431xx")
set(CORTEX_ARCH "cortex-m4")

# Common compiler flags
set(COMMON_CFLAGS
    -mcpu=${CORTEX_ARCH}
    -mthumb
    -mfpu=fpv4-sp-d16
    -mfloat-abi=hard
    -Wall
    -fdata-sections
    -ffunction-sections
    -g
    -fstack-usage
)
string(REPLACE ";" " " COMMON_CFLAGS_STR "${COMMON_CFLAGS}")
set(CMAKE_C_FLAGS "${COMMON_CFLAGS_STR} -std=gnu11" CACHE STRING "C compiler flags" FORCE)
set(CMAKE_CXX_FLAGS "${COMMON_CFLAGS_STR} -O0 -fno-exceptions -fno-rtti -std=gnu++17" CACHE STRING "CXX compiler flags" FORCE)
set(CMAKE_ASM_FLAGS "${COMMON_CFLAGS_STR} -x assembler-with-cpp" CACHE STRING "ASM compiler flags" FORCE)

# Preprocessor definitions
set(MCU_DEFINITIONS
    ${MCU_NAME}
    STM32G431xx
    __CORTEX_M4
    ARM_MATH_CM4
    USE_HAL_DRIVER
    DEBUG
    USE_NUCLEO_64
    USE_FULL_ASSERT
)
add_compile_definitions(${MCU_DEFINITIONS})

# --- Source Files and Include Directories ---
set(CUBE_ROOT ${CMAKE_SOURCE_DIR}/STM32CubeG4)

# HAL Driver Sources - ADD THE MISSING MODULES
set(HAL_DRIVER_DIR ${CUBE_ROOT}/Drivers/STM32G4xx_HAL_Driver)
set(HAL_SOURCES
    ${HAL_DRIVER_DIR}/Src/stm32g4xx_hal.c
    ${HAL_DRIVER_DIR}/Src/stm32g4xx_hal_adc_ex.c
    ${HAL_DRIVER_DIR}/Src/stm32g4xx_hal_adc.c
    ${HAL_DRIVER_DIR}/Src/stm32g4xx_hal_rcc_ex.c
    ${HAL_DRIVER_DIR}/Src/stm32g4xx_hal_rcc.c
    ${HAL_DRIVER_DIR}/Src/stm32g4xx_hal_cortex.c
    ${HAL_DRIVER_DIR}/Src/stm32g4xx_hal_gpio.c
    ${HAL_DRIVER_DIR}/Src/stm32g4xx_hal_pwr_ex.c
    ${HAL_DRIVER_DIR}/Src/stm32g4xx_hal_tim.c
    ${CMAKE_SOURCE_DIR}/Src/stm32g4xx_it.c
    ${CMAKE_SOURCE_DIR}/Src/stm32g4xx_hal_msp.c
    # Add other HAL sources as needed
)

# CMSIS and Device Sources
set(CMSIS_DEVICE_DIR ${CUBE_ROOT}/Drivers/CMSIS/Device/ST/STM32G4xx)
set(CMSIS_CORE_DIR ${CUBE_ROOT}/Drivers/CMSIS/Core/Include)
set(DEVICE_STARTUP_DIR ${CMSIS_DEVICE_DIR}/Source/Templates/gcc)
set(DEVICE_SYSTEM_DIR ${CMSIS_DEVICE_DIR}/Source/Templates)

set(DEVICE_SOURCES
    ${DEVICE_SYSTEM_DIR}/system_stm32g4xx.c
    ${DEVICE_STARTUP_DIR}/startup_stm32g431xx.s
)

# Project Sources
set(PROJECT_SOURCES
    main.cpp
    syscalls.c  # Add this file - see below
    ${DEVICE_SOURCES}
    ${HAL_SOURCES}
)

# Include Paths
include_directories(
    ${CUBE_ROOT}
    ${CUBE_ROOT}/Drivers/CMSIS/Include
    ${CUBE_ROOT}/Drivers/BSP/STM32G4xx_Nucleo
    ${CMSIS_DEVICE_DIR}/Include
    ${HAL_DRIVER_DIR}/Inc
    ${CMAKE_SOURCE_DIR}/Inc
    ${CMAKE_SOURCE_DIR}
)

# --- Linker Configuration ---
set(LINKER_SCRIPT ${CMAKE_SOURCE_DIR}/linker_minimal.ld)
if(NOT EXISTS ${LINKER_SCRIPT})
    message(FATAL_ERROR "Linker script not found: ${LINKER_SCRIPT}")
endif()
# For project dev: -Wall -Wextra -Werror -Wconversion -Wshadow -Wpedantic -fsanitize=address,undefined
set(CMAKE_EXE_LINKER_FLAGS "-T${LINKER_SCRIPT} -Wl,--gc-sections -Wl,-Map=${PROJECT_NAME}.map -specs=nano.specs -specs=nosys.specs" CACHE STRING "Linker flags" FORCE)

# --- Build the Executable ---
add_executable(${PROJECT_NAME}.elf ${PROJECT_SOURCES})

# Link against standard libraries
target_link_libraries(${PROJECT_NAME}.elf 
    -lc
    -lm
    -lnosys
)

# --- Post-Build Steps ---
add_custom_command(
    TARGET ${PROJECT_NAME}.elf POST_BUILD
    COMMAND ${CMAKE_OBJCOPY} -O ihex $<TARGET_FILE:${PROJECT_NAME}.elf> ${PROJECT_NAME}.hex
    COMMAND ${CMAKE_OBJCOPY} -O binary $<TARGET_FILE:${PROJECT_NAME}.elf> ${PROJECT_NAME}.bin
    # COMMAND bash ${CMAKE_SOURCE_DIR}/memory_report.sh $<TARGET_FILE:${PROJECT_NAME}.elf>
    COMMAND bash ${CMAKE_SOURCE_DIR}/scripts/memory_report.sh $<TARGET_FILE:${PROJECT_NAME}.elf> horizontal
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
    COMMENT "Build complete"
)