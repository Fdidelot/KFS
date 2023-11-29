BITS 32

	extern keyboard_handler
	extern add_header
	extern screens_set_color
	global put_in_str
	global terminal_putchar
	global terminal_write_string
	global kernel_main

	section .data
VGA_WIDTH equ 80
VGA_HEIGHT equ 25

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
kernel_main:
	mov byte [byte 0xB9000], 5
	mov byte [byte 0xB9001], 10
	mov dh, VGA_COLOR_LIGHT_GREY
	mov dl, VGA_COLOR_BLACK
	call terminal_set_color
	call screens_set_color

	mov esi, header_42 ; need to be change when kernel will not loop
; on keyboard_handler
	call add_header
	mov esi, eax

	call terminal_write_string
	call set_cursor_position
	call keyboard_handler
;	jmp $ ; no needed again for the time

 
; IN = dl: bg color, dh: fg color
; OUT = none

set_cursor_position:
	mov ah, VGA_WIDTH
	mul byte [0xB9000]
	add ax, [0xB9001]
	shl ax, 1
	mov di, ax
	
	mov ax, 0xB8000
	add di, ax

	mov dx, 0x03D4
	mov al, 0x0F
	out dx, al
	inc dx
	mov al, byte [di+1]
	out dx, al
	
	mov dx, 0x3D4
	mov al, 0x0E
	out dx, al
	inc dx
	mov al, byte [di]
	out dx, al

	ret

terminal_set_color:
	shl dl, 4
 
	or dl, dh
	mov [terminal_color], dl

	ret
 
; IN = dl: y, dh: x
; OUT = dx: Index with offset 0xB8000 at VGA buffer
; Other registers preserved
terminal_getidx:
	push eax; preserve registers

	xor ebx, ebx
	mov bl, dh
	xor dh, dh

	mov eax, VGA_WIDTH
	mul edx

	add ebx, eax
	shl ebx, 1

	pop eax
	ret
 
; IN = dl: y, dh: x, al: ASCII char
; OUT = none
terminal_putentryat:
	pusha
	call terminal_getidx
 
	mov dl, [terminal_color]
	mov byte[0xB8000 + ebx], al
	mov byte[0xB8001 + ebx], dl

	popa
	ret

scroll:
	push eax
	push edx
	xor eax, eax
.loop:
	cmp eax, 3840
	jge .empty_last_line
	mov dh, byte[0xB80A0 + eax]
	mov dl, byte[0xB80A1 + eax]
	mov byte[0xB8000 + eax], dh
	mov byte[0xB8001 + eax], dl
	add eax, 2
	jmp .loop
.empty_last_line:
	cmp eax, 4000
	jge .end
	mov byte[0xB8000 + eax], " "
	mov byte[0xB8001 + eax], 0
	add eax, 2
	jmp .empty_last_line
.end:
	pop edx
	pop eax
	ret
	
; IN = al: ASCII char
terminal_putchar:
	mov dx, [terminal_cursor_pos] ; This loads terminal_column at DH, and terminal_row at DL

	cmp al, 0xA
	je .new_line

	call terminal_putentryat
 
	inc dh
	cmp dh, VGA_WIDTH
	jne .cursor_moved
 
.new_line:
	mov dh, 0
	inc dl

	cmp dl, VGA_HEIGHT
	jne .cursor_moved
	call scroll
	dec dl

.cursor_moved:
	; Store new cursor position 
	mov [terminal_cursor_pos], dx
 
	ret
 
; IN = cx: length of string, ESI: string location
; OUT = none
terminal_write:
	pusha
.loopy:

	mov al, [esi]

	cmp al, 0
	je .done

	call terminal_putchar

	inc esi
	jmp .loopy
 
 
.done:
	popa
	ret
 
; IN = ESI: string location
; OUT = none
terminal_write_string:
	pusha
	call terminal_write
	popa
	ret

put_in_str:
	mov dx, [terminal_cursor_pos]

	push ebx
	push edx
	push eax
        xor ebx, ebx
        mov bl, dh
        xor dh, dh

        mov eax, VGA_WIDTH
        mul edx

        add ebx, eax
	pop eax
	mov byte[esi + ebx], al
	pop edx
	pop ebx
 
	inc dh
	cmp dh, VGA_WIDTH
	jne .cursor_moved
 
	mov dh, 0
	inc dl

	cmp dl, VGA_HEIGHT
	jne .cursor_moved
 
	mov dl, 0

.cursor_moved:
	; Store new cursor position 
	mov [terminal_cursor_pos], dx
 
	ret

; Exercises:
; - Terminal scrolling when screen is full
; Note: 
; - The string is looped through twice on printing.

;don't forget do pimp the header with a lot of 258
	section .data
header_42 db 26 dup(" "), "        ,--,               ", 0xA, \
	     26 dup(" "), "      ,--.'|       ,----,  ", 0xA, \
	     26 dup(" "), "   ,--,  | :     .'   .' \ ", 0xA, \
	     26 dup(" "), ",---.'|  : '   ,----,'    |", 0xA, \
	     26 dup(" "), ";   : |  | ;   |    :  .  ;", 0xA, \
	     26 dup(" "), "|   | : _' |   ;    |.'  / ", 0xA, \
	     26 dup(" "), ":   : |.'  |   `----'/  ;  ", 0xA, \
	     26 dup(" "), "|   ' '  ; :     /  ;  /   ", 0xA, \
	     26 dup(" "), "\   \  .'. |    ;  /  /-,  ", 0xA, \
	     26 dup(" "), " `---`:  | '   /  /  /.`|  ", 0xA, \
	     26 dup(" "), "      '  ; | ./__;      :  ", 0xA, \
	     26 dup(" "), "      |  : ; |   :    .'   ", 0xA, \
	     26 dup(" "), "      '  ,/  ;   | .'      ", 0xA, \
	     26 dup(" "), "      '--' ", 258, " `---'         ", 0xA, 0

	global terminal_color
terminal_color:	db 0
	global terminal_cursor_pos
	global terminal_column
	global terminal_row
terminal_cursor_pos:
terminal_column db 0
terminal_row db 0
