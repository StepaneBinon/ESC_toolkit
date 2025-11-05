cmake_minimum_required(VERSION 3.20)
project(stm32_template C CXX ASM)

set(CMAKE_TOOLCHAIN_FILE ${CMAKE_SOURCE_DIR}/cmake/toolchain-arm-none-eabi.cmake)

set(LINKER_SCRIPT ${CMAKE_SOURCE_DIR}/linker/STM32G431CB_FLASH.ld)

add_executable(${PROJECT_NAME}
  src/main.c
  src/system_stm32g4xx.c
  startup/startup_stm32g431xx.s
)

target_include_directories(${PROJECT_NAME} PRIVATE
  drivers/CMSIS/Include
  drivers/CMSIS/Device/ST/STM32G4xx/Include
  drivers/HAL/Inc
  src
)

# CPU/ABI flags (Cortex-M4F on G431)
set(CPU_FLAGS "-mcpu=cortex-m4 -mthumb -mfpu=fpv4-sp-d16 -mfloat-abi=hard")

target_compile_options(${PROJECT_NAME} PRIVATE
  ${CPU_FLAGS}
  -Og -g3
  -ffunction-sections -fdata-sections
  -Wall -Wextra -Wno-unused-parameter
)

target_link_options(${PROJECT_NAME} PRIVATE
  ${CPU_FLAGS}
  -T${LINKER_SCRIPT}
  -Wl,--gc-sections
  -Wl,-Map=${PROJECT_NAME}.map
)

# HAL sources (add what you actually use)
target_sources(${PROJECT_NAME} PRIVATE
  drivers/HAL/Src/stm32g4xx_hal.c
  drivers/HAL/Src/stm32g4xx_hal_rcc.c
  drivers/HAL/Src/stm32g4xx_hal_gpio.c
  drivers/HAL/Src/stm32g4xx_hal_cortex.c
  # + add ADC/TIM/HRTIM as needed
)

# Produce BIN/HEX and show size
add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
  COMMAND ${ARM_OBJCOPY} -O ihex $<TARGET_FILE:${PROJECT_NAME}> ${PROJECT_NAME}.hex
  COMMAND ${ARM_OBJCOPY} -O binary $<TARGET_FILE:${PROJECT_NAME}> ${PROJECT_NAME}.bin
  COMMAND ${ARM_SIZE} --format=berkeley $<TARGET_FILE:${PROJECT_NAME}>
)