; =============================================================================
; isr.asm: Low-level Interrupt Service Routine (ISR) stubs.
; =============================================================================

; These stubs are the entry points for interrupts. They save the CPU state
; and then call a higher-level C handler.

; --- Externals ---
extern fault_handler ; C-level handler for CPU exceptions
extern irq_handler   ; C-level handler for hardware interrupts

; --- Macros ---

; Macro to generate a stub for an ISR that does not push an error code.
%macro ISR_NO_ERR_CODE 1
    global isr%1
    isr%1:
        cli          ; Disable interrupts
        push byte 0  ; Push a dummy error code
        push byte %1 ; Push the interrupt number
        jmp isr_common_stub
%endmacro

; Macro to generate a stub for an ISR that pushes an error code.
%macro ISR_ERR_CODE 1
    global isr%1
    isr%1:
        cli          ; Disable interrupts
        push byte %1 ; Push the interrupt number
        jmp isr_common_stub
%endmacro

; Macro for hardware interrupt (IRQ) handlers.
%macro IRQ 2
    global irq%1
    irq%1:
        cli
        push byte 0
        push byte %2
        jmp irq_common_stub
%endmacro

; --- Common Stubs ---

; This common stub is called by all CPU exception ISRs.
isr_common_stub:
    pushad      ; Pushes edi,esi,ebp,esp,ebx,edx,ecx,eax

    mov ax, ds  ; Lower 16-bits of eax = ds.
    push eax    ; save the data segment descriptor

    mov ax, 0x10 ; Load the kernel data segment descriptor
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    call fault_handler

    pop ebx     ; Pop the saved data segment descriptor
    mov ds, bx
    mov es, bx
    mov fs, bx
    mov gs, bx

    popad       ; Pops edi,esi,ebp,esp,ebx,edx,ecx,eax
    add esp, 8  ; Cleans up the pushed error code and ISR number
    iret        ; Return from interrupt

; This common stub is called by all hardware IRQ handlers.
irq_common_stub:
    pushad

    mov ax, ds
    push eax

    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    call irq_handler

    pop ebx
    mov ds, bx
    mov es, bx
    mov fs, bx
    mov gs, bx

    popad
    add esp, 8
    iret

; --- ISR Definitions ---

; 32 CPU exceptions
ISR_NO_ERR_CODE 0  ; 0 - Division by zero
ISR_NO_ERR_CODE 1  ; 1 - Debug
ISR_NO_ERR_CODE 2  ; 2 - Non-maskable Interrupt
ISR_NO_ERR_CODE 3  ; 3 - Breakpoint
ISR_NO_ERR_CODE 4  ; 4 - Overflow
ISR_NO_ERR_CODE 5  ; 5 - Bound Range Exceeded
ISR_NO_ERR_CODE 6  ; 6 - Invalid Opcode
ISR_NO_ERR_CODE 7  ; 7 - Device Not Available
ISR_ERR_CODE    8  ; 8 - Double Fault
ISR_NO_ERR_CODE 9  ; 9 - Coprocessor Segment Overrun
ISR_ERR_CODE    10 ; 10 - Invalid TSS
ISR_ERR_CODE    11 ; 11 - Segment Not Present
ISR_ERR_CODE    12 ; 12 - Stack-Segment Fault
ISR_ERR_CODE    13 ; 13 - General Protection Fault
ISR_ERR_CODE    14 ; 14 - Page Fault
ISR_NO_ERR_CODE 15 ; 15 - Reserved
ISR_NO_ERR_CODE 16 ; 16 - x87 Floating-Point Exception
ISR_ERR_CODE    17 ; 17 - Alignment Check
ISR_NO_ERR_CODE 18 ; 18 - Machine Check
ISR_NO_ERR_CODE 19 ; 19 - SIMD Floating-Point Exception
ISR_NO_ERR_CODE 20 ; 20 - Virtualization Exception
ISR_NO_ERR_CODE 21 ; 21 - Control Protection Exception
ISR_NO_ERR_CODE 22 ; 22 - Reserved
ISR_NO_ERR_CODE 23 ; 23 - Reserved
ISR_NO_ERR_CODE 24 ; 24 - Reserved
ISR_NO_ERR_CODE 25 ; 25 - Reserved
ISR_NO_ERR_CODE 26 ; 26 - Reserved
ISR_NO_ERR_CODE 27 ; 27 - Reserved
ISR_NO_ERR_CODE 28 ; 28 - Reserved
ISR_NO_ERR_CODE 29 ; 29 - Reserved
ISR_NO_ERR_CODE 30 ; 30 - Reserved
ISR_NO_ERR_CODE 31 ; 31 - Reserved

; Hardware IRQs (we will map them to 32-47)
IRQ 0, 32  ; Timer
IRQ 1, 33  ; Keyboard
IRQ 2, 34
IRQ 3, 35
IRQ 4, 36
IRQ 5, 37
IRQ 6, 38
IRQ 7, 39
IRQ 8, 40
IRQ 9, 41
IRQ 10, 42
IRQ 11, 43
IRQ 12, 44
IRQ 13, 45
IRQ 14, 46
IRQ 15, 47
