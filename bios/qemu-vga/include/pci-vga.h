#ifndef _SYS_PCI_VGA_H_
#define _SYS_PCI_VGA_H_

#include "common.h"

typedef struct vga_device vga_device_t;

typedef int (*vga_palette_write_t)(uint8_t *);
typedef int (*vga_fb_write_t)(uint8_t*);

typedef struct vga_device {
  vga_palette_write_t palette_write;
  vga_fb_write_t fb_write;
} vga_device_t;

#endif /* _SYS_VGA_H_ */
