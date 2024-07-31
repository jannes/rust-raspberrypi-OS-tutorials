// SPDX-License-Identifier: MIT OR Apache-2.0
//
// Copyright (c) 2021-2023 Andre Richter <andre.o.richter@gmail.com>

//--------------------------------------------------------------------------------------------------
// Public Code
//--------------------------------------------------------------------------------------------------
.section .text._start

//------------------------------------------------------------------------------
// fn _start()
//------------------------------------------------------------------------------
_start:
	// Only proceed on the boot core. Park it otherwise.
	csrr a0, mhartid
	la t0, BOOT_CORE_ID // provided by bsp/__board_name__/cpu.rs
	ld a1, 0(t0)
	bne a0, a1, .L_parking_loop

	// If execution reaches here, it is the boot core.

	// Initialize DRAM.
	la a0, __bss_start
	la a1, __bss_end_exclusive

.L_bss_init_loop:
	beq a0, a1, .L_prepare_rust
	sd zero, (a0)
	addi a0, a0, 8
	j .L_bss_init_loop

	// Prepare the jump to Rust code.
.L_prepare_rust:
	// Set the stack pointer.
	la sp, __boot_core_stack_end_exclusive

	// Jump to Rust code.
	j _start_rust

	// Infinitely wait for events (aka "park the core").
.L_parking_loop:
	wfi
	j .L_parking_loop

.size	_start, . - _start
.type	_start, function
.global	_start
