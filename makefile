CC = gcc
NASM = nasm
CFLAGS = `pkg-config --cflags allegro-5 allegro_font-5`
LDFLAGS = `pkg-config --libs allegro-5 allegro_font-5`
ASMFLAGS = -f elf64

all: julia

julia: main.o juliaSet.o
	$(CC) -o julia main.o juliaSet.o $(LDFLAGS)

main.o: main.c juliaSet.h constants.h
	$(CC) $(CFLAGS) -c main.c -o main.o

juliaSet.o: juliaSet.s
	$(NASM) $(ASMFLAGS) juliaSet.s -o juliaSet.o

clean:
	rm -f *.o julia