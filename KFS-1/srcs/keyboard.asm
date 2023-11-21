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

	cmp ax, 0x2A ; shift pressed?
	je .press_shift
	cmp ax, 0x80 ; check release
	jg .key_release
	
	mov eax, [ecx + eax]
	push esi
	call print_debug
	pop esi

.key_release:	
	cmp ax, 0xAA
	je .release_shift
	;cmp byte [keystatus], 00000001b ; shift released?
	jmp .start
	ret

.press_shift:	
;	mov byte [keystatus], 00000001b
	mov ecx, shift_kdbus
	jmp .start

.release_shift:	
;	mov byte [keystatus], 00000000b
	mov ecx, kdbus
	jmp .start

;keystatus dd 0

kdbus db 0,  27, "1", "2", "3", "4", "5", "6", "7", "8", \
	"9", "0", "-", "=", 0X8, \
	0X9, \
	"q", "w", "e", "r", \
	"t", "y", "u", "i", "o", "p", "[", "]", 0XA, \
	0, \
	"a", "s", "d", "f", "g", "h", "j", "k", "l", ";", \
	0X27, "`", 0, \
	0X5C, "z", "x", "c", "v", "b", "n", \
	"m", ",", ".", "/",   0, \
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

;kdbus db 0,  27, "1", "2", "3", "4", "5", "6", "7", "8", \ ;/* 9 */
;	"9", "0", "-", "=", 0X8, \ ; Backspace
;	0X9, \ ; Tab
;	"q", "w", "e", "r", \ ; 19
;	"t", "y", "u", "i", "o", "p", "[", "]", 0XA, \ ; Enter key
;	0, \ ; 29   - Control
;	"a", "s", "d", "f", "g", "h", "j", "k", "l", ";", \ ; 39
;	0X27, "`",   0, \ ; Left shift
;	0X5C, "z", "x", "c", "v", "b", "n", \ ; 49
;	"m", ",", ".", "/",   0, \ ; Right shift
;	"*", \ ;
;	0, \ ; Alt
;	" ", \ ; Space bar
;	0, \ ; Caps lock
;	0, \ ; 59 - F1 key ... >
;	0,   0,   0,   0,   0,   0,   0,   0, \
;	0, \ ; < ... F10
;	0, \ ; 69 - Num lock
;	0, \ ; Scroll Lock
;	0, \ ; Home key
;	0, \ ; Up Arrow
;	0, \ ; Page Up
;	"-", \
;	0, \ ; Left Arrow
;	0,
;	0, \ ; Right Arrow
;	"+",
;	0, \ ; 79 - End key
;	0, \ ; Down Arrow
;	0, \ ; Page Down
;	0, \ ; Insert Key
;	0, \ ; Delete Key
;	0,   0,   0, \
;	0, \ ; F11 Key
;	0, \ ; F12 Key
;	0 ; All other keys are undefined
