#!/usr/bin/perl
#
# This script converts an Adobe Font Metric file for a special font to
# TeX font metric, and installs it in a distribution directory. It uses
# afm2tfm.
#
# (c) Sebastian Rahtz June 6th 1994 
#  revised December 11 1995
#  converted to Perl January 23rd 1997
#
$filedate="1997/09/17";
$fileversion="1.2";
use English;
use Getopt::Long;
use File::Basename;
use Cwd;
require "famtool.pl";
$opt_debug=0;
$result = GetOptions (
"debug!",   
"download!",# means that the lines written to psfonts.<family> have "<thisfont"
"outdir=s", # [dir] specifies where the results are to go
"fdcode=s", # extra FD code
"verbose!", # be chatty
    );

if ($result eq 0 ) {  die ("OPTION FAILURE"); }
if ($opt_debug) { $opt_verbose=1;}
die "[makeone] Usage: makeone [options] thisfont\n"  unless @ARGV > 0;

# Parameters:
# $1 The font name, eg psyr
$thisfont=$ARGV[0];
&Setup($thisfont);
#
$AFMfile=`kpsewhich $thisfont.afm`; 
chop($AFMfile);
if ($AFMfile eq "") { die "cannot find $thisfont.afm"; }
system("afm2tfm $AFMfile $thisfont.tfm ");
$FontName=&readAFMfile($AFMfile);
open(MAP,">$Outdir/dvips/$Famcode.map");
print MAP "$thisfont $FontName ";
if ($opt_download) { print MAP " <$thisfont.pfb"; }
print MAP "\n";
close(MAP);
open CONFIG,">$Outdir/dvips/config.$Famcode";
print CONFIG  "p +$Famcode.map\n" ;
close CONFIG;
open (FD,">$Outdir/tex/u$Famcode.fd");
print FD "\\ProvidesFile{u$Famcode.fd}\n";
print FD "  [$year/$mon/$mday font definitions for U/$Famcode.]\n";
print FD "\\DeclareFontFamily{U}{$Famcode}{}\n";
print FD "\\DeclareFontShape{U}{$Famcode}{m}{n}{<->$thisfont}{}\n" ;
print FD "\\endinput\n";
close FD;
&install_symbol_README;
print "Installing metric files in $Outdir/tfm and vf\n"  if $opt_verbose;
&installMetrics;
rmdir("$Outdir/vf");
&Cleanup;
print "Done\n" if $opt_verbose;
