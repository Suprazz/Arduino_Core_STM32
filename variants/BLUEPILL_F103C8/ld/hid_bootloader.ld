/*
 * libmaple linker script for "Flash" builds.
 *
 * A Flash build puts .text (and .rodata) in Flash, and
 * .data/.bss/heap (of course) in SRAM, but offsets the sections by
 * enough space to store the Maple bootloader, which lives in low
 * Flash and uses low memory.
 */

/*
 * This pulls in the appropriate MEMORY declaration from the right
 * subdirectory of stm32/mem/ (the environment must call ld with the
 * right include directory flags to make this happen). Boards can also
 * use this file to use any of libmaple's memory-related hooks (like
 * where the heap should live).
 */
MEMORY
{
  ram (rwx) : ORIGIN = 0x20000000, LENGTH = 20K
  rom (rx)  : ORIGIN = 0x08001000, LENGTH = 124K
}

/* Provide memory region aliases for common.inc */
REGION_ALIAS("REGION_TEXT", rom);
REGION_ALIAS("REGION_DATA", ram);
REGION_ALIAS("REGION_BSS", ram);
REGION_ALIAS("REGION_RODATA", rom);

/* Common.inc file content */
/*
 * Linker script for libmaple.
 *
 * Original author "lanchon" from ST forums, with modifications by LeafLabs.
 */

OUTPUT_FORMAT ("elf32-littlearm", "elf32-bigarm", "elf32-littlearm")

/*
 * Configure other libraries we want in the link.
 *
 * libgcc, libc, and libm are common across supported toolchains.
 * However, some toolchains require additional archives which aren't
 * present everywhere (e.g. ARM's gcc-arm-embedded releases).
 *
 * To hack around this, we let the build system specify additional
 * archives by putting the right extra_libs.inc (in a directory under
 * toolchains/) in our search path.
 */
GROUP(libgcc.a libc.a libm.a)
/*INCLUDE extra_libs.inc*/
/*
 * Extra archives needed by ARM's GCC ARM Embedded arm-none-eabi-
 * releases (https://launchpad.net/gcc-arm-embedded/).
 */

/* This is for the provided newlib. */
GROUP(libnosys.a)


/*
 * These force the linker to search for vector table symbols.
 *
 * These symbols vary by STM32 family (and also within families).
 * It's up to the build system to configure the link's search path
 * properly for the target MCU.
 */
/*INCLUDE vector_symbols.inc*/
EXTERN(__msp_init)
EXTERN(__exc_reset)
EXTERN(__exc_nmi)
EXTERN(__exc_hardfault)
EXTERN(__exc_memmanage)
EXTERN(__exc_busfault)
EXTERN(__exc_usagefault)
EXTERN(__stm32reservedexception7)
EXTERN(__stm32reservedexception8)
EXTERN(__stm32reservedexception9)
EXTERN(__stm32reservedexception10)
EXTERN(__exc_svc)
EXTERN(__exc_debug_monitor)
EXTERN(__stm32reservedexception13)
EXTERN(__exc_pendsv)
EXTERN(__exc_systick)

EXTERN(__irq_wwdg)
EXTERN(__irq_pvd)
EXTERN(__irq_tamper)
EXTERN(__irq_rtc)
EXTERN(__irq_flash)
EXTERN(__irq_rcc)
EXTERN(__irq_exti0)
EXTERN(__irq_exti1)
EXTERN(__irq_exti2)
EXTERN(__irq_exti3)
EXTERN(__irq_exti4)
EXTERN(__irq_dma1_channel1)
EXTERN(__irq_dma1_channel2)
EXTERN(__irq_dma1_channel3)
EXTERN(__irq_dma1_channel4)
EXTERN(__irq_dma1_channel5)
EXTERN(__irq_dma1_channel6)
EXTERN(__irq_dma1_channel7)
EXTERN(__irq_adc)
EXTERN(__irq_usb_hp_can_tx)
EXTERN(__irq_usb_lp_can_rx0)
EXTERN(__irq_can_rx1)
EXTERN(__irq_can_sce)
EXTERN(__irq_exti9_5)
EXTERN(__irq_tim1_brk)
EXTERN(__irq_tim1_up)
EXTERN(__irq_tim1_trg_com)
EXTERN(__irq_tim1_cc)
EXTERN(__irq_tim2)
EXTERN(__irq_tim3)
EXTERN(__irq_tim4)
EXTERN(__irq_i2c1_ev)
EXTERN(__irq_i2c1_er)
EXTERN(__irq_i2c2_ev)
EXTERN(__irq_i2c2_er)
EXTERN(__irq_spi1)
EXTERN(__irq_spi2)
EXTERN(__irq_usart1)
EXTERN(__irq_usart2)
EXTERN(__irq_usart3)
EXTERN(__irq_exti15_10)
EXTERN(__irq_rtcalarm)
EXTERN(__irq_usbwakeup)

EXTERN(__irq_tim8_brk)
EXTERN(__irq_tim8_up)
EXTERN(__irq_tim8_trg_com)
EXTERN(__irq_tim8_cc)
EXTERN(__irq_adc3)
EXTERN(__irq_fsmc)
EXTERN(__irq_sdio)
EXTERN(__irq_tim5)
EXTERN(__irq_spi3)
EXTERN(__irq_uart4)
EXTERN(__irq_uart5)
EXTERN(__irq_tim6)
EXTERN(__irq_tim7)
EXTERN(__irq_dma2_channel1)
EXTERN(__irq_dma2_channel2)
EXTERN(__irq_dma2_channel3)
EXTERN(__irq_dma2_channel4_5)


/* STM32 vector table. */
EXTERN(__stm32_vector_table)

/* C runtime initialization function. */
EXTERN(start_c)

/* main entry point */
EXTERN(main)

/* Initial stack pointer value. */
EXTERN(__msp_init)
PROVIDE(__msp_init = ORIGIN(ram) + LENGTH(ram));

/* Reset vector and chip reset entry point */
EXTERN(__start__)
ENTRY(__start__)
PROVIDE(__exc_reset = __start__);

/* Heap boundaries, for libmaple */
EXTERN(_lm_heap_start);
EXTERN(_lm_heap_end);

SECTIONS
{
    .text :
      {
        __text_start__ = .;
        /*
         * STM32 vector table.  Leave this here.  Yes, really.
         */
        *(.stm32.interrupt_vector)

        /*
         * Program code and vague linking
         */
        *(.text .text.* .gnu.linkonce.t.*)
        *(.plt)
        *(.gnu.warning)
        *(.glue_7t) *(.glue_7) *(.vfp11_veneer)

        *(.ARM.extab* .gnu.linkonce.armextab.*)
        *(.gcc_except_table)
        *(.eh_frame_hdr)
        *(.eh_frame)

        . = ALIGN(4);
        KEEP(*(.init))

        . = ALIGN(4);
        __preinit_array_start = .;
        KEEP (*(.preinit_array))
        __preinit_array_end = .;

        . = ALIGN(4);
        __init_array_start = .;
        KEEP (*(SORT(.init_array.*)))
        KEEP (*(.init_array))
        __init_array_end = .;

        . = ALIGN(0x4);
        KEEP (*crtbegin.o(.ctors))
        KEEP (*(EXCLUDE_FILE (*crtend.o) .ctors))
        KEEP (*(SORT(.ctors.*)))
        KEEP (*crtend.o(.ctors))

        . = ALIGN(4);
        KEEP(*(.fini))

        . = ALIGN(4);
        __fini_array_start = .;
        KEEP (*(.fini_array))
        KEEP (*(SORT(.fini_array.*)))
        __fini_array_end = .;

        KEEP (*crtbegin.o(.dtors))
        KEEP (*(EXCLUDE_FILE (*crtend.o) .dtors))
        KEEP (*(SORT(.dtors.*)))
        KEEP (*crtend.o(.dtors))
      } > REGION_TEXT

    /*
     * End of text
     */
    .text.align :
      {
        . = ALIGN(8);
        __text_end__ = .;
      } > REGION_TEXT

    /*
     * .ARM.exidx exception unwinding; mandated by ARM's C++ ABI
     */
    __exidx_start = .;
    .ARM.exidx :
      {
        *(.ARM.exidx* .gnu.linkonce.armexidx.*)
      } > REGION_RODATA
    __exidx_end = .;

    /*
     * .data
     */
    .data :
      {
        __data_start__ = .;
      	LONG(0)
        . = ALIGN(8);

        *(.got.plt) *(.got)
        *(.data .data.* .gnu.linkonce.d.*)

        . = ALIGN(8);
        __data_end__ = .;
      } > REGION_DATA AT> REGION_RODATA

    /*
     * Read-only data
     */
    .rodata :
      {
        *(.rodata .rodata.* .gnu.linkonce.r.*)
        /* .USER_FLASH: We allow users to allocate into Flash here */
        *(.USER_FLASH)
        /* ROM image configuration; for C startup */
        . = ALIGN(4);
        _lm_rom_img_cfgp = .;
        LONG(LOADADDR(.data));
        /*
         * Heap: Linker scripts may choose a custom heap by overriding
         * _lm_heap_start and _lm_heap_end. Otherwise, the heap is in
         * internal SRAM, beginning after .bss, and growing towards
         * the stack.
         *
         * I'm shoving these here naively; there's probably a cleaner way
         * to go about this. [mbolivar]
         */
        _lm_heap_start = DEFINED(_lm_heap_start) ? _lm_heap_start : _end;
        _lm_heap_end   = DEFINED(_lm_heap_end) ? _lm_heap_end : __msp_init;
      } > REGION_RODATA

    /*
     * .bss
     */
    .bss :
      {
        . = ALIGN(8);
        __bss_start__ = .;
        *(.bss .bss.* .gnu.linkonce.b.*)
        *(COMMON)
        . = ALIGN (8);
        __bss_end__ = .;
        _end = __bss_end__;
      } > REGION_BSS

    /*
     * Debugging sections
     */
    .stab 0 (NOLOAD) : { *(.stab) }
    .stabstr 0 (NOLOAD) : { *(.stabstr) }
    /* DWARF debug sections.
     * Symbols in the DWARF debugging sections are relative to the beginning
     * of the section so we begin them at 0.  */
    /* DWARF 1 */
    .debug          0 : { *(.debug) }
    .line           0 : { *(.line) }
    /* GNU DWARF 1 extensions */
    .debug_srcinfo  0 : { *(.debug_srcinfo) }
    .debug_sfnames  0 : { *(.debug_sfnames) }
    /* DWARF 1.1 and DWARF 2 */
    .debug_aranges  0 : { *(.debug_aranges) }
    .debug_pubnames 0 : { *(.debug_pubnames) }
    /* DWARF 2 */
    .debug_info     0 : { *(.debug_info .gnu.linkonce.wi.*) }
    .debug_abbrev   0 : { *(.debug_abbrev) }
    .debug_line     0 : { *(.debug_line) }
    .debug_frame    0 : { *(.debug_frame) }
    .debug_str      0 : { *(.debug_str) }
    .debug_loc      0 : { *(.debug_loc) }
    .debug_macinfo  0 : { *(.debug_macinfo) }
    /* SGI/MIPS DWARF 2 extensions */
    .debug_weaknames 0 : { *(.debug_weaknames) }
    .debug_funcnames 0 : { *(.debug_funcnames) }
    .debug_typenames 0 : { *(.debug_typenames) }
    .debug_varnames  0 : { *(.debug_varnames) }

    .note.gnu.arm.ident 0 : { KEEP (*(.note.gnu.arm.ident)) }
    .ARM.attributes 0 : { KEEP (*(.ARM.attributes)) }
    /DISCARD/ : { *(.note.GNU-stack) }
}
