; =============================================================================
; A simple 16-bit bootloader for our OS.
;
; - Sets up basic segment registers.
; - Initializes the COM1 serial port for output.
; - Prints a message to the VGA display (screen).
; - Prints the same message to the serial port (for verification).
; - Halts the CPU.
; =============================================================================

[org 0x7c00]    ; The BIOS loads us at this address.

; --- Entry Point ---
start:
    ; Set up segment registers. BIOS guarantees CS=0, IP=0x7c00.
    ; We'll set DS and ES to 0 as well for a flat memory model.
    xor ax, ax
    mov ds, ax
    mov es, ax

    ; Initialize the serial port (COM1) for logging.
    ; This is how we'll verify execution in QEMU.
    call init_serial

    ; Print our welcome message to the screen.
    mov si, msg_hello
    call print_string_vga

    ; Print our welcome message to the serial port.
    mov si, msg_hello
    call print_string_serial

    ; Hang the system.
hang:
    jmp hang


; --- Subroutines ---

; Initializes COM1 serial port at 0x3f8.
init_serial:
    mov dx, 0x3f8 + 1  ; Interrupt Enable Register
    mov al, 0x00       ; Disable all interrupts
    out dx, al
    mov dx, 0x3f8 + 3  ; Line Control Register
    mov al, 0x80       ; Enable DLAB (to set baud rate)
    out dx, al
    mov dx, 0x3f8 + 0  ; Divisor Latch Low Byte
    mov al, 12         ; Set baud rate to 9600 (115200 / 12)
    out dx, al
    mov dx, 0x3f8 + 1  ; Divisor Latch High Byte
    mov al, 0x00
    out dx, al
    mov dx, 0x3f8 + 3  ; Line Control Register
    mov al, 0x03       ; 8 bits, no parity, one stop bit (8N1)
    out dx, al
    ret

; Prints a null-terminated string from SI to the VGA display.
print_string_vga:
    mov ah, 0x0e       ; BIOS teletype function
.loop:
    lodsb              ; Load character from [SI] into AL, then increment SI
    cmp al, 0          ; Check for null terminator
    je .done
    int 0x10           ; Call BIOS video interrupt to print the character
    jmp .loop
.done:
    ret

; Prints a null-terminated string from SI to the serial port.
print_string_serial:
.loop:
    lodsb              ; Load character from [SI] into AL, then increment SI
    cmp al, 0          ; Check for null terminator
    je .done
    call print_char_serial ; Print the character
    jmp .loop
.done:
    ret

; Transmits a single character from AL over the serial port.
; NOTE: Preserves AX on the stack because the character is in AL.
print_char_serial:
    push ax            ; Save AX (which contains our character in AL) onto the stack.

    mov dx, 0x3f8 + 5  ; Line Status Register
.wait:
    in al, dx          ; Read status into AL. This overwrites our char, but it's saved.
    and al, 0x20       ; Check if the transmitter holding register is empty.
    jz .wait           ; Loop until the serial port is ready.

    pop ax             ; Restore our original character from the stack back into AX.
    mov dx, 0x3f8      ; Data Register
    out dx, al         ; Send the character.
    ret


; --- Data ---

msg_hello:
    db "Hello from our new OS!", 0x0d, 0x0a, 0  ; Message, carriage return, newline, null terminator.


; --- Bootloader Signature ---

; Pad the rest of the file with zeros to make it 512 bytes long.
; `$` is the current address, `$$` is the starting address (0x7c00).
; `($-$$)` calculates the size of the code and data so far.
times 510 - ($ - $$) db 0

; The boot signature must be the last two bytes.
dw 0xaa55
