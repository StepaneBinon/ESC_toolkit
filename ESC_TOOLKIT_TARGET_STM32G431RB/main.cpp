#include "main.hpp"

#define MOSFET_PORT GPIOB
#define AH GPIO_PIN_10
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

enum class Sector { 
    S0, S1, S2, S3, S4, S5
};
enum class Phase { 
    A, B, C
};
enum class Dir { 
    Up, Down
};
enum class Sign { 
    Negi, Posi
};

uint32_t SSC(const Sector sector) {
    if (sector == Sector::S0) {
        return AH|BL;
    }
    else if (sector == Sector::S1) {
        return AH|CL;
    }
    else if (sector == Sector::S2) {
        return BH|CL;
    }
    else if (sector == Sector::S3) {
        return BH|AL;
    }
    else if (sector == Sector::S4) {
        return CH|AL;
    }
    else {
        return CH|BL;
    }
}

Phase getFloatingPhase(const Sector sector_prev) {
    if (sector_prev == Sector::S0 || sector_prev == Sector::S3) {
        return Phase::B;
    }
    else if (sector_prev == Sector::S4 || sector_prev == Sector::S4) {
        return Phase::C; 
    }
    else {
        return Phase::A; 
    }
}

Dir getDir(const int32_t delta_v) {
    if (delta_v > 0) {
        return Dir::Up;
    }
    else {
        return Dir::Down;
    }
}

Sector getNextSector(const Phase phase, const Dir dir) {
    if (phase == Phase::A && dir == Dir::Up) {
        return Sector::S1;
    }
    else if (phase == Phase::A && dir == Dir::Down) {
        return Sector::S4;
    }
    else if (phase == Phase::B && dir == Dir::Up) {
        return Sector::S3;
    }
    else if (phase == Phase::B && dir == Dir::Down) {
        return Sector::S0;
    }
    else if (phase == Phase::C && dir == Dir::Up) {
        return Sector::S5;
    }
    else {
        return Sector::S2;
    }
}

std::optional<Sector> getSector(const uint32_t tcom_last, 
                                const uint32_t tcom_curr, 
                                const int32_t v_bus, 
                                const Sector sector_prev, 
                                const int32_t v_ph,
                                const Sign sign_prev) {
    if (tcom_curr - tcom_last < DEAD_TIME) {
        return std::nullopt;
    }

    const Phase floating_ph = getFloatingPhase(sector_prev);
    const int32_t v_neutral = v_bus/2;
    const int32_t delta_v = v_ph - v_neutral;
    const int32_t abs_delta_v = std::abs(delta_v);
    const Sign sign_curr = (delta_v == abs_delta_v) ? Sign::Posi : Sign::Negi;
    // If no ZC
    if (sign_curr == sign_prev || abs_delta_v >= V_HYST) {
        return std::nullopt;
    } 

    const Dir dir = getDir(delta_v);
    const Sector sector = getNextSector(floating_ph, dir);

    return sector;
}

bool isPwmOn(const uint32_t timer) {
    if (timer > PWM_OFF) {
        return false;
    }
    return true;
}

std::optional<uint32_t> getCmdArray(const uint32_t tcom_last, 
                                    const uint32_t tcom_curr, 
                                    const int32_t v_bus, 
                                    const Sector sector_prev, 
                                    const int32_t v_ph,
                                    const Sign sign_prev,
                                    const uint32_t timer) {
    if (isPwmOn(timer)) {
        return std::nullopt;
    } 

    auto temp = getSector(tcom_last, tcom_curr, v_bus, sector_prev, v_ph, sign_prev);
    if (!temp.has_value()) {
        return std::nullopt;
    }

    return SSC(temp.value());
}

void DWT_Init(void) {
    CoreDebug->DEMCR |= CoreDebug_DEMCR_TRCENA_Msk;  // Enable trace
    DWT->CYCCNT = 0;                                  // Reset counter
    DWT->CTRL |= DWT_CTRL_CYCCNTENA_Msk;             // Enable counter
}

void DWT_Reset(void) {
    DWT->CYCCNT = 0;                                  // Reset counter
}

uint32_t DWT_GetCycles(void) {
    return DWT->CYCCNT;
}

static inline void MOSFET_WriteAll(uint32_t phase_pattern) {
    const uint32_t bsrr_value = (phase_pattern & MOSFET_MASK)
                                | ((~phase_pattern & MOSFET_MASK) << 16);
    MOSFET_PORT->BSRR = bsrr_value;
}

// Trigger injected conversion and read all 3 channels
void ReadInjectedADC(volatile uint32_t* results)
{
    // Start injected conversion
    HAL_ADCEx_InjectedStart(&hadc1);
    
    // Wait for conversion to complete
    HAL_ADCEx_InjectedPollForConversion(&hadc1, HAL_MAX_DELAY);
    
    // Read all 3 injected channels
    results[0] = HAL_ADCEx_InjectedGetValue(&hadc1, ADC_INJECTED_RANK_1); // Channel 6
    results[1] = HAL_ADCEx_InjectedGetValue(&hadc1, ADC_INJECTED_RANK_2); // Channel 7
    results[2] = HAL_ADCEx_InjectedGetValue(&hadc1, ADC_INJECTED_RANK_3); // Channel 8
    
    // Stop injected conversion
    HAL_ADCEx_InjectedStop(&hadc1);
}

ADC_HandleTypeDef hadc1;
ADC_HandleTypeDef hadc2;
TIM_HandleTypeDef htim1;

void SystemClock_Config(void);
void GPIO_Init(void);
void ADC1_Init(void);
static void MX_TIM1_Init(void);

int main(void)
{
    // Reset of all peripherals, Initializes the Flash interface and the Systick.
    HAL_Init();
    // Configure the system clock
    SystemClock_Config();
    // Initialize all configured peripherals
    GPIO_Init();
    DWT_Init();
    ADC1_Init();
    MX_TIM1_Init();

    volatile uint32_t adc_values[3];

    // Blink through each pin one at a time
    while (1) {
        uint32_t phase_pattern = SSC(Sector::S0);
        MOSFET_WriteAll(phase_pattern);
        HAL_GPIO_WritePin(LED_PORT, LED_PIN, GPIO_PIN_SET);    // Turn ON
        HAL_Delay(500);
        MOSFET_WriteAll(phase_pattern << 16);
        HAL_GPIO_WritePin(LED_PORT, LED_PIN, GPIO_PIN_RESET);  // Turn OFF
        HAL_Delay(500);
        ReadInjectedADC(adc_values);
    }
}

void SystemClock_Config(void)
{
    RCC_OscInitTypeDef RCC_OscInitStruct = {0};
    RCC_ClkInitTypeDef RCC_ClkInitStruct = {0};

    /** Configure the main internal regulator output voltage
     */
    HAL_PWREx_ControlVoltageScaling(PWR_REGULATOR_VOLTAGE_SCALE1_BOOST);

    /** Initializes the RCC Oscillators according to the specified parameters
     * in the RCC_OscInitTypeDef structure.
     */
    RCC_OscInitStruct.OscillatorType = RCC_OSCILLATORTYPE_HSI;
    RCC_OscInitStruct.HSIState = RCC_HSI_ON;
    RCC_OscInitStruct.HSICalibrationValue = RCC_HSICALIBRATION_DEFAULT;
    RCC_OscInitStruct.PLL.PLLState = RCC_PLL_ON;
    RCC_OscInitStruct.PLL.PLLSource = RCC_PLLSOURCE_HSI;
    RCC_OscInitStruct.PLL.PLLM = RCC_PLLM_DIV4;
    RCC_OscInitStruct.PLL.PLLN = 85;
    RCC_OscInitStruct.PLL.PLLP = RCC_PLLP_DIV2;
    RCC_OscInitStruct.PLL.PLLQ = RCC_PLLQ_DIV2;
    RCC_OscInitStruct.PLL.PLLR = RCC_PLLR_DIV2;
    if (HAL_RCC_OscConfig(&RCC_OscInitStruct) != HAL_OK) {
        Error_Handler();
    }

    /** Initializes the CPU, AHB and APB buses clocks
     */
    RCC_ClkInitStruct.ClockType = RCC_CLOCKTYPE_HCLK|RCC_CLOCKTYPE_SYSCLK|RCC_CLOCKTYPE_PCLK1|RCC_CLOCKTYPE_PCLK2;
    RCC_ClkInitStruct.SYSCLKSource = RCC_SYSCLKSOURCE_PLLCLK;
    RCC_ClkInitStruct.AHBCLKDivider = RCC_SYSCLK_DIV1;
    RCC_ClkInitStruct.APB1CLKDivider = RCC_HCLK_DIV1;
    RCC_ClkInitStruct.APB2CLKDivider = RCC_HCLK_DIV1;

    if (HAL_RCC_ClockConfig(&RCC_ClkInitStruct, FLASH_LATENCY_4) != HAL_OK) {
        Error_Handler();
    }
}

void ADC1_Init(void)
{
    ADC_InjectionConfTypeDef sConfigInjected = {0};
    
    // Common config
    hadc1.Instance = ADC1;
    hadc1.Init.ClockPrescaler = ADC_CLOCK_SYNC_PCLK_DIV4;
    hadc1.Init.Resolution = ADC_RESOLUTION_12B;
    hadc1.Init.DataAlign = ADC_DATAALIGN_RIGHT;
    hadc1.Init.GainCompensation = 0;
    hadc1.Init.ScanConvMode = ADC_SCAN_ENABLE;
    hadc1.Init.EOCSelection = ADC_EOC_SINGLE_CONV;
    hadc1.Init.LowPowerAutoWait = DISABLE;
    hadc1.Init.ContinuousConvMode = DISABLE;
    hadc1.Init.NbrOfConversion = 1;
    hadc1.Init.NbrOfDiscConversion = 1;
    hadc1.Init.DiscontinuousConvMode = DISABLE;
    // hadc1.Init.ExternalTrigConv = ADC_SOFTWARE_START;
    // hadc1.Init.ExternalTrigConvEdge = ADC_SOFTWARE_START;
    // hadc1.Init.SamplingMode = ADC_SOFTWARE_START;
    hadc1.Init.DMAContinuousRequests = DISABLE;
    hadc1.Init.Overrun = ADC_OVR_DATA_PRESERVED;
    hadc1.Init.OversamplingMode = DISABLE;
    // hadc1.Init.Oversampling = ADC_OVR_DATA_PRESERVED;
    if (HAL_ADC_Init(&hadc1) != HAL_OK) {
        Error_Handler();
    }

    // Configure Injected Channel 6
    sConfigInjected.InjectedChannel = ADC_CHANNEL_6;
    sConfigInjected.InjectedRank = ADC_INJECTED_RANK_1;
    sConfigInjected.InjectedSamplingTime = ADC_SAMPLETIME_2CYCLES_5;
    sConfigInjected.InjectedSingleDiff = ADC_SINGLE_ENDED;
    sConfigInjected.InjectedOffsetNumber = ADC_OFFSET_NONE;
    sConfigInjected.InjectedOffset = 0;
    sConfigInjected.InjectedNbrOfConversion = 3;
    sConfigInjected.InjectedDiscontinuousConvMode = DISABLE;
    sConfigInjected.AutoInjectedConv = DISABLE;
    sConfigInjected.QueueInjectedContext = DISABLE;
    sConfigInjected.ExternalTrigInjecConv = ADC_INJECTED_SOFTWARE_START;
    sConfigInjected.ExternalTrigInjecConvEdge = ADC_EXTERNALTRIGINJECCONV_EDGE_NONE;
    sConfigInjected.InjecOversamplingMode = DISABLE;
    if (HAL_ADCEx_InjectedConfigChannel(&hadc1, &sConfigInjected) != HAL_OK) {
        Error_Handler();
    }

    // Configure Injected Channel 7
    sConfigInjected.InjectedChannel = ADC_CHANNEL_7;
    sConfigInjected.InjectedRank = ADC_INJECTED_RANK_2;
    if (HAL_ADCEx_InjectedConfigChannel(&hadc1, &sConfigInjected) != HAL_OK) {
        Error_Handler();
    }

    // Configure Injected Channel 8
    sConfigInjected.InjectedChannel = ADC_CHANNEL_8;
    sConfigInjected.InjectedRank = ADC_INJECTED_RANK_3;
    if (HAL_ADCEx_InjectedConfigChannel(&hadc1, &sConfigInjected) != HAL_OK) {
        Error_Handler();
    }
    
    HAL_ADCEx_Calibration_Start(&hadc1, ADC_SINGLE_ENDED);
}

void GPIO_Init(void)
{
    GPIO_InitTypeDef GPIO_InitStruct = {0};
    
    // Enable GPIO clock (change based on your port)
    __HAL_RCC_GPIOA_CLK_ENABLE();
    __HAL_RCC_GPIOB_CLK_ENABLE();
    
    // Configure LED pin
    HAL_GPIO_WritePin(LED_PORT, LED_PIN, GPIO_PIN_RESET);
    GPIO_InitStruct.Pin = LED_PIN;
    GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP;  // Push-pull output
    GPIO_InitStruct.Pull = GPIO_NOPULL;
    GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_VERY_HIGH;
    HAL_GPIO_Init(LED_PORT, &GPIO_InitStruct);

    // Configure MOSFETS pins
    HAL_GPIO_WritePin(GPIOB, AH|AL|BH|BL|CH|CL, GPIO_PIN_RESET);
    GPIO_InitStruct.Pin = AH|AL|BH|BL|CH|CL;
    GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP;  // Push-pull output
    GPIO_InitStruct.Pull = GPIO_NOPULL;
    GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_VERY_HIGH;
    HAL_GPIO_Init(GPIOB, &GPIO_InitStruct);

    // Configure ADC1 pins
    // GPIO_InitStruct.Pin = GPIO_PIN_0 | GPIO_PIN_1 | GPIO_PIN_6;
    // GPIO_InitStruct.Mode = GPIO_MODE_ANALOG;
    // GPIO_InitStruct.Pull = GPIO_NOPULL;
    // HAL_GPIO_Init(GPIOA, &GPIO_InitStruct);
    // GPIO_InitStruct.Pin = GPIO_PIN_3;
    // HAL_GPIO_Init(GPIOC, &GPIO_InitStruct);
}

/**
  * @brief  This function is executed in case of error occurrence.
  * @retval None
  */
void Error_Handler(void)
{
  __disable_irq();
  while (1)
  {
  }
}

#ifdef USE_FULL_ASSERT
/**
  * @brief  Reports the name of the source file and the source line number
  *         where the assert_param error has occurred.
  * @param  file: pointer to the source file name
  * @param  line: assert_param error line source number
  * @retval None
  */
void assert_failed(uint8_t *file, uint32_t line) {
    // printf("Wrong parameters value: file %s on line %d\r\n", file, line);
    HAL_GPIO_WritePin(LED_PORT, LED_PIN, GPIO_PIN_SET);    // Turn ON
}
#endif /* USE_FULL_ASSERT */