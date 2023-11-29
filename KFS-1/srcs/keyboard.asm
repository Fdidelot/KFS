	extern terminal_putchar
	extern first_terminal_color
	extern second_terminal_color
	extern third_terminal_color
	extern fourth_terminal_color
	extern terminal_color
	extern terminal_write_string
	extern backup_pos
	extern print_debug
	extern first_screen
	extern second_screen
	extern third_screen
	extern fourth_screen
	extern screen_id
	extern set_pos
	extern put_in_str
	global keyboard_handler

	section .text
keyboard_handler:
	mov ecx, kdbus

.start:
	xor eax, eax
	in al, 0x64 ; wait entries
	test al, 0b00000001
	jz .start
	in al, 0x60 ; read input

	cmp ax, 0x02 ; f1 pressed ?
	je .load_first_screen
	cmp ax, 0x03 ; f2 pressed ?
	je .load_second_screen
	cmp ax, 0x04 ; f3 pressed ?
	je .load_third_screen
	cmp ax, 0x05 ; f4 pressed ?
	je .load_fourth_screen
	cmp ax, 0x3A ; Caps Lock pressed?
	je .press_caps
	cmp ax, 0x2A ; shift pressed?
	je .press_shift
	cmp ax, 0x80 ; check release
	jg .key_release
	
	mov eax, [ecx + eax] ; get char in kdbus/shift_kdbus array

	cmp byte[keystatus], 00000001b ; check capslock
	je .use_print_debug

	call terminal_putchar
;//	call put_in_str		
;//	call terminal_write_string 

.key_release:
	cmp ax, 0xAA ; break code for shift, release shift?
	je .release_shift
	jmp .start
	ret

.load_first_screen:
	mov esi, first_screen
	call backup_pos
	mov byte[screen_id], 1
	call set_pos

	push eax
	mov al, byte[first_terminal_color]
	mov byte[terminal_color], al
	pop eax

	call terminal_write_string
	jmp .start

.load_second_screen:
	mov esi, second_screen
	call backup_pos
	mov byte[screen_id], 2
	call set_pos

	push eax
	mov al, byte[second_terminal_color]
	mov byte[terminal_color], al
	pop eax

	call terminal_write_string
	jmp .start

.load_third_screen:
	mov esi, third_screen
	call backup_pos
	mov byte[screen_id], 4
	call set_pos

	push eax
	mov al, byte[third_terminal_color]
	mov byte[terminal_color], al
	pop eax

	call terminal_write_string
	jmp .start

.load_fourth_screen:
	mov esi, fourth_screen
	call backup_pos
	mov byte[screen_id], 8
	call set_pos

	push eax
	mov al, byte[fourth_terminal_color]
	mov byte[terminal_color], al
	pop eax

	call terminal_write_string
	jmp .start
	
.use_print_debug:	
	push esi
	call print_debug
	pop esi
	jmp .start

.press_shift:
	mov ecx, shift_kdbus
	jmp .start

.press_caps:
	cmp byte[keystatus], 00000001b
	je .unset_debug
	cmp byte[keystatus], 00000000b
	je .set_debug
	jmp .start

.set_debug:
	mov byte[keystatus], 00000001b
	jmp .start

.unset_debug:
	mov byte[keystatus], 00000000b
	jmp .start

.release_shift:
	mov ecx, kdbus
	jmp .start

keystatus: dd 0

kdbus:
	db 0,  27, "1", "2", "3", "4", "5", "6", "7", "8" ; 9
	db "9", "0", "-", "=", 0x8 ; Backspace
	db 0x9 ; Tab
	db "q", "w", "e", "r" ; 19
	db "t", "y", "u", "i", "o", "p", "[", "]", 0xA ; Enter key
	db 0 ; 29 - Control
	db "a", "s", "d", "f", "g", "h", "j", "k", "l", ";" ; 39
	db 0x27, "`", 0 ; Left Shift
	db 0x5C, "z", "x", "c", "v", "b", "n" ; 49
	db "m", ",", ".", "/",   0 ; Right shift
	db "*"
	db 0 ; Alt
	db " " ; Space bar
	db 0 ; Caps Lock
	db 0 ; 59 - F1 key ... >
	db 0, 0, 0, 0, 0, 0, 0, 0
	db 0 ; < ... F10
	db 0 ; 69 - Num Lock
	db 0 ; Scroll Lock
	db 0 ; Home Key
	db 0 ; Up Arrow
	db 0 ; Page Up
	db "-"
	db 0 ; Left Arrow
	db 0
	db 0 ; Right Arrow
	db "+"
	db 0 ; 79 - End key
	db 0 ; Down Arrow
	db 0 ; Page Down
	db 0 ; Insert Key
	db 0 ; Delete Key
	db 0, 0, 0
	db 0 ; F11 Key
	db 0 ; F12 Key
	db 0 ; All other keys are undefined

shift_kdbus db 0,  27, "!", "@", "#", "$", "%", "^", "&", "*", \
	"(", ")", "_", "+", 0x8, \
	0x9, \
	"Q", "W", "E", "R", \
	"T", "Y", "U", "I", "O", "P", "{", "}", 0xA, \
	0, \
	"A", "S", "D", "F", "G", "H", "J", "K", "L", ":", \
	0x27, "~", 0, \
	0x7C, "Z", "X", "C", "V", "B", "N", \
	"M", "<", ">", "?",   0, \
	"*", \
	0, \
	" ", \
	0, \
	0, \
	0, 0, 0, 0, 0, 0, 0, 0, \
	0, \
	0, \
	0, \
	0, \
	0, \
	0, \
	"-", \
	0, \
	0, \
	0, \
	"+", \
	0, \
	0, \
	0, \
	0, \
	0, \
	0, 0, 0, \
	0, \
	0, \
	0 ; All other keys are undefined
