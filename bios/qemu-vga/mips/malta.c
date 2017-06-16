#include "mips/malta.h"
#include "pci.h"
#include "physmem.h"

#include <stdint.h>

extern uint8_t __bios_end[];

void pm_bootstrap(unsigned memsize) {
  pm_init();

  pm_seg_t *seg = (pm_seg_t *)__bios_end;
  size_t seg_size = align(pm_seg_space_needed(memsize), PAGESIZE);

  /* create Malta physical memory segment */
  pm_seg_init(seg, MALTA_PHYS_SDRAM_BASE, MALTA_PHYS_SDRAM_BASE + memsize,
              MIPS_KSEG0_START);

  /* reserve segment description space */
  pm_seg_reserve(seg, MIPS_KSEG0_TO_PHYS((intptr_t)seg),
                 MIPS_KSEG0_TO_PHYS((intptr_t)seg + seg_size));
  pm_add_segment(seg);
}

/* Normally this file an intialization procedure would not exits! This is barely
   a substitute for currently unimplemented device-driver matching mechanism. */

extern pci_bus_device_t gt_pci;
extern int stdvga_pci_attach(pci_device_t *pci, unsigned width, unsigned height);

void platform_init(unsigned width, unsigned height, unsigned memsize)
{
  pci_device_t *pcidev;

  pm_bootstrap(memsize);
  pci_init();

  TAILQ_FOREACH (pcidev, &gt_pci.devices, link) {
      /* Try initializing it as an stdvga device. */
      stdvga_pci_attach(pcidev, width, height);
  }
}
