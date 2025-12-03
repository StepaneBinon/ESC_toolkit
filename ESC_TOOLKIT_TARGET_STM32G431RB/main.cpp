#include "main.hpp"
#include <cstdint>
#include <cstdlib>
#include <optional>
#include <iostream>
#include "stm32g4xx_hal.h"
// #include "stm32g4xx_it.h"

#define MOSFET_PORT GPIOB
#define AH GPIO_PIN_10
#define AL GPIO_PIN_11
#define BH GPIO_PIN_12
#define BL GPIO_PIN_13
#define CH GPIO_PIN_14
#define CL GPIO_PIN_15
#define MOSFET_MASK AH|AL|BH|BL|CH|CL 

#define DEAD_TIME 18
#define PWM_OFF 1000
#define V_HYST 1000

#define LED_PIN GPIO_PIN_5
#define LED_PORT GPIOA

void SystemClock_Config(void);
void GPIO_Init(void);

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

static inline uint32_t MOSFET_WriteAll(uint32_t phase_pattern) {
    uint32_t bsrr_value = 0;
    
    bsrr_value |= ((phase_pattern) & MOSFET_MASK);
    bsrr_value |= (((~phase_pattern) & MOSFET_MASK) << 16);
    
    MOSFET_PORT->BSRR = bsrr_value;
}

int main(void)
{
    // Initialize HAL library
    HAL_Init();
    // Configure system clock
    SystemClock_Config();
    // Initialize GPIO for LED
    GPIO_Init();
    // Init timers
    DWT_Init();

    // Blink through each pin one at a time
    while (1) {
        uint32_t phase_pattern = SSC(Sector::S0);
        MOSFET_WriteAll(phase_pattern);
        HAL_GPIO_WritePin(LED_PORT, LED_PIN, GPIO_PIN_SET);    // Turn ON
        HAL_Delay(500);
        MOSFET_WriteAll(phase_pattern << 16);
        HAL_GPIO_WritePin(LED_PORT, LED_PIN, GPIO_PIN_RESET);  // Turn OFF
        HAL_Delay(500);
    }
}

// int main(void)
// {
//     // Initialize HAL library
//     HAL_Init();
//     // Configure system clock
//     SystemClock_Config();
//     // Initialize GPIO for LED
//     GPIO_Init();
//     // Init timers
//     DWT_Init();

//     // uint32_t pattern = 0x21;
//     // uint32_t odr = 0;
//     // MOSFET_PORT->BSRR = 0x0000;
//     // while (1) {
//     //     // MOSFET_WriteAll(pattern);
//     //     // pattern++;
//     //     odr = GPIOB->ODR;
//     //     HAL_GPIO_WritePin(GPIOB, GPIO_PIN_All, GPIO_PIN_SET);
//     //     odr = GPIOB->ODR;
//     //     HAL_Delay(500);
//     //     HAL_GPIO_WritePin(GPIOB, GPIO_PIN_All, GPIO_PIN_RESET);
//     //     odr = GPIOB->ODR;
//     //     HAL_Delay(500);
//     // }

//     uint32_t tcom_last = DWT_GetCycles();
//     uint32_t cmd_array = 0b100001;
//     while(1)
//     {
//         uint32_t tcom_curr = DWT_GetCycles();
//         int32_t v_bus = 222; //V
//         Sector sector_prev = Sector::S0; 
//         int32_t v_ph = 222; //V
//         Sign sign_prev = Sign::Negi;
//         uint32_t timer = 100000;

//         const auto temp = getCmdArray(tcom_last, tcom_curr, v_bus, sector_prev, v_ph, sign_prev, timer);
//         if (!temp.has_value()) {
//             continue;
//         }
//         cmd_array = temp.value();

//         HAL_GPIO_WritePin(LED_PORT, LED_PIN, GPIO_PIN_SET);    // Turn ON
//         HAL_Delay(500);
//         HAL_GPIO_WritePin(LED_PORT, LED_PIN, GPIO_PIN_RESET);  // Turn OFF
//         HAL_Delay(500);
//         tcom_curr = DWT_GetCycles();
//     }
// }

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
    if (HAL_RCC_OscConfig(&RCC_OscInitStruct) != HAL_OK)
    {
        Error_Handler();
    }

    /** Initializes the CPU, AHB and APB buses clocks
     */
    RCC_ClkInitStruct.ClockType = RCC_CLOCKTYPE_HCLK|RCC_CLOCKTYPE_SYSCLK|RCC_CLOCKTYPE_PCLK1|RCC_CLOCKTYPE_PCLK2;
    RCC_ClkInitStruct.SYSCLKSource = RCC_SYSCLKSOURCE_PLLCLK;
    RCC_ClkInitStruct.AHBCLKDivider = RCC_SYSCLK_DIV1;
    RCC_ClkInitStruct.APB1CLKDivider = RCC_HCLK_DIV1;
    RCC_ClkInitStruct.APB2CLKDivider = RCC_HCLK_DIV1;

    if (HAL_RCC_ClockConfig(&RCC_ClkInitStruct, FLASH_LATENCY_4) != HAL_OK)
    {
        Error_Handler();
    }
}

void GPIO_Init(void)
{
    GPIO_InitTypeDef GPIO_InitStruct = {0};
    
    // Enable GPIO clock (change based on your port)
    __HAL_RCC_GPIOA_CLK_ENABLE();
    __HAL_RCC_GPIOB_CLK_ENABLE();
    
    // Configure LED pin
    GPIO_InitStruct.Pin = LED_PIN;
    GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP;  // Push-pull output
    GPIO_InitStruct.Pull = GPIO_NOPULL;
    GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_VERY_HIGH;
    HAL_GPIO_Init(LED_PORT, &GPIO_InitStruct);

    // Configure PORT_B pins
    GPIO_InitStruct.Pin = GPIO_PIN_10;
    GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP;  // Push-pull output
    GPIO_InitStruct.Pull = GPIO_NOPULL;
    GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_VERY_HIGH;
    HAL_GPIO_Init(GPIOB, &GPIO_InitStruct);
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