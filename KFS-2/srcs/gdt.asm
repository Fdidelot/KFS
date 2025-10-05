[BITS 32]
extern setup_gdt

setup_gdt:
    ; -----------------------
    ; Copier la GDT en RAM (ici on suppose que tu as une GDT statique)
    ; -----------------------
    ; Adresse de la GDT
    mov eax, gdt_table
    mov [gdtr_base], eax
    mov word [gdtr_limit], gdt_end - gdt_table - 1

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
    ret
; ------- GDT -------
[BITS 16]
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
gdt_end:

gdtr:
    gdtr_limit: dw gdt_end - gdt_table - 1
    gdtr_base:  dd 0x00000800

; Sélecteurs
KERNEL_CS equ 0x08
KERNEL_DS equ 0x10
KERNEL_SS equ 0x18
USER_CS   equ 0x20
USER_DS   equ 0x28
USER_SS   equ 0x30