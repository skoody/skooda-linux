; =============================================================================
; kernel_entry.asm: The entry point for the kernel.
;
; This code is loaded by the bootloader to 0x100000. It handles the
; switch to protected mode and then calls the main C function.
; =============================================================================

bits 16

global start    ; Make the start label visible to the linker
start:
    ; This code starts executing in 16-bit real mode, having been
    ; jumped to by the bootloader.

    ; 1. Enable the A20 line
    call enable_a20

    ; 2. Load the GDT
    cli ; Disable interrupts before loading GDT
    lgdt [dword gdt_descriptor] ; Use a 32-bit address override

    ; 3. Switch to Protected Mode
    mov eax, cr0
    or eax, 0x1 ; Set the PE (Protection Enable) bit
    mov cr0, eax

    ; Far jump to flush the CPU pipeline and enter 32-bit code.
    ; We use an indirect jump with a pointer to avoid linker relocation errors.
    jmp far [protected_mode_ptr]

; Include the GDT file. The addresses in gdt_descriptor will be correct
; because this file is linked to run at 0x100000.
%include "gdt.asm"

; --- Data for the far jump ---
protected_mode_ptr:
    dd start_protected_mode ; 32-bit address of our protected mode code
    dw CODE_SEG             ; 16-bit code segment selector

; --- Helper functions (A20 gate) ---
enable_a20:
    call a20_wait_input
    mov al, 0xAD ; Command: disable keyboard
    out 0x64, al

    call a20_wait_input
    mov al, 0xD0 ; Command: read output port
    out 0x64, al

    call a20_wait_output
    in al, 0x60
    push eax

    call a20_wait_input
    mov al, 0xD1 ; Command: write output port
    out 0x64, al

    call a20_wait_input
    pop eax
    or al, 2 ; Set bit 1 (the A20 gate)
    out 0x60, al

    call a20_wait_input
    mov al, 0xAE ; Command: enable keyboard
    out 0x64, al

    call a20_wait_input
    ret

a20_wait_input:
    in al, 0x64
    test al, 2 ; Test input buffer status bit
    jnz a20_wait_input
    ret

a20_wait_output:
    in al, 0x64
    test al, 1 ; Test output buffer status bit
    jz a20_wait_output
    ret

; --- 32-bit Protected Mode Code ---
bits 32
start_protected_mode:
    ; Set up the data segment registers
    mov ax, DATA_SEG
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    ; Set up a stack
    mov ebp, 0x90000
    mov esp, ebp

    ; Call the external C main function
    extern main
    call main

    ; Hang if the kernel returns
    jmp $
