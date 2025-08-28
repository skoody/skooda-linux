/*
 * linker.ld -- A simple linker script for our kernel.
 */
OUTPUT_FORMAT(elf32-i386)
ENTRY(start)

SECTIONS
{
    /* Set the location counter. This is where our kernel will be loaded. */
    . = 0x8000;

    /* Place the .text (code) section first. */
    .text :
    {
        *(.text)
    }

    /* Place the .data (initialized data) section after the code. */
    .data :
    {
        *(.data)
    }

    /* Place the .bss (uninitialized data) section last. */
    .bss :
    {
        *(.bss)
    }
}
