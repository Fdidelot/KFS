    ; Extern section
	extern terminal_color
	extern terminal_getidx
	extern terminal_column
	extern terminal_row

    ; Global section
	global first_terminal_color
	global set_terminal_colors
	global set_cursor_shape
	global screen_id
	global add_headers
	global first_screen
	global save_screen

	section .rodata
; Colors value
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

; fourty-two header
header_ft db 26 dup(" "), "        ,--,               ", 27 dup(" "), \
	     26 dup(" "), "      ,--.'|       ,----,  ", 27 dup(" "), \
	     26 dup(" "), "   ,--,  | :     .'   .' \ ", 27 dup(" "), \
	     26 dup(" "), ",---.'|  : '   ,----,'    |", 27 dup(" "), \
	     26 dup(" "), ";   : |  | ;   |    :  .  ;", 27 dup(" "), \
	     26 dup(" "), "|   | : _' |   ;    |.'  / ", 27 dup(" "), \
	     26 dup(" "), ":   : |.'  |   `----'/  ;  ", 27 dup(" "), \
	     26 dup(" "), "|   ' '  ; :     /  ;  /   ", 27 dup(" "), \
	     26 dup(" "), "\   \  .'. |    ;  /  /-,  ", 27 dup(" "), \
	     26 dup(" "), " `---`:  | '   /  /  /.`|  ", 27 dup(" "), \
	     26 dup(" "), "      '  ; | ./__;      :  ", 27 dup(" "), \
	     26 dup(" "), "      |  : ; |   :    .'   ", 27 dup(" "), \
	     26 dup(" "), "      '  ,/  ;   | .'      ", 27 dup(" "), \
	     26 dup(" "), "      '--' ", 2, " `---'         ", 27 dup(" "), 0

; terminals colors
first_terminal_color:	 db 0

; set all screen at VGA_WIDTH*VGA_HEIGHT = 2000, the size of the screen
first_screen:	db 2000 dup(0), 0

screen_id db 1

	section .text
set_cursor_shape:
	pusha
	mov dx, 0x03d4
	mov al, 0x0a ; low cursor shape register
	out dx, al

	inc dl
	mov al, 0x0f ; the thinnest shape
	out dx, al

	popa
	ret

;setup screens colors
set_terminal_colors:
	push edx

	mov dh, VGA_COLOR_LIGHT_GREY
	mov dl, VGA_COLOR_BLACK

	shl dl, 4
	or dl, dh
	mov [first_terminal_color], dl
	mov [terminal_color], dl ; set terminal color for the first time

	pop edx

;call only at startup and setup header for all screen
add_headers:
	push edx ; edx used by terminal color

	mov esi, header_ft
	mov edx, 0
.loop:
	mov cl, byte[esi + edx]
	mov byte[first_screen + edx], cl

	cmp byte[esi + edx], 0
	je .end
	inc edx
	jmp .loop
.end:
	mov eax, first_screen ; set first screen to be the first displayed

	pop edx
	ret

; save old terminal in backup screens
save_screen:
	push eax
	push edx

	xor eax ,eax
.loop:
	cmp eax, 4000
	jg .end
	mov dl, byte[0xB8000 + eax]
	shr eax, 1
	mov byte[esi + eax], dl
	shl eax, 1
	add eax, 2
	jmp .loop
.end:
	mov byte[esi + 2000], 0

	pop edx
	pop eax
	ret
