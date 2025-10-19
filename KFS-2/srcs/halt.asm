global halt

halt:
    cli                 ; disable interrupts
.poweroff:
    mov dx, 0x604       ; Bochs/QEMU shutdown port
    mov ax, 0x2000      ; shutdown code
    out dx, ax          ; send 16-bit value to port
.halt_loop:
    hlt
    jmp .halt_loop
