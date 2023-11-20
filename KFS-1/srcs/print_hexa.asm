	extern terminal_putchar
	global print_hexa

which_number:
	cmp eax, 0x0
	jne .next_zero
	mov al, "0"
.next_zero:
	cmp eax, 0x1
	jne .next_one
	mov al, "1"
.next_one:
	cmp eax, 0x2
	jne .next_two
	mov al, "2"
.next_two:
	cmp eax, 0x3
	jne .next_three
	mov al, "3"
.next_three:
	cmp eax, 0x4
	jne .next_four
	mov al, "4"
.next_four:
	cmp eax, 0x5
	jne .next_five
	mov al, "5"
.next_five:
	cmp eax, 0x6
	jne .next_six
	mov al, "6"
.next_six:
	cmp eax, 0x7
	jne .next_seven
	mov al, "7"
.next_seven:
	cmp eax, 0x8
	jne .next_eight
	mov al, "8"
.next_eight:
	cmp eax, 0x9
	jne .next_nine
	mov al, "9"
.next_nine:
	cmp eax, 0xA
	jne .next_a
	mov al, "A"
.next_a:
	cmp eax, 0xB
	jne .next_b
	mov al, "B"
.next_b:
	cmp eax, 0xC
	jne .next_c
	mov al, "C"
.next_c:
	cmp eax, 0xD
	jne .next_d
	mov al, "D"
.next_d:
	cmp eax, 0xE
	jne .next_e
	mov al, "E"
.next_e:
	cmp eax, 0xF
	jne .next_f
	mov al, "F"
.next_f:
	ret
	
print_hexa:
	xor eax, eax

	cmp esi, 3
	jg .put_hexa
	and edi, 0x00ffffff
	cmp esi, 2
	jg .put_hexa
	and edi, 0x0000ffff
	cmp esi, 1
	jne .put_hexa
	and edi, 0x000000ff

.put_hexa:
	mov eax, edi
	and eax, 0xf0000000
	shr eax, 28
	call which_number
	call terminal_putchar

	mov eax, edi
	and eax, 0xf000000
	shr eax, 24
	call which_number
	call terminal_putchar

	mov eax, edi
	and eax, 0xf00000
	shr eax, 20
	call which_number
	call terminal_putchar

	mov eax, edi
	and eax, 0xf0000
	shr eax, 16
	call which_number
	call terminal_putchar

	mov eax, edi
	and eax, 0xf000
	shr eax, 12
	call which_number
	call terminal_putchar

	mov eax, edi
	and eax, 0xf00
	shr eax, 8
	call which_number
	call terminal_putchar

	mov eax, edi
	and eax, 0xf0
	shr eax, 4
	call which_number
	call terminal_putchar

	mov eax, edi
	and eax, 0xf
	call which_number
	call terminal_putchar
	
	ret
