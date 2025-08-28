#ifndef PIC_H
#define PIC_H

void PIC_remap(int offset1, int offset2);
void PIC_sendEOI(unsigned char irq);

#endif // PIC_H
