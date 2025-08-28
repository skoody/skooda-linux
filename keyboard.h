#ifndef KEYBOARD_H
#define KEYBOARD_H

// Initializes the keyboard driver.
void keyboard_init();

// The C-level handler for keyboard interrupts.
void keyboard_handler();

#endif // KEYBOARD_H
