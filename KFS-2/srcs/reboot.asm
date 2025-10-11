global reboot

reboot:
	in   al, 0x64           ; Lire le status du contrôleur clavier
	test al, 0x02           ; Bit 1 = buffer d’entrée plein ?
	jnz  reboot  ; Si oui, attendre qu’il soit vide

	mov  al, 0xFE           ; Commande "pulse CPU reset line"
	out  0x64, al           ; Envoyer au contrôleur clavier

.hang:
	hlt                     ; Si pour une raison quelconque le reset échoue
	jmp  .hang
