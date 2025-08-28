#include "idt.h"
#include "pic.h"
#include "keyboard.h"

// A dummy handler for CPU exceptions.
void fault_handler() {
    // For now, just hang.
    while(1);
}

// The main C-level handler for hardware interrupts.
void irq_handler() {
    // For now, we assume any IRQ is from the keyboard.
    // A proper implementation would check the interrupt number.
    keyboard_handler();
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
