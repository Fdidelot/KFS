extern printk
extern printk_start_address
extern printk_end_address
extern kernel_stack_bottom
extern kernel_stack_top

section .rodata
stack_string_part_one db 'The ', 0
stack_string_part_two db 'stac', 0
stack_string_part_three db 'k is', 0
stack_string_part_four db ' her', 0
stack_string_part_five db 'e!!!', 0

section .text
global print_stack
print_stack:
    mov eax, [stack_string_part_five]
    push eax
    mov eax, [stack_string_part_four]
    push eax
    mov eax, [stack_string_part_three]
    push eax
    mov eax, [stack_string_part_two]
    push eax
    mov eax, [stack_string_part_one]
    push eax
	mov dword[printk_start_address], kernel_stack_bottom
	mov dword[printk_end_address], kernel_stack_top
	call printk
    pop eax
    pop eax
    pop eax
    pop eax
    pop eax
	ret
