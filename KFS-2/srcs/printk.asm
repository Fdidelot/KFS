	; Global section
	global printk

	; Extern section
	extern keyboard_handler
	extern keyboard_handler.release_alt
	extern print_hexa
	extern terminal_write
	extern which_number
	extern terminal_putchar
	extern keystatus

	section .data
	print_hex_suffix db "0x", 0
	print_double_dot db ":", 0
	print_space db " ", 0
	print_newline db 0xA, 0
	print_pipe db "|", 0

PRINTK_START_ADDRESS equ 0x0
PRINTK_END_ADDRESS equ 0x0F800

	section .text
; print a char un ascii, replace by dot if non-printable
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

; print a byte in ascii
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

; print a byte
print_byte:
	mov eax, edx
	and eax, 0xf0 ; keep only left part of byte
	shr eax, 4
	call which_number

	push edx
	call terminal_putchar ; print left part
	pop edx

	mov eax, edx
	and eax, 0xf ; keep only right part of byte
	call which_number

	push edx
	call terminal_putchar ; print right part
	pop edx
	ret

; print 16 bytes in hexa, 2 by 2 
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
	push edx
	call print_byte
	pop edx
	popa

	inc ecx
	jmp .loop
.end:
	ret

; print kernel memory
printk:
	;pusha
	mov eax, PRINTK_START_ADDRESS

.loop:
 	cmp eax, PRINTK_END_ADDRESS ; end address to print
 	jg .end
	mov edi, eax

	push eax
	call print_hexa ; print address
	mov esi, print_double_dot
	call terminal_write
	pop eax

	pusha
	call print_bytes ; print content in hex
	mov esi, print_space
	call terminal_write

	mov esi, print_pipe
	call terminal_write
	call print_ascii ; print content in ascii
	mov esi, print_pipe
	call terminal_write

	mov esi, print_newline
	call terminal_write
	popa

	push eax
	cmp eax, PRINTK_START_ADDRESS
	je .next
	cmp eax, PRINTK_END_ADDRESS
	je .end
	and eax, 255 ; wait every 16 lines (eax % 256 == 0)
	cmp eax, 0
	jne .next
.start:
	xor eax, eax
	in al, 0x64 ; wait entries
	test al, 0b00000001 ; bit 1 is no entry
	jz .start
	in al, 0x60 ; read input

	cmp al, 0x38 ; ALT pressed?
	je .press_alt
	cmp al, 0x80 ; check release
	ja .key_release

	test byte[keystatus], 00000001b ; alt is pressed
	jnz .is_three_pressed

	cmp al, 0x1C ; enter pressed
	jne .start

.next:
	pop eax
	add eax, 16
	jmp .loop
.end:
	pop eax
	mov byte [keystatus], 0
	;popa
	jmp keyboard_handler ;.release_alt

.key_release:
	cmp al, 0xB8 ; break code for alt
	je .release_alt
	jmp .start

.press_alt:
	or byte[keystatus], 00000001b
	jmp .start

.release_alt:
	xor byte[keystatus], 00000001b
	jmp .start

.is_three_pressed:
	cmp al, 0x04
	je .end
	jmp .start
