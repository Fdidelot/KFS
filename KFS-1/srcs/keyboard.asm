	extern terminal_putchar
	extern print_debug
	global keyboard_handler

keyboard_handler:
	xor eax, eax
	in al, 0x64
	test al, 0b00000001
	jz keyboard_handler
	in al, 0x60

	cmp ax, 0x80
	jg .skip_release
	push esi
	call print_debug
	pop esi

.skip_release:	
	jmp keyboard_handler
	ret
	
