#include "pic.h"
#include "ports.h"

// PIC port definitions
#define PIC1            0x20    // Master PIC base address
#define PIC2            0xA0    // Slave PIC base address
#define PIC1_COMMAND    PIC1
#define PIC1_DATA       (PIC1+1)
#define PIC2_COMMAND    PIC2
#define PIC2_DATA       (PIC2+1)

// End-of-Interrupt command
#define PIC_EOI         0x20

// --- PIC Functions ---

/*
 * Re-initializes the PICs, giving them specified vector offsets
 * rather than the default ones (0x08 and 0x70). This is required to
 * prevent conflicts with CPU exceptions.
 */
void PIC_remap(int offset1, int offset2) {
    // Save masks
    unsigned char a1 = inb(PIC1_DATA);
    unsigned char a2 = inb(PIC2_DATA);

    // Starts the initialization sequence (in cascade mode)
    outb(PIC1_COMMAND, 0x11); // ICW1
    outb(PIC2_COMMAND, 0x11); // ICW1

    // Define the PICs' vector offsets
    outb(PIC1_DATA, offset1); // ICW2: Master PIC vector offset
    outb(PIC2_DATA, offset2); // ICW2: Slave PIC vector offset

    // Tell Master PIC that there is a slave PIC at IRQ2 (0000 0100)
    outb(PIC1_DATA, 4);       // ICW3
    // Tell Slave PIC its cascade identity (0000 0010)
    outb(PIC2_DATA, 2);       // ICW3

    // Set 8086/88 (MCS-80/85) mode
    outb(PIC1_DATA, 0x01);    // ICW4
    outb(PIC2_DATA, 0x01);    // ICW4

    // Restore saved masks
    outb(PIC1_DATA, a1);
    outb(PIC2_DATA, a2);
}

/*
 * Sends an End-of-Interrupt (EOI) signal to the PICs.
 * If the IRQ came from the Slave PIC, an EOI must be sent to it first.
 */
void PIC_sendEOI(unsigned char irq) {
    if (irq >= 8) {
        outb(PIC2_COMMAND, PIC_EOI);
    }
    outb(PIC1_COMMAND, PIC_EOI);
}
