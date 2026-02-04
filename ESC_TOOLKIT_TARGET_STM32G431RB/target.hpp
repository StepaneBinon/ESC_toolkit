
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
void HAL_TIM_MspPostInit(TIM_HandleTypeDef *htim);
#ifdef __cplusplus
}
#endif

/* General variables -----------------------------*/
void SystemClock_Config(void);
void GPIO_Init(void);
void DMA_Init(void);
void ADC1_Init(void);
void TIM1_Init(void);
void TIM3_Init(void);
#define MOSFET_PORT GPIOB
#define AH GPIO_PIN_8
#define AL GPIO_PIN_11
#define BH GPIO_PIN_12
#define BL GPIO_PIN_13
#define CH GPIO_PIN_14
#define CL GPIO_PIN_15
#define MOSFET_MASK (AH|AL|BH|BL|CH|CL)

#define DEAD_TIME 18
#define PWM_OFF 1000
#define V_HYST 1000

#define LED_PIN GPIO_PIN_5
#define LED_PORT GPIOA

#define CLOCK_FREQ 170000000
#define DELAY_SLAVE_TRIGGER_NS 20.3 // Delay btwn OC1 and blanking slave TIM trigger (ns)
#define DELAY_TOTAL_PWM_BLANKING_NS 700 // Delay before the t_off is considered clean for ADC conversions (ns)
// #define DELAY_PWM_BLANKING_TICK ((DELAY_TOTAL_PWM_BLANKING_NS-DELAY_SLAVE_TRIGGER_NS)*0.000000001*CLOCK_FREQ + 3)
#define DELAY_PWM_BLANKING_TICK 300

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