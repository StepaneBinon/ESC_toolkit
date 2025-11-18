
main.o:     file format elf32-littlearm


Disassembly of section .text:

00000000 <main>:
#include <stdint.h>

int main(void)
{
   0:	b480      	push	{r7}
   2:	af00      	add	r7, sp, #0
    static uint32_t cnt = 0u;

    while(1)
    {
        cnt = cnt + 1;
   4:	4b02      	ldr	r3, [pc, #8]	; (10 <main+0x10>)
   6:	681b      	ldr	r3, [r3, #0]
   8:	3301      	adds	r3, #1
   a:	4a01      	ldr	r2, [pc, #4]	; (10 <main+0x10>)
   c:	6013      	str	r3, [r2, #0]
   e:	e7f9      	b.n	4 <main+0x4>
  10:	00000000 	.word	0x00000000
