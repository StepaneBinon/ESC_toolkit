/**
 * 
 * 
 */

#ifndef IGPIO_HPP
#define IGPIO_HPP

// #include <cstdint>

namespace pal
{

enum class gpio_port 
{
    GPIO_PORT_A = 0
};

enum class gpio_bit
{
    GPIO_BIT_1 = 0
};

// A pin is a port+bit of GPIO
enum class gpio_pin_mode    
{
    GPIO_OUTPUT = 0,
    GPIO_INPUT,
    GPIO_ALTERNATE_FUNCTION
};

enum class gpio_pin_output_speed 
{
    LOW = 0, 
    MEDIUM,
    HIGH, 
    VERY_HIGH
};

/**
 * @brief Pure interface for zero crossing detection.
 * 
 * @tparam Measures Type representing sensor measurement (e.g. voltage).
 */
template <typename Params>
class IGPIO
{
public:
    // ----------------- Ctors / Dtors -----------------
    IGPIO() noexcept = default;
    IGPIO(const IGPIO&) = default;
    IGPIO(IGPIO&&) noexcept = default;
    IGPIO& operator=(const IGPIO&) = default;
    IGPIO& operator=(IGPIO&&) = default;
    virtual ~IGPIO() = default;

    // ----------------- Methods -----------------
};

}

#endif // IGPIO_HPP