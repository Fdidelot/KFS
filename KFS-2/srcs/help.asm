extern terminal_putstr

section .rodata
help_text	db "Available commands :", 10
			db "  help   - Show this help message", 10
			db "  clear  - clear the screen", 10
			db "  regs   - Print registers", 10
			db "  reboot - Reboot the system", 10
			db "  halt   - Power off the system", 10
			db 10
			db "Available shorcuts :", 10
			db "  Ctrl+1/4  - Switch colored screen", 10
			db "  Alt+1     - Debug mode", 10
			db "  Alt+2     - Print registers", 10
			db "  Alt+3     - Print memory", 10
			db "  Shift+key - Print Uppercase", 10
			db 0

section .text
global help
help:
	pusha
	mov ecx, 0
	mov edi, help_text
	call terminal_putstr
	popa
	ret

