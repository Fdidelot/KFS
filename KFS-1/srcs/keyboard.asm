	extern terminal_putchar
	extern print_debug
	global keyboard_handler

keyboard_handler:
	xor eax, eax
	in al, 0x64
	test al, 0b00000001
	jz keyboard_handler
	in al, 0x60

	cmp ax, 0x80
	jg .skip_release
	
	mov eax, [kdbus + eax]
	push esi
	call print_debug
	pop esi

.skip_release:	
	jmp keyboard_handler
	ret



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
