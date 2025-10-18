extern terminal_putchar

section .text
global terminal_putstr

; -------------------------------------------------
; terminal_putstr:
;   EDI -> string to print
; -------------------------------------------------
terminal_putstr:
	pusha
	mov ecx, 0

.loop:
	mov al, [edi + ecx]
	cmp al, 0
	je .end
	mov al, [edi + ecx]
	call terminal_putchar
	inc ecx
	jmp .loop

.end:
	popa
	ret
