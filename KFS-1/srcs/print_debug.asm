	; Extern section
	extern terminal_write
	extern terminal_putchar
	extern print_hexa
	extern print_registers

	; Global section
	global print_debug

	section .data
	debug_string1 db "value(0x", 0
	debug_string2 db ") char(", 0
	debug_string3 db ")", 0xA, 0

	section .text
print_debug:
	push esi
	mov esi, debug_string1
	call terminal_write

	pop esi
	push eax
	mov edi, eax
	call print_hexa
	pop eax

	mov esi, debug_string2
	call terminal_write

	push eax
	and eax, 0xff
	call terminal_putchar
	pop eax

	mov esi, debug_string3
	call terminal_write
	call print_registers

	ret
	
