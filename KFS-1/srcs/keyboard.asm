	extern terminal_putchar
	extern print_debug
	global keyboard_handler

keyboard_handler:
	mov ecx, kdbus

.start:
	xor eax, eax
	in al, 0x64 ; wait entries
	test al, 0b00000001
	jz .start
	in al, 0x60 ; read input

	cmp ax, 0x3A ; Caps Lock pressed?
	je .press_caps
	cmp ax, 0x2A ; shift pressed?
	je .press_shift
	cmp ax, 0x80 ; check release
	jg .key_release
	
	mov eax, [ecx + eax]

	cmp byte [keystatus], 00000001b
	je .use_print_debug

	call terminal_putchar

.key_release:
	cmp ax, 0xAA
	je .release_shift
	jmp .start
	ret

.use_print_debug:	
	push esi
	call print_debug
	pop esi
	jmp .start

.press_shift:
	mov ecx, shift_kdbus
	jmp .start

.press_caps:
	cmp byte [keystatus], 00000001b
	je .unset_debug
	cmp byte [keystatus], 00000000b
	je .set_debug
	jmp .start

.set_debug:
	mov byte [keystatus], 00000001b
	jmp .start

.unset_debug:
	mov byte [keystatus], 00000000b
	jmp .start

.release_shift:
	mov ecx, kdbus
	jmp .start

keystatus dd 0

kdbus:
	db 0,  27, "1", "2", "3", "4", "5", "6", "7", "8" ; 9
	db "9", "0", "-", "=", 0X8 ; Backspace
	db 0X9 ; Tab
	db "q", "w", "e", "r" ; 19
	db "t", "y", "u", "i", "o", "p", "[", "]", 0XA ; Enter key
	db 0 ; 29 - Control
	db "a", "s", "d", "f", "g", "h", "j", "k", "l", ";" ; 39
	db 0X27, "`", 0 ; Left Shift
	db 0X5C, "z", "x", "c", "v", "b", "n" ; 49
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
	"(", ")", "_", "+", 0X8, \
	0X9, \
	"Q", "W", "E", "R", \
	"T", "Y", "U", "I", "O", "P", "{", "}", 0XA, \
	0, \
	"A", "S", "D", "F", "G", "H", "J", "K", "L", ":", \
	0X27, "~", 0, \
	0X7C, "Z", "X", "C", "V", "B", "N", \
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
