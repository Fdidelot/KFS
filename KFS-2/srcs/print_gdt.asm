extern printk
extern printk_start_address
extern printk_end_address

section .text
global print_gdt
print_gdt:
	mov dword[printk_start_address], 0x800
	mov dword[printk_end_address], 0x900
	call printk
	ret
