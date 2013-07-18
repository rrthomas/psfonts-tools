#!/usr/bin/perl
use English;
use Getopt::Long;
use File::Basename;
use Cwd;
require "famtool.pl";
$opt_debug=0;
$result = GetOptions (
"debug!",   
"outdir=s", # [dir] specifies where the results are to go
"verbose!", # be chatty
    );

if ($result eq 0 ) {  die ("OPTION FAILURE"); }
if ($opt_debug) { $opt_verbose=1;}

&Setup(ptm);
if (&IsWin32) {
$ENV{TFMFONTS}=".;";
$ENV{TEXINPUTS}=".;$Inidir/mathptm;$Inidir/mathptmx;";
}
else
{
$ENV{TEXINPUTS}=".:$Inidir/mathptm:$Inidir/mathptmx:";
$ENV{TFMFONTS}=".:";
}

$JOB="fontptcmx";
print "Running fontinst fontptcmx TeX job\n"  if $opt_verbose;
system("tex -ini -progname=fontinst fontptcmx");
system("pltotf psyro.pl psyro.tfm");
$JOB="fontptcm";
print "Running fontinst fontptcm TeX job\n"  if $opt_verbose;
system("tex -ini -progname=fontinst fontptcm");
&buildfilelist;
print "Installing dvips files in $Outdir/dvips\n"  if $opt_verbose;
&installDvips;
print "Installing metric files in $Outdir/tfm and vf\n"  if $opt_verbose;
print "** Making virtual fonts with vptovf\n" if $opt_verbose;
for (grep(/.*\.vpl/,@filenames)) { 
    s/.vpl//;
    my $Basename=$_;
    processVPL($Basename);
 }
 &buildfilelist;
# this is a rogue file, a nolig raw tfm
 unlink "$Outdir/tfm/pzcmi8r.tfm";
 killfiles('.*8r\.tfm') ;
 print "** Installing TFM files in $Outdir/tfm\n" if $opt_verbose;
 for (grep(/.*\.tfm/,@filenames)) { 
 print "Installing $_ \n" if $opt_verbose;
 if (! -r "$Outdir/tfm/$_") { system("mv $_ $Outdir/tfm") ;  }
  }
 print "** Installing VF files in $Outdir/vf\n" if $opt_verbose;
 for (grep(/.*\.vf/,@filenames)) {
  print "Installing $_ \n" if $opt_verbose;
  if (! -r "$Outdir/vf/$_") { system("mv $_ $Outdir/vf") ; }
 }
print "Installing LaTeX files in $Outdir/tex\n"  if $opt_verbose;
for (grep(/.*\.fd/,@filenames)) { 
   if (! -r "$Outdir/tex/$_") { system("cp $_ $Outdir/tex") ; }
  }


&Cleanup;

&remove_duplicates("$Outdir/dvips/ptm.map");
&remove_duplicates("$Outdir/dvips/config.ptm");
print "Done\n" if $opt_verbose;
#-------------------------------------------------------------------

sub IsWin32 {
    return $^O =~ 'MSWin32';
}
