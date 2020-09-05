decode_ean8: first.c second.s
	cc -m32 -std=c99 -c first.c
	nasm -f elf32 second.s
	cc -m32 -o decode_ean8 first.o second.o
	rm first.o second.o