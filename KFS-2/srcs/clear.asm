extern clear_terminal
extern terminal_column
extern terminal_row

global clear

clear:
    call clear_terminal
	mov byte[terminal_column], 0
	mov byte[terminal_row], 0
    ret