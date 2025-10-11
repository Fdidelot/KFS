extern setup_gdt
extern kernel_stack_top
extern user_stack_top
extern tss_entry
extern kfs_mfpd_main

global enter_user_mode


section .data
; Sélecteurs
KERNEL_CS equ 0x08
KERNEL_DS equ 0x10
KERNEL_SS equ 0x18
USER_CS   equ 0x20
USER_DS   equ 0x28
USER_SS   equ 0x30
TSS_SEL   equ 0x38

section .text
setup_gdt:

    lgdt [gdtr]         ; Charger GDTR

    ; Activer PE
    mov eax, cr0
    or  eax, 1
    mov cr0, eax

    ; Far jump pour charger CS
    jmp KERNEL_CS:protected_gdt_entry

protected_gdt_entry:
    ; Recharger les autres registres
    mov ax, KERNEL_DS
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ax, KERNEL_SS
    mov ss, ax
    mov [tss_entry + 4], ax   ; ss0
    mov dword [tss_entry + 8], kernel_stack_top  ; esp0
    mov ax, TSS_SEL
    ltr ax

    ret
; ------- GDT -------
section .gdt
align 8
gdt_table:
    ; Descripteur NULL (8 bytes)
    dq 0

    ; Kernel Code segment (base=0, limit=4GiB, DPL=0)  access=0x9A, flags=0xCF
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 0x9A
    db 0xCF
    db 0x00

    ; Kernel Data segment (base=0, limit=4GiB, DPL=0) access=0x92
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 0x92
    db 0xCF
    db 0x00

    ; Kernel Stack segment (traité comme Data R/W, DPL=0)
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 0x92
    db 0xCF
    db 0x00

    ; User Code segment (base=0, limit=4GiB, DPL=3) access=0xFA (0x9A | DPL=3)
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 0xFA
    db 0xCF
    db 0x00

    ; User Data segment (DPL=3) access=0xF2 (0x92 | DPL=3)
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 0xF2
    db 0xCF
    db 0x00

    ; User Stack segment (DPL=3) access=0xF2
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 0xF2
    db 0xCF
    db 0x00

tss_limit equ 103
tss_base  equ 104
	dw tss_limit & 0xFFFF
	dw tss_base & 0xFFFF
	db (tss_base >> 16) & 0xFF
	db 0x89                    ; type=0x9, S=0, P=1
	db ((tss_limit >> 16) & 0xF)
	db (tss_base >> 24) & 0xFF
gdt_end:

gdtr:
    dw gdt_end - gdt_table - 1
	dd gdt_table

; -------------------------------
; Passage en Ring 3
; -------------------------------
enter_user_mode:
	mov ax, USER_DS
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax

	mov eax, user_stack_top
	push USER_DS
	push eax
	pushf
	push USER_CS
	push user_code_label
	ret

user_code_label:
; code en Ring 3
	call kfs_mfpd_main
	hlt
