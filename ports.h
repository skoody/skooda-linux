#ifndef PORTS_H
#define PORTS_H

// Writes a byte to the specified hardware port.
static inline void outb(unsigned short port, unsigned char val) {
    asm volatile ("outb %0, %1" : : "a"(val), "Nd"(port));
}

// Reads a byte from the specified hardware port.
static inline unsigned char inb(unsigned short port) {
    unsigned char ret;
    asm volatile ("inb %1, %0" : "=a"(ret) : "Nd"(port));
    return ret;
}

#endif // PORTS_H
