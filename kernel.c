/*
 * kernel.c - A simple C kernel.
 *
 * This kernel is entered in 32-bit protected mode. Its only job is to
 * write a message to the screen to prove that it's running.
 */

// A pointer to the VGA text mode buffer.
volatile unsigned short* video_memory = (unsigned short*)0xB8000;

/*
 * The main entry point for our C kernel.
 * This function is called from the bootloader.
 */
void main() {
    const char* message = "Hello from C Kernel!";
    int i = 0;

    // The color code: white text (0xF) on a black background (0x0).
    unsigned char color_byte = 0x0F;

    // Write each character of the message to video memory.
    // Each character cell is 2 bytes: [Color Byte | ASCII Char].
    while (message[i] != '\0') {
        // The character is in the low byte, color in the high byte.
        unsigned short character = message[i];
        unsigned short attribute = color_byte << 8;
        video_memory[i] = character | attribute;
        i++;
    }

    // Hang forever.
    while (1) {}
}
