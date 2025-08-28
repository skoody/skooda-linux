#include "keyboard.h"
#include "ports.h"
#include "pic.h"
#include <stdint.h>

// --- Globals for screen state ---
volatile unsigned short* video_memory = (unsigned short*)0xB8000;
int cursor_x = 0;
int cursor_y = 0;

// --- Scancode to ASCII map (US QWERTY) ---
// Only handles key presses, not releases.
const char scancode_map[128] = {
    0,  27, '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', '=', '\b',
    '\t', 'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', '[', ']', '\n',
    0, 'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';', '\'', '`',
    0, '\\', 'z', 'x', 'c', 'v', 'b', 'n', 'm', ',', '.', '/', 0,
    '*', 0, ' ', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '-',
    0, 0, 0, '+', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
};

// --- Private functions ---

// Simple function to print a character and handle cursor.
static void print_char(char c) {
    if (c == '\n') {
        cursor_x = 0;
        cursor_y++;
    } else if (c == '\b') {
        if (cursor_x > 0) {
            cursor_x--;
            video_memory[cursor_y * 80 + cursor_x] = ' ' | (0x0F << 8);
        }
    } else {
        video_memory[cursor_y * 80 + cursor_x] = c | (0x0F << 8);
        cursor_x++;
    }

    if (cursor_x >= 80) {
        cursor_x = 0;
        cursor_y++;
    }
    // TODO: Add scrolling when cursor_y >= 25
}

// --- Public functions ---

void keyboard_init() {
    // Nothing to do for now.
}

// This is the C-level handler called by the assembly stub (irq1).
void keyboard_handler() {
    unsigned char scancode = inb(0x60);

    // We only handle key presses for now (scancode < 128).
    if (scancode < 128) {
        print_char(scancode_map[scancode]);
    }

    // Send End-of-Interrupt to the PIC
    PIC_sendEOI(1);
}
