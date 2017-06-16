#include "pci.h"
#include "pci-vga.h"
#include <string.h>
//#include <stdc.h>
//#include <malloc.h>


#define VGA_PALETTE_SIZE (256u * 3)

typedef struct stdvga_device {
  pci_device_t *pci_device;
  resource_t *mem;
  resource_t *io;

  unsigned int width;
  unsigned int height;

  vga_device_t vga;
} stdvga_device_t;

static stdvga_device_t stdvga[1];

/* Detailed information about VGA registers is available at
   http://www.osdever.net/FreeVGA/vga/vga.htm */

#define VGA_PALETTE_ADDR 0x3C8
#define VGA_PALETTE_DATA 0x3C9
#define VGA_AR_ADDR 0x3C0
#define VGA_AR_PAS 0x20 /* Palette Address Source bit */

/* Bochs VBE. Simplifies VGA graphics mode configuration a great deal. Some
   documentation is available at http://wiki.osdev.org/Bochs_VBE_Extensions */
#define VBE_DISPI_INDEX_XRES 0x01
#define VBE_DISPI_INDEX_YRES 0x02
#define VBE_DISPI_INDEX_BPP 0x03
#define VBE_DISPI_INDEX_ENABLE 0x04
#define VBE_DISPI_ENABLED 0x01 /* VBE Enabled bit */

/* Offsets for accessing ioports via PCI BAR1 (MMIO) */
#define VGA_MMIO_OFFSET (0x400 - 0x3c0)
#define VBE_MMIO_OFFSET 0x500

/* The general overview of the QEMU std vga device is available at
   https://github.com/qemu/qemu/blob/master/docs/specs/standard-vga.txt */
#define VGA_QEMU_STDVGA_VENDOR_ID 0x1234
#define VGA_QEMU_STDVGA_DEVICE_ID 0x1111

static void stdvga_io_write(stdvga_device_t *vga, uint16_t reg, uint8_t value) {
  bus_space_write_1(vga->io, reg + VGA_MMIO_OFFSET, value);
}
static uint8_t __unused stdvga_io_read(stdvga_device_t *vga, uint16_t reg) {
  return bus_space_read_1(vga->io, reg + VGA_MMIO_OFFSET);
}
static void stdvga_vbe_write(stdvga_device_t *vga, uint16_t reg,
                             uint16_t value) {
  /* <<1 shift enables access to 16-bit registers. */
  bus_space_write_2(vga->io, (reg << 1) + VBE_MMIO_OFFSET, value);
}
static uint16_t stdvga_vbe_read(stdvga_device_t *vga, uint16_t reg) {
  return bus_space_read_2(vga->io, (reg << 1) + VBE_MMIO_OFFSET);
}

static void stdvga_palette_write_single(stdvga_device_t *stdvga, uint8_t offset,
                                        uint8_t r, uint8_t g, uint8_t b) {
  stdvga_io_write(stdvga, VGA_PALETTE_ADDR, offset);
  stdvga_io_write(stdvga, VGA_PALETTE_DATA, r >> 2);
  stdvga_io_write(stdvga, VGA_PALETTE_DATA, g >> 2);
  stdvga_io_write(stdvga, VGA_PALETTE_DATA, b >> 2);
}

static void stdvga_palette_write_buffer(stdvga_device_t *stdvga,
                                        const uint8_t buf[VGA_PALETTE_SIZE]) {
  for (unsigned i = 0; i < VGA_PALETTE_SIZE / 3; i++)
    stdvga_palette_write_single(stdvga, i, buf[3 * i + 0], buf[3 * i + 1],
                                buf[3 * i + 2]);
}

int stdvga_palette_write(uint8_t *buf) {
  /* TODO: Only update the modified area. */
  stdvga_palette_write_buffer(stdvga, buf);
  return 0;
}

int stdvga_fb_write(uint8_t *buf) {
  bus_space_write_region_1(stdvga->mem, 0, buf,
                           stdvga->width * stdvga->height);
  return 0;
}

int stdvga_pci_attach(pci_device_t *pci, unsigned width, unsigned height) {
  if (pci->vendor_id != VGA_QEMU_STDVGA_VENDOR_ID ||
      pci->device_id != VGA_QEMU_STDVGA_DEVICE_ID)
    return 0;

  /* TODO: Enabling PCI regions should probably be performed by PCI bus resource
   * reservation code. */
  uint16_t command = pci_read_config(pci, PCIR_COMMAND, 2);
  command |= PCIM_CMD_PORTEN | PCIM_CMD_MEMEN;
  pci_write_config(pci, PCIR_COMMAND, 2, command);

  assert(pci->bar[0].r_flags | RF_PREFETCHABLE);
  /* TODO: This will get replaced by bus_alloc_resource* function */
  stdvga->mem = &pci->bar[0];
  stdvga->io = &pci->bar[1];

  /* Switching output resolution is straightforward - but not implemented since
     we don't need it ATM. */
  stdvga->width = width;
  stdvga->height = height;

  stdvga->vga = (vga_device_t){
    .palette_write = stdvga_palette_write, .fb_write = stdvga_fb_write,
  };

  /* Apply resolution */
  stdvga_vbe_write(stdvga, VBE_DISPI_INDEX_XRES, stdvga->width);
  stdvga_vbe_write(stdvga, VBE_DISPI_INDEX_YRES, stdvga->height);

  /* Enable palette access */
  stdvga_io_write(stdvga, VGA_AR_ADDR, VGA_AR_PAS);

  /* Set 8 BPP */
  stdvga_vbe_write(stdvga, VBE_DISPI_INDEX_BPP, 8);

  /* Enable VBE. */
  stdvga_vbe_write(stdvga, VBE_DISPI_INDEX_ENABLE,
                   stdvga_vbe_read(stdvga, VBE_DISPI_INDEX_ENABLE) |
                     VBE_DISPI_ENABLED);

  /* Install /dev/vga interace. */
  //dev_vga_install(&stdvga->vga);

  return 1;
}
