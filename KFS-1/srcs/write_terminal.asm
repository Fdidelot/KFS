	; Global section
	global terminal_write_string
	global terminal_write
	global terminal_color
	global terminal_column
	global terminal_row
	global terminal_putchar
	global terminal_getidx

    section .data
VGA_WIDTH equ 80
VGA_HEIGHT equ 25

terminal_color:	db 0
terminal_cursor_pos:
terminal_column db 0
terminal_row db 0

    section .text
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
	mov byte[0xB8003 + ebx], dl ; set next position's color for cursor

	popa
	ret

; scroll and clear the last line
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

	mov byte[0xB8000 + eax], 0
	;mov byte[0xB8001 + eax], dl

	add eax, 2
	jmp .empty_last_line
.end:
	pop edx
	pop eax
	ret

; fill line with space when thereis a \n for switch screens purpose
; IN = dh: cursor width pos 
fill_line_with_space:
	cmp dh, VGA_WIDTH
	je .end
	mov al, " "
	call terminal_putentryat
	inc dh
	jmp fill_line_with_space
.end:
	mov al, 0
	call terminal_putentryat
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
	call fill_line_with_space
	mov dh, 0
	inc dl

	cmp dl, VGA_HEIGHT
	jne .cursor_moved
 
	call scroll
	dec dl

.cursor_moved:
	; Store new cursor position 
	mov [terminal_cursor_pos], dx
 	call set_cursor_pos

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

; clear the terminal
clear_terminal:
	push eax
	xor eax, eax
.loop:
	cmp eax, 4000
	jg .end
	add eax, 2
	mov byte[0xB8000 + eax], 0
	jmp .loop
.end:
	pop eax
	ret

; IN = ESI: string location
; OUT = none
terminal_write_string:
	pusha
	call clear_terminal

	mov byte[terminal_column], 0
	mov byte[terminal_row], 0

	call terminal_write

	popa
	ret

set_cursor_pos:
	pusha
	xor ebx, ebx
	xor eax, eax
	mov al, byte[terminal_column]
	mov bl, byte[terminal_row]

	mov dl, VGA_WIDTH
	mul dl
	add bx, ax

	mov dx, 0x03d4
	mov al, 0x0f
	out dx, al

	inc dl
	mov al, bl
	out dx, al

	dec dl
	mov al, 0x0e
	out dx, al

	inc dl
	mov al, bh
	out dx, al
	popa
	ret
