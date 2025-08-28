; =============================================================================
; gdt.asm: Global Descriptor Table (GDT) for our OS.
; =============================================================================

gdt_start:

; GDT Null Descriptor (required)
gdt_null:
    dd 0x0  ; define double word (4 bytes)
    dd 0x0

; GDT Code Segment Descriptor
; Base=0x0, Limit=0xFFFFF, Granularity=4KB, 32-bit
; Access Byte: Present=1, Ring=0, Type=System, Executable=1, Direction=0, R/W=1, Accessed=0
gdt_code:
    dw 0xFFFF    ; Limit (bits 0-15)
    dw 0x0000    ; Base (bits 0-15)
    db 0x00      ; Base (bits 16-23)
    db 0b10011010; Access Byte: P=1, DPL=00, S=1, E=1, DC=0, RW=1, A=0
    db 0b11001111; Granularity (4KB), 32-bit segment, Limit (bits 16-19)
    db 0x00      ; Base (bits 24-31)

; GDT Data Segment Descriptor
; Base=0x0, Limit=0xFFFFF, Granularity=4KB, 32-bit
; Access Byte: Present=1, Ring=0, Type=System, Executable=0, Direction=0, R/W=1, Accessed=0
gdt_data:
    dw 0xFFFF    ; Limit (bits 0-15)
    dw 0x0000    ; Base (bits 0-15)
    db 0x00      ; Base (bits 16-23)
    db 0b10010010; Access Byte: P=1, DPL=00, S=1, E=0, ED=0, RW=1, A=0
    db 0b11001111; Granularity (4KB), 32-bit segment, Limit (bits 16-19)
    db 0x00      ; Base (bits 24-31)

gdt_end:

; GDT Descriptor structure used by the LGDT instruction.
; It contains the size of the GDT (limit) and its linear address (base).
gdt_descriptor:
    dw gdt_end - gdt_start - 1 ; GDT Limit (size of the table minus one)
    dd gdt_start               ; GDT Base (linear address of gdt_start)

; Constants to calculate the selector offsets for our segments.
; The LGDT instruction loads the GDT descriptor, but then we need to load
; the segment selectors into the segment registers (CS, DS, etc.).
; The selector for the code segment is its offset from the start of the GDT.
CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start
