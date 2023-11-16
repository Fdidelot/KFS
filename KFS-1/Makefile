NAME = kfs.bin
NAME_ISO = kfs.iso
LINKER = linker.ld

ISO_DIR = isodir

SRCS =	boot.asm \
		kernel.asm

NA = nasm
NAFL = -felf32

OBJS_DIR = ./objs
SRCS_DIR = ./srcs

OBJ =	$(SRCS:.asm=.o)
OBJS =	$(OBJ:%=$(OBJS_DIR)/%)

all: $(NAME) $(NAME_ISO)

$(NAME): $(OBJS)
	ld -m elf_i386 -T $(LINKER) -o $(NAME) $(OBJS)

$(NAME_ISO): $(NAME)
	mkdir -p $(ISO_DIR)/boot/grub
	cp $(NAME) $(ISO_DIR)/boot/$(NAME)
	cp grub.cfg $(ISO_DIR)/boot/grub/grub.cfg
	grub-mkrescue -o $(NAME_ISO) $(ISO_DIR)
 	# if grub-file --is-x86-multiboot $(NAME); then
 	#   echo "multiboot confirmed"
 	# else
 	#   echo "the file is not multiboot"
 	# fi


clean:
	rm -rf $(OBJS_DIR)
	rm -rf $(ISO_DIR)

fclean: clean
	rm $(NAME)
	rm $(NAME_ISO)

re: fclean all

$(OBJS_DIR)/%.o: $(SRCS_DIR)/%.asm
	$(NA) $(NAFL) -o $@ $<

$(OBJS): | $(OBJS_DIR)

$(OBJS_DIR):
	mkdir $(OBJS_DIR)

.PHONY: all clean fclean re