BITS 32

    ; Extern section
    extern set_terminal_colors
    extern add_headers
    extern terminal_write_string
    extern keyboard_handler

	; Global section
	global kfs_mfpd_main
	global handle_key_and_display

	section .data

	section .text
; start of the kernel, set colors, add headers to the terms
kfs_mfpd_main:
	call set_terminal_colors

	call add_headers
	mov esi, eax ; first screen in esi

    call handle_key_and_display
    ret

;display a term on the physical terminal and wait for a key
handle_key_and_display:
	call terminal_write_string
	call keyboard_handler
	ret
