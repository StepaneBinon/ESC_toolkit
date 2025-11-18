/* Minimal STM32G4 linker script */

/* Set the entry point */
ENTRY(Reset_Handler) 

/* Memory map: adjust sizes if needed */
MEMORY
{
  FLASH (rx)  : ORIGIN = 0x08000000, LENGTH = 128K
  RAM   (xrw) : ORIGIN = 0x20000000, LENGTH = 32K
}

/* Top (end) of stack (used in vector table) */
_estack = ORIGIN(RAM) + LENGTH(RAM);

SECTIONS
{
  /* Vector table at start of flash */
  .isr_vector :
  {
    KEEP(*(.isr_vector)) /* KEEP = not discard the section even if unused */
  } > FLASH

  /* Code + const data in flash */
  .text :
  {
    *(.text*)            /* code */
    *(.rodata*)          /* const data */
    KEEP(*(.init))
    KEEP(*(.fini))
  } > FLASH

  /* Initialised data in RAM, image stored in FLASH */
  .data : AT (ADDR(.text) + SIZEOF(.text))
  {
    _sdata = .;          /* start of .data in RAM */
    *(.data*)
    _edata = .;          /* end of .data in RAM */
  } > RAM
  _sidata = LOADADDR(.data);   /* start of .data init values in FLASH */

  /* Zero-init data in RAM */
  .bss (NOLOAD) :
  {
    _sbss = .;
    *(.bss*)
    *(COMMON)
    _ebss = .;
  } > RAM
}