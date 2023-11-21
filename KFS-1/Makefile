NAME = kfs.bin
NAME_ISO = kfs.iso
LD_SCRIPT = linker.ld

ISO_DIR = iso_dir

SRCS =	boot.asm \
		kernel.asm \
		keyboard.asm \
		print_debug.asm \
		print_hexa.asm \
		screen.asm

NA = nasm
NAFL = -felf32

OBJS_DIR = ./objs
SRCS_DIR = ./srcs

OBJ =	$(SRCS:.asm=.o)
OBJS =	$(OBJ:%=$(OBJS_DIR)/%)

all: $(NAME) $(NAME_ISO)

$(NAME): $(OBJS)
	ld -m elf_i386 -T $(LD_SCRIPT) -o $(NAME) $(OBJS)

$(NAME_ISO): $(NAME)
	mkdir -p $(ISO_DIR)/boot/grub
	cp $(NAME) $(ISO_DIR)/boot/$(NAME)
	cp grub.cfg $(ISO_DIR)/boot/grub/grub.cfg
	grub-mkrescue -o $(NAME_ISO) $(ISO_DIR)

clean:
	rm -rf $(OBJS_DIR)
	rm -rf $(ISO_DIR)
	rm -f Makefile~
	rm -f $(SRCS_DIR)/*~

fclean: clean
	rm -f $(NAME)
	rm -f $(NAME_ISO)

re: fclean all

$(OBJS_DIR)/%.o: $(SRCS_DIR)/%.asm
	$(NA) $(NAFL) -o $@ $<

$(OBJS): | $(OBJS_DIR)

$(OBJS_DIR):
	mkdir $(OBJS_DIR)

qemu: all
	qemu-system-i386 kfs.iso

.PHONY: all clean fclean re qemu
