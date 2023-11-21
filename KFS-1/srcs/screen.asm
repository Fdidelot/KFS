	extern terminal_write_string
	global add_header

add_header:
	push edx
	push ecx
	mov edx, 0
.loop:
	mov cl, byte[esi + edx]
	mov byte[first_screen + edx], cl
	mov byte[second_screen + edx], cl
	mov byte[third_screen + edx], cl
	mov byte[fourth_screen + edx], cl
	cmp byte[esi + edx], 0
	je .end			
	inc edx
	jmp .loop
.end:
	mov eax, first_screen
	pop ecx
	pop edx
	ret

first_screen db 2000 dup(" ")
second_screen db 2000 dup(" ")
third_screen db 2000 dup(" ")
fourth_screen db 2000 dup(" ")
