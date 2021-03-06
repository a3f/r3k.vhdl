#include "mips/gt64120.h"
#include "pci.h"

#define PCI0_CFG_ADDR_R GT_R(GT_PCI0_CFG_ADDR)
#define PCI0_CFG_DATA_R GT_R(GT_PCI0_CFG_DATA)

#define PCI0_CFG_REG_SHIFT 2
#define PCI0_CFG_FUNCT_SHIFT 8
#define PCI0_CFG_DEV_SHIFT 11
#define PCI0_CFG_BUS_SHIFT 16
#define PCI0_CFG_ENABLE 0x80000000

static unsigned gt_pci_make_addr(pci_device_t *dev, unsigned reg) {
  return (((dev->addr.device) << PCI0_CFG_DEV_SHIFT) |
          ((dev->addr.function) << PCI0_CFG_FUNCT_SHIFT) |
          ((reg) << PCI0_CFG_REG_SHIFT));
}

typedef union {
  uint8_t byte[4];
  uint16_t word[2];
  uint32_t dword;
} pci_reg_t;

/* Access configuration space through memory mapped GT-64120 registers. Take
 * care of the fact that MIPS processor cannot handle unaligned accesses. */
static uint32_t gt_pci_read_config(pci_device_t *dev, unsigned reg,
                                   unsigned size) {
  if (dev->addr.bus > 0)
    return -1;

  PCI0_CFG_ADDR_R = PCI0_CFG_ENABLE | gt_pci_make_addr(dev, reg >> 2);
  pci_reg_t data = (pci_reg_t)PCI0_CFG_DATA_R;
  reg &= 3;
  switch (size) {
    case 1:
      return data.byte[3 - reg];
    case 2:
      return data.word[1 - (reg >> 1)];
    case 4:
      return data.dword;
    default:
      return -1;
  }
}

static void gt_pci_write_config(pci_device_t *dev, unsigned reg, unsigned size,
                                uint32_t value) {
  if (dev->addr.bus > 0)
    return;

  PCI0_CFG_ADDR_R = PCI0_CFG_ENABLE | gt_pci_make_addr(dev, reg >> 2);
  pci_reg_t data = (pci_reg_t)PCI0_CFG_DATA_R;
  reg &= 3;
  switch (size) {
    case 1:
      data.byte[3 - reg] = value;
    case 2:
      data.word[1 - (reg >> 1)] = value;
    case 4:
      data.dword = value;
    default:
      break;
  }
  PCI0_CFG_DATA_R = data.dword;
}

static uint8_t gt_pci_read_1(resource_t *handle, unsigned offset) {
  intptr_t addr = handle->r_start + offset;
  return *(volatile uint8_t *)MIPS_PHYS_TO_KSEG1(addr);
}

static void gt_pci_write_1(resource_t *handle, unsigned offset, uint8_t value) {
  intptr_t addr = handle->r_start + offset;
  *(volatile uint8_t *)MIPS_PHYS_TO_KSEG1(addr) = value;
}

static uint16_t gt_pci_read_2(resource_t *handle, unsigned offset) {
  intptr_t addr = handle->r_start + offset;
  return *(volatile uint16_t *)MIPS_PHYS_TO_KSEG1(addr);
}

static void gt_pci_write_2(resource_t *handle, unsigned offset,
                           uint16_t value) {
  intptr_t addr = handle->r_start + offset;
  *(volatile uint16_t *)MIPS_PHYS_TO_KSEG1(addr) = value;
}

static void gt_pci_read_region_1(resource_t *handle, unsigned offset,
                                 uint8_t *dst, size_t count) {
  uint8_t *src = (uint8_t *)MIPS_PHYS_TO_KSEG1(handle->r_start + offset);
  for (size_t i = 0; i < count; i++)
    *dst++ = *src++;
}

static void gt_pci_write_region_1(resource_t *handle, unsigned offset,
                                  const uint8_t *src, size_t count) {
  uint8_t *dst = (uint8_t *)MIPS_PHYS_TO_KSEG1(handle->r_start + offset);
  for (size_t i = 0; i < count; i++)
    *dst++ = *src++;
}

static bus_space_t gt_pci_bus_space = {.read_1 = gt_pci_read_1,
                                       .write_1 = gt_pci_write_1,
                                       .read_2 = gt_pci_read_2,
                                       .write_2 = gt_pci_write_2,
                                       .read_region_1 = gt_pci_read_region_1,
                                       .write_region_1 = gt_pci_write_region_1};

static pci_bus_t gt_pci_bus = {.read_config = gt_pci_read_config,
                               .write_config = gt_pci_write_config};
static resource_t gt_pci_memory = {.r_bus_space = &gt_pci_bus_space,
                                   .r_type = RT_MEMORY,
                                   .r_start = MALTA_PCI0_MEMORY_BASE,
                                   .r_end = MALTA_PCI0_MEMORY_END};
static resource_t gt_pci_ioports = {.r_bus_space = &gt_pci_bus_space,
                                    .r_type = RT_IOPORTS,
                                    .r_start = MALTA_PCI0_IO_BASE,
                                    .r_end = MALTA_PCI0_IO_END};
pci_bus_device_t gt_pci = {.bus = &gt_pci_bus,
                           .mem_space = &gt_pci_memory,
                           .io_space = &gt_pci_ioports,
                           .devices = TAILQ_HEAD_INITIALIZER(gt_pci.devices)};
