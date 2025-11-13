/* STM32G431xx — set sizes to your exact variant */
MEMORY
{
  FLASH (rx)  : ORIGIN = 0x08000000, LENGTH = 128K  /* set 64K/128K/256K as needed */
  RAM   (rwx) : ORIGIN = 0x20000000, LENGTH = 32K   /* set to your SRAM size */
}

/* Provide a default stack top at end of RAM */
_estack = ORIGIN(RAM) + LENGTH(RAM);