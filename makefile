CC=gcc
CFLAGS=-m64 -Wall
DFLAGS=-g -O0
LIBS=-lallegro -lallegro_font


deb:	main.o juliaSet.o
		$(CC) $(CFLAGS) $(DFLAGS) main.o juliaSet.o -o debug $(LIBS)
all:	main.o juliaSet.o
		$(CC) $(CFLAGS) main.o juliaSet.o -o f
main.o:	main.c 
		$(CC) $(CFLAGS) -c main.c -o main.o
juliaSet.o:	juliaSet.s
		nasm -f elf64 juliaSet.s
clean:
		rm -rf *.o juliaSet debug