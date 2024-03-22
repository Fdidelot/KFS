	global printk

	extern print_hexa
	extern terminal_write
	extern which_number
	extern terminal_putchar

	section .data
	print_hex_suffix db "0x", 0
	print_double_dot db ":", 0
	print_space db " ", 0
	print_newline db 0xA, 0
	print_pipe db "|", 0

	section .text
print_char:
	mov eax, edx
	cmp al, 31
	jg .next
	mov al, '.'
.next:
	cmp al, 127
	jl .skip
	mov al, '.'
.skip:
	call terminal_putchar
	ret

print_ascii:
	xor ecx, ecx
.loop:
	cmp ecx, 16
	je .end

	pusha
	xor edx, edx
	mov dl, byte[eax + ecx]
	call print_char
	popa

	inc ecx
	jmp .loop
.end:
	ret

print_byte:
	mov eax, edx
	and eax, 0xf0
	shr eax, 4
	call which_number
	call terminal_putchar

	mov eax, edx
	and eax, 0xf
	call which_number
	call terminal_putchar
	ret

print_bytes:
	xor ecx, ecx
.loop:
	cmp ecx, 16
	je .end

	push eax
	mov esi, print_space
	call terminal_write
	pop eax

	pusha
	xor edx, edx
	mov dl, byte[eax + ecx]
	call print_byte
	popa

	inc ecx
	jmp .loop
.end:
	ret

; print kernel memory
printk:
	pusha
 	xor eax, eax

.loop:
 	cmp eax, 0x40
 	jg .end
	mov edi, eax

	push eax
	call print_hexa
	mov esi, print_double_dot
	call terminal_write
	pop eax

	pusha 
	call print_bytes
	mov esi, print_space
	call terminal_write

	mov esi, print_pipe
	call terminal_write
	call print_ascii
	mov esi, print_pipe
	call terminal_write

	mov esi, print_newline
	call terminal_write
	popa

	add eax, 16
	jmp .loop
.end:
	popa
	ret