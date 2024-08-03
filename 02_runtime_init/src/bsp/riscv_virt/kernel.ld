OUTPUT_ARCH( "riscv" )

ENTRY(_start)

/* Segments are marked PT_LOAD below so that the ELF file provides virtual and physical addresses.
 * It doesn't mean all of them need actually be loaded. */
PHDRS
{
    segment_code            PT_LOAD FLAGS(5); /* 5 = RX */
    segment_data            PT_LOAD FLAGS(6); /* 6 = RW */
    segment_boot_core_stack PT_LOAD FLAGS(6); /* 6 = RW */
}

SECTIONS
{
    /* QEMU's RISC-V virt machine starts execution from this address,
       which is also the beginning of DRAM in the memory map */
    . = 0x80000000;

    .text :
    {
        KEEP(*(.text._start))
        *(.text._start_arguments) /* Constants (or statics in Rust speak) read by _start(). */
        *(.text._start_rust)      /* The Rust entry point */
        *(.text*)                 /* Everything else */
    } :segment_code

    .rodata : ALIGN(8) {
        *(.rodata*)
    } :segment_code

    .data : {
        *(.data*)
    } :segment_data

    /* Section is zeroed in pairs of u64. Align start and end to 16 bytes */
    .bss (NOLOAD) : ALIGN(16)
    {
        __bss_start = .;
        *(.bss*);
        . = ALIGN(16);
        __bss_end_exclusive = .;
    } :segment_data

    /* Put the boot core stack after everything else with fixed size
       Stack grows from end to start (higher address to lower address) */
    .boot_core_stack (NOLOAD) :
    {
         __boot_core_stack_start = .;
        . += 0x80000;
        __boot_core_stack_end_exclusive = .;
    } :segment_boot_core_stack
}
