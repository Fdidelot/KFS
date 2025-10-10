global	ft_strcmp

section	.text

ft_strcmp:
	xor		eax, eax

.loop:
	mov dl, byte [edi + eax]
	mov cl, byte [esi + eax]
	inc eax
	cmp dl, 0x0
	je .end
	cmp cl, 0x0
	je .end
	cmp dl, cl
	je .loop

.end:
	sub dl, cl
	movsx eax, dl ;move data with sign or zero extend
	ret

