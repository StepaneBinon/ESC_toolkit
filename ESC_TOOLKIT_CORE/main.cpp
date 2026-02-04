

#include <cstdint>
#include <cstdlib>
#include <optional>
#include <iostream>

volatile uint32_t count1=0;
volatile uint32_t count2=0;
volatile uint16_t adc_values[3];

ADC_HandleTypeDef hadc1;
ADC_HandleTypeDef hadc2;
DMA_HandleTypeDef hdma_adc1;
TIM_HandleTypeDef htim1;
TIM_HandleTypeDef htim3;

#include "target.hpp"

int main(void)
{
    // Reset of all peripherals, Initializes the Flash interface and the Systick.
    HAL_Init();
    // Configure the system clock
    SystemClock_Config();
    // Initialize all configured peripherals
    GPIO_Init();
    DMA_Init();
    ADC1_Init();
    TIM1_Init();
    TIM3_Init();

    HAL_TIM_PWM_Start(&htim1, TIM_CHANNEL_1);
    HAL_TIM_PWM_Start(&htim1, TIM_CHANNEL_2);
    HAL_TIM_PWM_Start(&htim1, TIM_CHANNEL_3);
    HAL_TIMEx_PWMN_Start(&htim1, TIM_CHANNEL_1);
    HAL_TIMEx_PWMN_Start(&htim1, TIM_CHANNEL_2);
    HAL_TIMEx_PWMN_Start(&htim1, TIM_CHANNEL_3);
    HAL_TIM_OC_Start(&htim3, TIM_CHANNEL_1);

    // HAL_ADC_Start_IT(&hadc1);

    HAL_ADCEx_Calibration_Start(&hadc1, ADC_SINGLE_ENDED);
    HAL_ADC_Start_DMA(&hadc1, (uint32_t*)adc_values, 3);

    // Blink through each pin one at a time
    while (1) {
        // volatile uint16_t adc1_result = (uint16_t)(adc_values[0] & 0xFFFF);    // Master ADC (ADC1)
        // volatile uint16_t adc2_result = (uint16_t)(adc_values[0] >> 16);      // Slave ADC (ADC2)
        // volatile uint32_t count11=count1;
        // volatile uint32_t count22=count2;
        // uint32_t phase_pattern = SSC(Sector::S0);
        // MOSFET_WriteAll(phase_pattern);
        // HAL_GPIO_WritePin(LED_PORT, LED_PIN, GPIO_PIN_SET);    // Turn ON
        // HAL_Delay(500);
        // MOSFET_WriteAll(phase_pattern << 16);
        // HAL_GPIO_WritePin(LED_PORT, LED_PIN, GPIO_PIN_RESET);  // Turn OFF
        // HAL_Delay(500);
        // ReadInjectedADC(adc_values);
    }
}