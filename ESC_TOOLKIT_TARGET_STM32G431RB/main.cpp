#include <stdint.h>

int main(void)
{
    static uint32_t var_a = 0u;
    static uint32_t var_b = 0u;
    static uint32_t var_c = 0u;
    
    while(1)
    {
        var_a = var_a + 1;
        var_b = var_b + 2;
        var_c = var_c + 3;
    }
}