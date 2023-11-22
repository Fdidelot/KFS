	extern terminal_write_string
	extern terminal_color
	extern terminal_column
	extern terminal_row
	global set_pos
	global screens_set_color
	global backup_pos
	global add_header

	section .data
VGA_COLOR_BLACK equ 0
VGA_COLOR_BLUE equ 1
VGA_COLOR_GREEN equ 2
VGA_COLOR_CYAN equ 3
VGA_COLOR_RED equ 4
VGA_COLOR_MAGENTA equ 5
VGA_COLOR_BROWN equ 6
VGA_COLOR_LIGHT_GREY equ 7
VGA_COLOR_DARK_GREY equ 8
VGA_COLOR_LIGHT_BLUE equ 9
VGA_COLOR_LIGHT_GREEN equ 10
VGA_COLOR_LIGHT_CYAN equ 11
VGA_COLOR_LIGHT_RED equ 12
VGA_COLOR_LIGHT_MAGENTA equ 13
VGA_COLOR_LIGHT_BROWN equ 14
VGA_COLOR_WHITE equ 15

	section .text
;setup screens colors
screens_set_color:
	push edx
	mov dh, VGA_COLOR_LIGHT_GREY
        mov dl, VGA_COLOR_BLACK

	shl dl, 4
	or dl, dh
	mov [first_terminal_color], dl

	mov dh, VGA_COLOR_LIGHT_BLUE
        mov dl, VGA_COLOR_BLACK

	shl dl, 4
	or dl, dh
	mov [second_terminal_color], dl

	mov dh, VGA_COLOR_LIGHT_GREEN
        mov dl, VGA_COLOR_BLACK

	shl dl, 4
	or dl, dh
	mov [third_terminal_color], dl

	mov dh, VGA_COLOR_LIGHT_MAGENTA
        mov dl, VGA_COLOR_BLACK

	shl dl, 4
	or dl, dh
	mov [fourth_terminal_color], dl

	pop edx

;call only at startup and setup header for all screen
add_header:
	push edx ; edx used by terminal color
;	push ecx ; push/pop ecx isn't needed at startup? (never used)
	mov edx, 0
	;mov byte [first_terminal_color], 4 ; to delete, it was a test
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
;	pop ecx
	pop edx
	ret

;backup cursor position when switch screen
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
	push eax
	mov al, byte[terminal_column]
	mov byte[second_terminal_column], al
	mov al, byte[terminal_row]
	mov byte[second_terminal_row], al
	pop eax
	ret
.backup_third:
	push eax
	mov al, byte[terminal_column]
	mov byte[third_terminal_column], al
	mov al, byte[terminal_row]
	mov byte[second_terminal_row], al
	pop eax
	ret
.backup_fourth:
	push eax
	mov al, byte[terminal_column]
	mov byte[fourth_terminal_column], al
	mov al, byte[terminal_row]
	mov byte[fourth_terminal_row], al
	pop eax
	ret

set_pos:
	mov byte[terminal_column], 0
	mov byte[terminal_row], 0
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
; set all screen at VGA_WIDTH*VGA_HEIGHT = 2000, the size of the screen
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
