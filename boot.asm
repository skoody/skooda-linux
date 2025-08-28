; =============================================================================
; boot.asm: A 512-byte Stage 1 bootloader.
;
; This bootloader's only job is to load the kernel from the disk
; into memory at 0x100000 and then jump to it.
; =============================================================================

bits 16
[org 0x7c00]

; --- Constants ---
KERNEL_LOAD_ADDR equ 0x8000 ; Address to load the kernel to.
KERNEL_SECTORS_TO_READ equ 10  ; Number of sectors for the kernel

start:
    mov si, msg_loading
    call print_string

    ; Use legacy BIOS read (int 13h, ah=02h) to load our kernel.
    ; This is often more reliable in emulators than the extended read.
    mov ah, 0x02
    mov al, KERNEL_SECTORS_TO_READ
    mov ch, 0 ; Cylinder 0
    mov cl, 2 ; Start at Sector 2 (1 is the boot sector)
    mov dh, 0 ; Head 0
    ; DL = boot drive (already set by BIOS)
    ; ES:BX is the destination buffer. ES is already 0.
    mov bx, KERNEL_LOAD_ADDR ; Load to 0x0000:0x8000
    int 0x13
    jc load_error

    ; If loading was successful, jump to the kernel's load address
    jmp KERNEL_LOAD_ADDR

; Prints a null-terminated string using BIOS int 10h
print_string:
    mov ah, 0x0e
.loop:
    lodsb
    cmp al, 0
    je .done
    int 0x10
    jmp .loop
.done:
    ret

load_error:
    mov si, msg_failed
    call print_string
    jmp $ ; Hang forever

; --- Data ---
msg_loading db "Loading kernel...", 0x0d, 0x0a, 0
msg_failed db "Kernel load failed!", 0x0d, 0x0a, 0

; --- Padding and Magic Number ---
times 510 - ($ - $$) db 0
dw 0xaa55
