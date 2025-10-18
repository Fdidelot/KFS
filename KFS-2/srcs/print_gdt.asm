extern printk

section .text
global print_gdt
print_gdt:
	call printk
	ret
