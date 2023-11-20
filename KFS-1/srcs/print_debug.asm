	extern terminal_write_string
	extern terminal_putchar
	extern print_hexa
	global print_debug
	debug_string1 db "value(", 0
	debug_string2 db ") char(", 0
	debug_string3 db ")", 0xA, 0

print_debug:
	push esi
	mov esi, debug_string1
	call terminal_write_string

	pop esi
	push eax
	mov edi, eax
	call print_hexa
	pop eax

	mov esi, debug_string2
	call terminal_write_string

	push eax
	and eax, 0xff
	call terminal_putchar
	pop eax

	mov esi, debug_string3
	call terminal_write_string

	ret
	
