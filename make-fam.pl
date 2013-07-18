#!/usr/bin/perl
#
# This script writes a .tex file which does the necessary work 
# of converting Adobe Font Metric files for a `normal' font family,
# runs fontinst on it, adds checksums,
# converts the resulting files,
# and installs them in distribution directories.
#
# (c) Sebastian Rahtz February 6th 1994--January 1997.
#  Piet Tutelaers (rcpt@urc.tue.nl) added a lot of
#  material in the sh version which I have (I hope) 
#  adapted to Perl properly, and I have also folded in his
#  Perl code to add checksums.
#
#        1) run fontinst              
#        2) install DVIPS files       (result: $OUT/dvips)
#        3) install TFM and VF files  (result: $OUT/vf)
#        4) install TFM files         (result: $OUT/tfm)
#        5) install FD and STY files  (result: $OUT/tex)
#        6) install README file       (result: $OUT/README)
#----------------------------------------------------------------
# The user has to supply the Berry family name, and (optionally) 
# any special code to run when the family is loaded.
# The output is:
#  - three .fd files (one for T1, one for OT1, and one for 8r)
#  - .tfm and .vf files
#  - a file <family>.map (could be appended to psfonts.map (for dvips))
#  - a file config.<family> (for use with dvips, referencing psfonts.<family>)
#  - a file <family>.sty package file for trivial use of font family
# Intermediate files are deleted.
#

use English;
use Getopt::Long;
use File::Basename;
use Cwd;

$filedate="1997/09/17";
$fileversion="1.2";

require "famtool.pl";

$opt_debug=0;
$opt_slant=".167";

$result = GetOptions (
"debug!",   
"download!",# means that the lines written to psfonts.<family> have "<fontname"
"sans!",    # means this is a sanserif font
"tt!",      # means that this is a typewriter family
"outdir=s", # [dir] specifies where the results are to go
"lucida!",  # means add special code for Lucida scaling
"nosty!",   # means do NOT produce a .sty file
"narrow=s", # [width] means generate narrow fonts
"slant=s",  # [amount] means amount to slant fake oblique
"fdcode=s", # extra FD code
"expert=s", # means this is to be set up as an expert set, suffix s
"verbose!", # be chatty
    );

if ($result eq 0 ) {  die ("OPTION FAILURE"); }
if ($opt_debug) { $opt_verbose=1;}
die "[makefam] Usage: makefam [options] fontname\n"  unless @ARGV > 0;

&Setup($ARGV[0]);

$Type="\\rm";
if ($opt_tt)   { $Type="\\tt"; $ExtraFDCode="\\hyphenchar\\font=-1" ;}
if ($opt_sans) { $Type="\\sf"; }
if ($opt_fdcode ne "")   { $ExtraFDCode="$opt_fdcode" ;}

print "Running fontinst TeX job\n"  if $opt_verbose;
&runTeX;

&buildfilelist;

print "Installing dvips files in $Outdir/dvips\n"  if $opt_verbose;
&installDvips;

print "Installing metric files in $Outdir/tfm and vf\n"  if $opt_verbose;
&installMetrics;

print "Installing LaTeX files in $Outdir/tex\n"  if $opt_verbose;
&installTeX;

&Cleanup;

print "Done\n" if $opt_verbose;

#-------------------------------------------------------------------

