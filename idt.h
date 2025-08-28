#ifndef IDT_H
#define IDT_H

#include <stdint.h> // For standard integer types

// Defines an entry in the Interrupt Descriptor Table.
struct idt_entry_struct {
    uint16_t base_lo;    // The lower 16 bits of the handler's address.
    uint16_t sel;        // The kernel segment selector.
    uint8_t  always0;    // This must always be zero.
    uint8_t  flags;      // Gate type, storage segment, DPL, and present bit.
    uint16_t base_hi;    // The upper 16 bits of the handler's address.
} __attribute__((packed)); // Prevent compiler padding.
typedef struct idt_entry_struct idt_entry_t;

// A pointer structure used by the LIDT instruction.
struct idt_ptr_struct {
    uint16_t limit;
    uint32_t base;       // The address of the first IDT entry.
} __attribute__((packed));
typedef struct idt_ptr_struct idt_ptr_t;

// The main function to initialize the IDT.
void idt_init();

#endif // IDT_H
