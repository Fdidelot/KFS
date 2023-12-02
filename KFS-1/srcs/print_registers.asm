	; Extern section
	extern terminal_write
	extern terminal_putchar
	extern print_hexa

	; Global section
	global print_registers

	section .data
	print_eax1 db "eax(0x", 0
	print_eax2 db ")", 0xA, 0
	print_ebx1 db "ebx(0x", 0
	print_ebx2 db ")", 0xA, 0
	print_ecx1 db "ecx(0x", 0
	print_ecx2 db ")", 0xA, 0
	print_edx1 db "edx(0x", 0
	print_edx2 db ")", 0xA, 0
	print_esi1 db "esi(0x", 0
	print_esi2 db ")", 0xA, 0
	print_edi1 db "edi(0x", 0
	print_edi2 db ")", 0xA, 0

	section .text
print_registers:
	; print eax
	push esi
	mov esi, print_eax1
	call terminal_write

	pop esi
	push eax
	mov edi, eax
	call print_hexa
	pop eax

	mov esi, print_ebx2
	call terminal_write

	; print ebx
	push esi
	mov esi, print_ebx1
	call terminal_write


	pop esi
	push eax
	mov edi, ebx
	call print_hexa
	pop eax

	mov esi, print_ebx2
	call terminal_write

	; print ecx
	push esi
	mov esi, print_ecx1
	call terminal_write


	pop esi
	push eax
	mov edi, ecx
	call print_hexa
	pop eax

	mov esi, print_ecx2
	call terminal_write

	; print edx
	push esi
	mov esi, print_edx1
	call terminal_write


	pop esi
	push eax
	mov edi, edx
	call print_hexa
	pop eax

	mov esi, print_edx2
	call terminal_write

	; print esi
	push esi
	mov esi, print_esi1
	call terminal_write


	pop esi
	push eax
	mov edi, esi
	call print_hexa
	pop eax

	mov esi, print_esi2
	call terminal_write

	; print edi
	push esi
	mov esi, print_edi1
	call terminal_write


	pop esi
	push eax
	mov edi, edi
	call print_hexa
	pop eax

	mov esi, print_edi2
	call terminal_write

	ret
