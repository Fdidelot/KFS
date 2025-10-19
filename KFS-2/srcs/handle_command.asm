extern print_enter
extern ft_strcmp
extern help
extern print_registers
extern reboot
extern clear
extern print_gdt
extern halt

section .rodata
help_str db "help", 0
clear_str db "clear", 0
regs_str db "regs", 0
reboot_str db "reboot", 0
halt_str db "halt", 0
gdt_str db "gdt", 0
;stack_str db "stack", 0

; Commands str table null terminated
commands:
	dd help_str
	dd clear_str
	dd regs_str
	dd reboot_str
	dd halt_str
	dd gdt_str
	;dd stack_str
	dd 0

; Table of related functions
handlers:
	dd help
	dd clear
	dd print_registers
	dd reboot
	dd halt
	dd print_gdt
	;dd print_stack
	dd 0

section .text
global handle_command

; -------------------------------------------------
; handle_command:
;   EDI -> buffer utilisateur (readline_buffer)
; -------------------------------------------------
handle_command:
    mov esi, commands
    mov ebx, handlers

.loop:
    mov eax, [esi]          ; charger pointeur vers commande
    test eax, eax           ; fin de table ?
    jz .done

    push esi                ; sauvegarder table ptr
    push ebx

    mov esi, eax            ; esi = cmd_i
    call ft_strcmp          ; compare readline_buffer (edi) et cmd_i
    test eax, eax
    jz .found               ; si == 0 => trouvé

    pop ebx
    pop esi
    add esi, 4              ; commande suivante
    add ebx, 4              ; handler suivant
    jmp .loop

.found:
	call print_enter
    pop ebx                 ; handler table
    pop esi                 ; restore command table
    mov eax, [ebx]          ; eax = fonction associée
    call eax                ; call fonction
	xor eax, eax            ; set eax = 0 for return value
	ret

.done:
	mov eax, -1
    ret
