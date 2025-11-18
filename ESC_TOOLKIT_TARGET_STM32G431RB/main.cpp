#include <stdint.h>

int main(void)
{
    static uint32_t cnt = 0u;

    while(1)
    {
        cnt = cnt + 1;
    }
}