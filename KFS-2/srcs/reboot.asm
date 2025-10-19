global reboot

reboot:
	in   al, 0x64           ; Read keyboard controller status
	test al, 0x02           ; Bit 1 = buffer full ?
	jnz  reboot             ; If yes, wait until it is empty

	mov  al, 0xFE           ; Command "pulse CPU reset line"
	out  0x64, al           ; Send to keyboard controller

.hang:
	hlt                     ; Wait if for some reason the reset fails
	jmp  .hang
