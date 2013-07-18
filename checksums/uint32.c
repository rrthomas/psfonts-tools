/*
 * File:	uint32.c
 * Purpose:	determine proper type definition for UINT32
 *
 * Version 1.0: Aug. 1995
 */

#include <stdio.h>

#define TEST(type)				\
   { type s; 					\
     s = 1; bits = 0;				\
     while (s != 0) { s <<= 1; bits++; }	\
     if (bits == 32) {				\
	printf("typedef %s UINT32;\n", #type);	\
	exit(0);				\
     }						\
   }

main() {

   int bits;

   TEST(unsigned int);		/* 32 bits? */
   TEST(unsigned long);		/* 16 bits? */
   TEST(unsigned short);	/* 64 bits? */

   /* What else? */
   fprintf(stderr, "No proper unsigned 32 bit type found\n");
   exit(1);
}

