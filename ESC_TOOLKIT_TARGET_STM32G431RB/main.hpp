
#ifndef __MAIN_HPP
#define __MAIN_HPP

#include "stm32g4xx_hal.h"
// #include "stm32g4xx_it.h"
// #include "stm32g4xx_nucleo.h"

#ifdef __cplusplus
#include <cstdint>
#include <cstdlib>
#include <optional>
#include <iostream>
#endif // __cplusplus

/* Exported functions prototypes ---------------------------------------------*/
#ifdef __cplusplus
extern "C" {
#endif
void Error_Handler(void);
#ifdef __cplusplus
}
#endif

/* Private defines ----------------------------------------------------------- */
#define RCC_OSC32_OUT_Pin GPIO_PIN_14
#define RCC_OSC32_OUT_GPIO_Port GPIOC
#define RCC_OSC32_OUTC15_Pin GPIO_PIN_15
#define RCC_OSC32_OUTC15_GPIO_Port GPIOC
#define RCC_OSC_IN_Pin GPIO_PIN_0
#define RCC_OSC_IN_GPIO_Port GPIOF
#define RCC_OSC_OUT_Pin GPIO_PIN_1
#define RCC_OSC_OUT_GPIO_Port GPIOF
#define T_SWDIO_Pin GPIO_PIN_13
#define T_SWDIO_GPIO_Port GPIOA
#define T_SWCLK_Pin GPIO_PIN_14
#define T_SWCLK_GPIO_Port GPIOA
#define T_SWO_Pin GPIO_PIN_3
#define T_SWO_GPIO_Port GPIOB

#endif // __MAIN_HPP