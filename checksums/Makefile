#
# Makefile for UNIX
#
# Version 1.0: Jan. 1995
# Version 1.1: Aug. 1995 (added UINT32 typedef and a test clause)
# Version 1.1a: November 1995 (version to use with psfonts on CTAN)
#

# Compiler directives and other goodies
CFLAGS = -O
SYSTEM = UNIX

cs:  uint32.h cs.o encoding.o texfiles.o
	$(CC) -o cs encoding.o cs.o texfiles.o

cs.o: cs.c texfiles.h
	$(CC) $(CFLAGS) -c cs.c

uint32.h:	uint32.c
	$(CC) -o uint32 uint32.c
	uint32 > uint32.h

clean:
	rm -f *.o cs uint32 uint32.h
