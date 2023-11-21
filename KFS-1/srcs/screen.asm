	extern terminal_write_string
	extern terminal_color
	extern terminal_column
	extern terminal_row
	global backup_pos
	global add_header

	section .text
add_header:
	push edx
	push ecx
	mov edx, 0
	mov byte[first_terminal_color], 4
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

backup_pos:
	cmp byte[screen_id], 1
	je .backup_first
	cmp byte[screen_id], 2
	je .backup_second
	cmp byte[screen_id], 4
	je .backup_third
	cmp byte[screen_id], 8
	je .backup_fourth
	ret
.backup_first:
	push eax
	mov al, byte[terminal_column]
	mov byte[first_terminal_column], al
	mov al, byte[terminal_row]
	mov byte[first_terminal_row], al
	pop eax
	ret
.backup_second:
	ret
.backup_third:
	ret
.backup_fourth:
	ret

	section .data
	global first_screen
	global second_screen
	global third_screen
	global fourth_screen
	global first_terminal_color
	global first_terminal_cursor_pos
	global second_terminal_color
	global second_terminal_cursor_pos
	global third_terminal_color
	global third_terminal_cursor_pos
	global fourth_terminal_color
	global fourth_terminal_cursor_pos
	global screen_id
screen_id:	db 1
first_screen:	db 2000 dup(" ")
second_screen:	db 2000 dup(" ")
third_screen:	db 2000 dup(" ")
fourth_screen:	db 2000 dup(" ")

first_terminal_color:	 db 0
first_terminal_cursor_pos:
first_terminal_column db 0
first_terminal_row db 0

second_terminal_color:	 db 0
second_terminal_cursor_pos:
second_terminal_column db 0
second_terminal_row db 0

third_terminal_color:	 db 0
third_terminal_cursor_pos:
third_terminal_column db 0
third_terminal_row db 0

fourth_terminal_color:	 db 0
fourth_terminal_cursor_pos:
fourth_terminal_column db 0
fourth_terminal_row db 0
