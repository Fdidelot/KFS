; Extern section
extern handle_key_and_display
extern terminal_color
extern terminal_putchar
extern terminal_putstr
extern print_debug
extern print_registers
extern printk
extern handle_command
extern help

section .rodata
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

shift_kdbus:
	db 0,  0, "!", "@", "#", "$", "%", "^", "&", "*", \
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

intro_str:
	db "Welcome! Use 'help' for a list of commands", 10
	db 0

section .data
global keystatus
keystatus: db 0


section .bss
readline_buffer resb 79
readline_index  resb 1
is_readline_mode resb 1

section .text
global keyboard_handler
keyboard_handler:
	mov edi, intro_str
	call terminal_putstr
	mov ecx, kdbus
	mov byte[is_readline_mode], 1
	mov al, 0x3E
	call terminal_putchar

.start:
	xor eax, eax
	in al, 0x64 ; wait entries
	test al, 0b00000001 ; bit 1 is no entry
	jz .start
	in al, 0x60 ; read input

	cmp al, 0x2A ; shift pressed?
	je .press_shift
	;cmp al, 0x1D ; CTRL pressed?
	;je .press_ctrl
	cmp al, 0x38 ; ALT pressed?
	je .press_alt
	cmp al, 0x80 ; check release
	ja .key_release

	test byte[keystatus], 00000001b ; check debug mode
	jnz .debug_mode

	mov eax, [ecx + eax] ; get char in kdbus/shift_kdbus array
	cmp al, 0 ; skip unused keys
	je .start

	test byte[keystatus], 00000100b ; check print_hex
	jnz .print_hexa

	cmp byte[is_readline_mode], 1
	je .readline_mode

	jmp .start

.readline_mode:
	cmp al, 0xA ; enter pressed
	je .readline_done

	xor ebx, ebx ; clear ebx
	mov bl, [readline_index] ; put index in ebx
	mov [readline_buffer + ebx], al ; add char to buffer + index
	inc byte[readline_index]
	call terminal_putchar

	mov bl, [readline_index]
	cmp bl, 79 ; end of line?
	je .readline_done

	jmp .start

.readline_done:
	cmp byte[readline_index], 0 ; print enter if index != 0
	je .skip
	cmp byte[readline_index], 79 ; print enter if index != buffer size
	je .skip

	push edi
	mov edi, readline_buffer
	push esi
	push ebx
	push ecx
	call handle_command
	pop ecx
	pop ebx
	pop esi
	pop edi
	cmp eax, 0
	je .start

	call print_enter

.skip:

	call print_readline
	call print_enter
	mov al, 0x3E
	call terminal_putchar
	call clear_readline_buffer
	jmp .start

.key_release:
	cmp al, 0xB8 ; break code for alt, release alt?
	je .release_alt
	cmp al, 0xAA ; break code for shift, release shift?
	je .release_shift
	;cmp al, 0x9D ; break code for ctrl, release ctrl?
	;je .release_ctrl
	jmp .start

.press_alt:
	or byte[keystatus], 00000001b
	mov byte[is_readline_mode], 0
	jmp .start

.release_alt:
	xor byte[keystatus], 00000001b
	mov byte[is_readline_mode], 1
	jmp .start

.press_shift:
	mov ecx, shift_kdbus
	jmp .start

.release_shift:
	mov ecx, kdbus
	jmp .start

.press_ctrl:
	or byte[keystatus], 00000010b
	mov byte[is_readline_mode], 0
	jmp .start

.release_ctrl:
	xor byte[keystatus], 00000010b
	mov byte[is_readline_mode], 1
	jmp .start

.set_mode_print_hex:
	or byte[keystatus], 00000100b
	jmp .start
	
.unset_mode_print_hex:
	xor byte[keystatus], 00000100b
	call print_enter
	mov al, 0x3E
	call terminal_putchar
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

.debug_mode:
	cmp al, 0x02 ; 1 pressed ?
	je .mode_print_hex
	jmp .start

print_readline:
	push eax
	push ecx

	xor ecx, ecx

.loop:
	cmp ecx, 79
	jge .end

	mov al, [readline_buffer + ecx]
	cmp al, 0
	je .end
	call terminal_putchar

	inc ecx
	jmp .loop

.end:
	pop ecx
	pop eax
	ret

clear_readline_buffer:
	push ecx

	xor ecx, ecx
.clear_loop:
	cmp ecx, 79
	jge .done

	mov byte[readline_buffer + ecx], 0
	inc ecx
	jmp .clear_loop

.done:
	mov byte[readline_index], 0

	pop ecx
	ret

global print_enter
print_enter:
	mov al, 0xA
	call terminal_putchar
	ret

