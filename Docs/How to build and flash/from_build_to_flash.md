First code to compile in `main.cpp`
```cpp
#include <stdint.h>

int main(void)
{
    static uint32_t cnt = 0u;

    while(1)
    {
        cnt = cnt + 1;
    }
}
```

To build
```bash
arm-none-eabi-gcc \
  -mcpu=cortex-m4 -mthumb \
  -std=c++17 -O0 -g \
  -ffreestanding -nostdlib \
  -c main.cpp -o main.o
# -mcpu=cortex-m4 : generate code for Cortex-M4.
# -mthumb : use Thumb instruction set (what Cortex-M actually runs).
# -O0 : no optimizations, so the assembly is “literal” and easier to read.
# -g : include debug info (handy later with GDB).
# -ffreestanding : tell the compiler there is no hosted OS, no normal main/argc/argv conventions.
# -nostdlib : don’t try to link libc, libstdc++, etc.
```

To disassemble
```bash 
arm-none-eabi-objdump -d -S main.o > main.asm
```

Which gives
```asm
0:	b480      	push	{r7}        ; increment sp (stack ptr) by 4 bytes and save r7 at stack top, to be devel after the function as ended
2:	af00      	add	r7, sp, #0      ; set r7 as the fp (frame ptr) for this funtion (add r7 = sp + 0x0 = sp)
4:	4b02      	ldr	r3, [pc, #8]	; (10 <main+0x10>)
6:	681b      	ldr	r3, [r3, #0]
8:	3301      	adds	r3, #1
a:	4a01      	ldr	r2, [pc, #4]	; (10 <main+0x10>)
c:	6013      	str	r3, [r2, #0]
e:	e7f9      	b.n	4 <main+0x4>
10:	00000000 	.word	0x00000000
```
