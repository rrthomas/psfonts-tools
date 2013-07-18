/*
 * NAME
 *	cs - checksum for TeX fonts
 * SYNOPSIS:
 *	cs [options] font
 * DESCRIPTION
 *      This program can read checksums from existing TeX font files
 *      (TFM/PK/VF). It can also compute the checksum for TeX fonts that
 *	are used to cope with PostScript fonts in the same manner as
 *	afm2tfm(1), as part of dvips version 5.487 or higher, and ps2pk(1)
 *	do. In the case of a PostScript font, the checksum will depend upon:
 *	  - the AFM file (containing WX values)
 *	  - the encoding vector (or built-in default encoding)
 *	  - the amount of extension used (-E<value>).
 *	Slanting has no effect on the checksum because it does not
 *	change the character box.
 *
 *	Options and arguments:
 *	 -n		Use new checksum algorithm.
 *       -o             Print checksum as an octal value.
 *       -e<encoding>   The encoding scheme (default the encoding from the 
 *                      AFM file is used).
 *	 -E<extension>	The extension factor (real value, default 1.0).
 *	 -S<slant>	The slant (real value, default 0.0).
 *	
 *	 font		The name of a TeX PK, TFM or VF font, or the name of
 *			a PostScript AFM file.
 *	
 * SEE ALSO
 *	afm2tfm(1), dvips(1), ps2pk(1)
 * VERSION
 *	1.0 (Januari 1995), derived from an earlier version (part of mtpk).
 *	1.1 (August 1995),  introduced UINT32 type definition so that
 *			    program works correct on 16-bits (Borland C
 *			    on MSDOS) and 64-bits platforms on UNIX
 * AUTHOR
 *	Piet Tutelaers
 *	rcpt@urc.tue.nl
 */

#include <ctype.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "uint32.h"	/* typedef UINT32 <unsigned 32-bits integer>  */
#include "texfiles.h"

/* read checksum (non negative integer less than 2^32) */
UINT32 checksum_texfont(char *name, UINT32 *checksum);

char *encfile = NULL, *afmfile, *font;

typedef char *encoding[256];
void getenc(encoding, int [256]);

int octal = 0, new = 0;

main(argc, argv)
int argc; char *argv[];
{  char *argp, c;
   int done, i;
   char *myname = "cs";

   UINT32 cs;
   encoding ev;
   int WX[256];

   float efactor = 1.0, slant = 0.0;
   
   /* proto's */
   char *locate(char *, char *, char *);
   UINT32 checksum(encoding, int [256]);
   UINT32 new_checksum(encoding, int [256]);
   void fatal(char *fmt, ...);

   while (--argc > 0 && (*++argv)[0] == '-') {
      done=0;
      while ((!done) && (c = *++argv[0]))  /* allow -bcK like options */
      	 switch (c) {
      	 case 'e':
      	    if (*++argv[0] == '\0') {
      	       argc--; argv++;
      	    }
	    encfile = argv[0]; 
	    done = 1;
      	    break;
      	 case 'E':
      	    if (*++argv[0] == '\0') {
      	       argc--; argv++;
      	    }
	    efactor = atof(argv[0]); 
	    done = 1;
      	    break;
      	 case 'S':
      	    if (*++argv[0] == '\0') {
      	       argc--; argv++;
      	    }
	    slant = atof(argv[0]); 
	    done = 1;
      	    break;
      	 case 'n':
      	    new = 1; break;
      	 case 'o':
      	    octal = 1; break;
      	 default:
      	    fatal("%s: %c illegal option\n", myname, c);
      	 }
      }

   if (argc < 1 || argc >2) {
      printf("cs: version 1.1 (Aug. 1995)\n");
      printf("Usage: cs [-o] TeXfont\n");
      printf("   or: cs [-n] [-o] [-e<enc>] [-E<expansion>] [-S<slant>] AFMfile\n");
      exit(1);
   }

   font = argv[0];

   /* Is it a TeX font? */
   if (checksum_texfont(font, &cs)) {
      if (octal)
#ifdef __BORLANDC__
         printf("%lo\n", cs);
#else
         printf("%o\n", cs);
#endif
      else
#ifdef __BORLANDC__
         printf("%lu\n", cs);
#else
         printf("%u\n", cs);
#endif
      exit(0);
   }

   /* It must be an AFM file now */
   afmfile = font;
   getenc(ev, WX);
   if (efactor != 1.0)
      for (i=0; i < 256; i++) {
         if (ev[i] == NULL) continue;
         WX[i] = WX[i] * efactor + 0.5;
      }

   if (new)
      cs = new_checksum(ev, WX);
   else
      cs = checksum(ev, WX);
   if (octal)
#ifdef __BORLANDC__
      printf("%lo\n", cs);
#else
      printf("%o\n", cs);
#endif
   else
#ifdef __BORLANDC__
      printf("%lu\n", cs);
#else
      printf("%u\n", cs);
#endif
   exit(0);
}

/*
 * The checksum should garantee that our PK file belongs to the correct TFM
 * file! Exactly the same as the afm2tfm (dvips5487) calculation.
 */
UINT32 checksum(encoding ev, int width[256])
{
   int i, leftbit ;
   UINT32 s1 = 0, s2 = 0;
   char *p ;

   for (i=0; i<256; i++) {
      if (ev[i] == NULL) continue;
      s1 = (s1<<1) ^ width[i];                   /* left shift */
      for (p=ev[i]; *p; p++)
	 s2 = s2 * 3 + *p ;
   }
   return (s1<<1) ^ s2 ;
}

/*
 * The proposed new checksum algorithm.
 */
UINT32 new_checksum(encoding ev, int width[256])
{
   int i, leftbit ;
   UINT32 s1 = 0, s2 = 0;
   char *p ;

   for (i=0; i<256; i++) {
      if (ev[i] == NULL) continue;
      s1 = ((s1<<1) ^ (s1>>31)) ^ width[i];   /* cyclic left shift */
      for (p=ev[i]; *p; p++)
	 s2 = s2 * 3 + *p ;
   }
   return (s1<<1) ^ s2 ;
}

/* Give up ... */
void fatal(char *fmt, ...)
{  va_list args;

   va_start(args, fmt);
   vfprintf(stderr, fmt, args);
   va_end(args);
   exit(1);
}

#define PKPRE  247
#define PKID    89 
#define VFID   202 

#ifdef MSDOS
#define RB "rb"
#else
#define RB "r"
#endif

/*
 * Checksum_texfont() reads the <checksum> of a TFM file (if filename ends
 * with ".tfm"), PK file (if magic code equals PK) or or VF file (if magic
 * code equals VF). Function returns 1 upon succes otherwise (no TFM, PK or
 * VF file) 0.
 */
 
UINT32 checksum_texfont(char *name, UINT32 *checksum)
{
    FILE *fontfp; int id, i;

    if ((fontfp= fopen(name, RB)) == NULL) 
       fatal("%s: can't open file\n", name);

    if (strcmp(name+strlen(name)-4, ".tfm") ==0) {
    	
        if (fseek(fontfp, 24L, 0))
        {
	    fclose(fontfp);
	    fatal("%s: really a TFM font?\n", name);
        }
        *checksum = four(fontfp);	/* checksum */
        fclose(fontfp);
        return(1);
    }

    /* PK or VF font? */
    if (sone(fontfp) != PKPRE) return 0;
    id = sone(fontfp);
    if (id == VFID) {
         /* skip header */
       for(i=sone(fontfp); i>0; i--) (void)sone(fontfp) ;
       *checksum = four(fontfp);     /* checksum */
    }
    else if (id == PKID) {
         /* skip header */
       for(i=sone(fontfp); i>0; i--) (void)sone(fontfp) ;
       (void) four(fontfp);          /* design size */
       *checksum = four(fontfp);    /* checksum */
    }
    else return 0;

    fclose(fontfp);
    return(1);
}

