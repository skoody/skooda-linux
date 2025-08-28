#include "idt.h"
#include "pic.h"
#include "keyboard.h"
#include "common.h"

// A dummy handler for CPU exceptions.
void fault_handler(registers_t regs) {
    // For now, just hang. In the future, we would print error info.
    while(1);
}

// The main C-level handler for hardware interrupts.
// This function is called by the common IRQ stub in isr.asm.
void irq_handler(registers_t regs) {
    // First, send an EOI to the PICs.
    // If we don't, the PICs won't send any more IRQs.
    // The IRQ number is regs.int_no - 32.
    PIC_sendEOI(regs.int_no - 32);

    // Handle the specific interrupt.
    if (regs.int_no == 33) { // 33 is the keyboard
        keyboard_handler();
    }
}

/*
 * The main entry point for our C kernel.
 */
void main() {
    // Initialize all our interrupt-related hardware and software.
    idt_init();
    PIC_remap(32, 40); // Remap IRQs to start at interrupt 32

    // Initialize the keyboard
    keyboard_init();

    // Enable interrupts!
    asm volatile("sti");

    // Hang forever. The keyboard will now generate interrupts.
    while (1) {}
}
