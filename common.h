#ifndef COMMON_H
#define COMMON_H

#include <stdint.h>

// This structure defines the registers that our ISR stubs push to the stack.
// The order is important.
typedef struct {
    uint32_t ds;                                      // Data segment selector
    uint32_t edi, esi, ebp, esp, ebx, edx, ecx, eax;    // Pushed by pushad
    uint32_t int_no, err_code;                         // Pushed by our ISR stubs
    uint32_t eip, cs, eflags, useresp, ss;             // Pushed by the processor automatically
} registers_t;

#endif // COMMON_H
