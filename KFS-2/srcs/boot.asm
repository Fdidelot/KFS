MBALIGN  equ  1 << 0            ; align loaded modules on page boundaries
MEMINFO  equ  1 << 1            ; provide memory map
MBFLAGS  equ  MBALIGN | MEMINFO ; this is the Multiboot 'flag' field
MAGIC    equ  0x1BADB002        ; 'magic number' lets bootloader find the header
CHECKSUM equ -(MAGIC + MBFLAGS)   ; checksum of above, to prove we are multiboot
 
section .multiboot
align 4
	dd MAGIC
	dd MBFLAGS
	dd CHECKSUM
 
section .bss
align 16
stack_bottom:
	resb 16384 ; 16 KiB
stack_top:

global stack_top

section .text
global _start:function (_start.end - _start)
_start:
	cli

	extern setup_gdt
	call setup_gdt

	extern kfs_mfpd_main
	call kfs_mfpd_main

.hang:	hlt
	jmp .hang
.end:
