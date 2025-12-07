#warning "coucou"
#include "main.hpp"

// Initializes the Global MSP
void HAL_MspInit(void)
{
    __HAL_RCC_SYSCFG_CLK_ENABLE();
    __HAL_RCC_PWR_CLK_ENABLE();

    HAL_PWREx_DisableUCPDDeadBattery();
}

static uint32_t HAL_RCC_ADC12_CLK_ENABLED=0;

/**
  * @brief ADC MSP Initialization
  * This function configures the hardware resources used in this example
  * @param hadc: ADC handle pointer
  * @retval None
  */
void HAL_ADC_MspInit(ADC_HandleTypeDef* hadc)
{
    GPIO_InitTypeDef GPIO_InitStruct = {0};
    RCC_PeriphCLKInitTypeDef PeriphClkInit = {0};
    if(hadc->Instance==ADC1)
    {
        // Initializes the peripherals clocks
        PeriphClkInit.PeriphClockSelection = RCC_PERIPHCLK_ADC12;
        PeriphClkInit.Adc12ClockSelection = RCC_ADC12CLKSOURCE_SYSCLK;
        if (HAL_RCCEx_PeriphCLKConfig(&PeriphClkInit) != HAL_OK) {
            Error_Handler();
        }

        // Peripheral clock enable 
        HAL_RCC_ADC12_CLK_ENABLED++;
        if(HAL_RCC_ADC12_CLK_ENABLED==1) {
            __HAL_RCC_ADC12_CLK_ENABLE();
        }

        __HAL_RCC_GPIOC_CLK_ENABLE();
        __HAL_RCC_GPIOB_CLK_ENABLE();
        /**ADC1 GPIO Configuration
        PC0     ------> ADC1_IN6
        PC1     ------> ADC1_IN7
        PC2     ------> ADC1_IN8
        PB0     ------> ADC1_IN15
        */
        GPIO_InitStruct.Pin = GPIO_PIN_0|GPIO_PIN_1|GPIO_PIN_2;
        GPIO_InitStruct.Mode = GPIO_MODE_ANALOG;
        GPIO_InitStruct.Pull = GPIO_NOPULL;
        HAL_GPIO_Init(GPIOC, &GPIO_InitStruct);

        GPIO_InitStruct.Pin = GPIO_PIN_0;
        GPIO_InitStruct.Mode = GPIO_MODE_ANALOG;
        GPIO_InitStruct.Pull = GPIO_NOPULL;
        HAL_GPIO_Init(GPIOB, &GPIO_InitStruct);
    }
    else if(hadc->Instance==ADC2)
    {
        // Initializes the peripherals clocks
        PeriphClkInit.PeriphClockSelection = RCC_PERIPHCLK_ADC12;
        PeriphClkInit.Adc12ClockSelection = RCC_ADC12CLKSOURCE_SYSCLK;
        if (HAL_RCCEx_PeriphCLKConfig(&PeriphClkInit) != HAL_OK) {
            Error_Handler();
        }

        // Peripheral clock enable 
        HAL_RCC_ADC12_CLK_ENABLED++;
        if(HAL_RCC_ADC12_CLK_ENABLED==1) {
            __HAL_RCC_ADC12_CLK_ENABLE();
        }

        __HAL_RCC_GPIOA_CLK_ENABLE();
        /**ADC2 GPIO Configuration
        PA0     ------> ADC2_IN1
        PA1     ------> ADC2_IN2
        PA6     ------> ADC2_IN3
        */
        GPIO_InitStruct.Pin = GPIO_PIN_0|GPIO_PIN_1|GPIO_PIN_6;
        GPIO_InitStruct.Mode = GPIO_MODE_ANALOG;
        GPIO_InitStruct.Pull = GPIO_NOPULL;
        HAL_GPIO_Init(GPIOA, &GPIO_InitStruct);
    }
}

/**
  * @brief ADC MSP De-Initialization
  * This function freeze the hardware resources used in this example
  * @param hadc: ADC handle pointer
  * @retval None
  */
void HAL_ADC_MspDeInit(ADC_HandleTypeDef* hadc)
{
    if(hadc->Instance==ADC1)
    {
        /* Peripheral clock disable */
        HAL_RCC_ADC12_CLK_ENABLED--;
        if(HAL_RCC_ADC12_CLK_ENABLED==0) {
            __HAL_RCC_ADC12_CLK_DISABLE();
        }

        /**ADC1 GPIO Configuration
        PC0     ------> ADC1_IN6
        PC1     ------> ADC1_IN7
        PC2     ------> ADC1_IN8
        PB0     ------> ADC1_IN15
        */
        HAL_GPIO_DeInit(GPIOC, GPIO_PIN_0|GPIO_PIN_1|GPIO_PIN_2);

        HAL_GPIO_DeInit(GPIOB, GPIO_PIN_0);
    }
    else if(hadc->Instance==ADC2)
    {
        // Peripheral clock disable 
        HAL_RCC_ADC12_CLK_ENABLED--;
        if(HAL_RCC_ADC12_CLK_ENABLED==0) {
            __HAL_RCC_ADC12_CLK_DISABLE();
        }

        /**ADC2 GPIO Configuration
        PA0     ------> ADC2_IN1
        PA1     ------> ADC2_IN2
        PA6     ------> ADC2_IN3
        */
        HAL_GPIO_DeInit(GPIOA, GPIO_PIN_0|GPIO_PIN_1|GPIO_PIN_6);
    }
}

