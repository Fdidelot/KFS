	; Extern section
	extern handle_key_and_display
	extern terminal_color
	extern first_terminal_color
	extern second_terminal_color
	extern third_terminal_color
	extern fourth_terminal_color
	extern terminal_putchar
	extern print_debug
	extern first_screen
	extern second_screen
	extern third_screen
	extern fourth_screen
	extern screen_id
	extern save_screen
	extern load_pos
	extern print_registers
	extern printk

	; Global section
	global keyboard_handler
	global keyboard_handler.release_alt

	section .data
kdbus:
	db 0,  0, "1", "2", "3", "4", "5", "6", "7", "8" ; 9
	db "9", "0", "-", "=", 0 ; Backspace
	db 0 ; Tab
	db "q", "w", "e", "r" ; 19
	db "t", "y", "u", "i", "o", "p", "[", "]", 0xA ; Enter key
	db 0 ; 29 - Control
	db "a", "s", "d", "f", "g", "h", "j", "k", "l", ";" ; 39
	db 0x27, "`", 0 ; Left Shift
	db 0x5C, "z", "x", "c", "v", "b", "n" ; 49 ; 0x7c maj for 0x5c ?
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

shift_kdbus db 0,  0, "!", "@", "#", "$", "%", "^", "&", "*", \
	"(", ")", "_", "+", 0, \
	0, \
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

keystatus: dd 0

	section .text
keyboard_handler:
	mov ecx, kdbus

.start:
	xor eax, eax
	in al, 0x64 ; wait entries
	test al, 0b00000001 ; bit 1 is no entry
	jz .start
	in al, 0x60 ; read input

	cmp ax, 0x2A ; shift pressed?
	je .press_shift
	cmp ax, 0x1D ; CTRL pressed?
	je .press_ctrl
	cmp ax, 0x38 ; ALT pressed?
	je .press_alt
	cmp ax, 0x80 ; check release
	jg .key_release

	test byte[keystatus], 00000010b ; check switch screen
	jnz .switch_screen

	test byte[keystatus], 00000001b ; check debug mode
	jnz .debug_mode

	mov eax, [ecx + eax] ; get char in kdbus/shift_kdbus array
	cmp al, 0 ; skip unsued keys
	je .start

	test byte[keystatus], 00000100b ; check print_hex
	jnz .print_hexa

	call terminal_putchar

.key_release:
	cmp ax, 0xB8 ; break code for alt, release alt?
	je .release_alt
	cmp ax, 0xAA ; break code for shift, release shift?
	je .release_shift
	cmp ax, 0x9D ; break code for ctrl, release ctrl?
	je .release_ctrl
	jmp .start
	ret

.load_first_screen:
	call save_screen

	mov esi, first_screen
	mov byte[screen_id], 1

	push eax
	mov al, byte[first_terminal_color]
	mov byte[terminal_color], al
	pop eax

	call handle_key_and_display
	jmp .start

.load_second_screen:
	call save_screen

	mov esi, second_screen
	mov byte[screen_id], 2

	push eax
	mov al, byte[second_terminal_color]
	mov byte[terminal_color], al
	pop eax

	call handle_key_and_display
	jmp .start

.load_third_screen:
	call save_screen

	mov esi, third_screen
	mov byte[screen_id], 4

	push eax
	mov al, byte[third_terminal_color]
	mov byte[terminal_color], al
	pop eax

	call handle_key_and_display
	jmp .start

.load_fourth_screen:
	call save_screen

	mov esi, fourth_screen
	mov byte[screen_id], 8

	push eax
	mov al, byte[fourth_terminal_color]
	mov byte[terminal_color], al
	pop eax

	call handle_key_and_display
	jmp .start

.press_alt:
	or byte[keystatus], 00000001b
	jmp .start

.release_alt:
	xor byte[keystatus], 00000001b
	jmp .start

.press_shift:
	mov ecx, shift_kdbus
	jmp .start

.release_shift:
	mov ecx, kdbus
	jmp .start

.press_ctrl:
	or byte[keystatus], 00000010b
	jmp .start

.release_ctrl:
	xor byte[keystatus], 00000010b
	jmp .start

.set_mode_print_hex:
	or byte[keystatus], 00000100b
	jmp .start
	
.unset_mode_print_hex:
	xor byte[keystatus], 00000100b
	jmp .start

.mode_print_hex:
	test byte[keystatus], 00000100b
	jnz .unset_mode_print_hex
	jmp .set_mode_print_hex

.print_hexa:
	pusha
	call print_debug
	popa
	jmp .start

.print_register:
	pusha
	call print_registers
	popa
	jmp .start

.debug_mode:
	cmp ax, 0x02 ; 1 pressed ?
	je .mode_print_hex
	cmp ax, 0x03 ; 2 pressed ?
	je .print_register
	cmp ax, 0x04 ; 3 pressed ?
	call printk
	jmp .start

.switch_screen:
	cmp ax, 0x02 ; 1 pressed ?
	je .load_first_screen
	cmp ax, 0x03 ; 2 pressed ?
	je .load_second_screen
	cmp ax, 0x04 ; 3 pressed ?
	je .load_third_screen
	cmp ax, 0x05 ; 4 pressed ?
	je .load_fourth_screen
	jmp .start

