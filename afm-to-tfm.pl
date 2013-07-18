#!/usr/bin/perl
# Make the dvips-encoded vf/tfm using afm2tfm
# Karl Berry, Sebastian Rahtz 1995--1998
# Assumes web2c 7 setup.
# Translated from sh to Perl, SPQR 1997/09/18
use English;
use Getopt::Long;
use File::Basename;
use Cwd;

$filedate="1998/07/04";
$fileversion="1.1";

require "famtool.pl";
$opt_debug=0;
$opt_verbose=0;

$result = GetOptions (
"debug!",   
"verbose!",   
"outdir=s", # [dir] specifies where the results are to go
		      );
if ($result eq 0 ) {  die ("OPTION FAILURE"); }
if ($opt_debug) { $opt_verbose=1;}

$FontName=@ARGV[0];


&texSetup;
mkdir($opt_outdir,0777);
chdir("$opt_outdir");
$Outdir = getcwd();
mkdir("$Outdir/vpl",0777);
mkdir("$Outdir/pl",0777);
mkdir("$Outdir/tfm",0777);
mkdir("$Outdir/vf",0777);
mkdir("$Outdir/dvips",0777);
$BaseEnc="8r.enc";
$UserEnc="dvips.enc";
$vorV="-v";
$AtoToptions="";
$_=$FontName;
($famcode) = /(...).*/;
mkdir("/tmp/Fam_$$",0777);
chdir("/tmp/Fam_$$");
$Tmpdir=getcwd();
open(ENC,">8r.enc") || die "cannot open /tmp/Fam_$$/8r.enc";
open(OLDENC,"$Inidir/8r.enc") || die "cannot open $Inidir/8r.enc";
while (<OLDENC>) { print ENC $_; }
close (ENC);
close (OLDENC);
open(ENC,">dvips.enc") || die "cannot open /tmp/Fam_$$/dvips.enc";
open(OLDENC,"$Inidir/dvips.enc") || die "cannot open $Inidir/dvips.enc";
while (<OLDENC>) { print ENC $_; }
close (ENC);
close (OLDENC);
# If we have a natural afm file (e.g., pagko), then we just use
# that. Otherwise (e.g., pplro), we manipulate the roman. Check this first,
# because the natural file might be almost anything (e.g., uaqrrc is not
# smallcaps).
$BaseName=$FontName . "8r";
$AFMfile=$FontName . "8a";
print "For $AFMfile, search for $AFMfile.afm first\n" if $opt_verbose;
$AFMpath=`kpsewhich $AFMfile.afm`; 
chop $AFMpath;
if ($AFMpath eq "") {
# Determine the AFM file to read for this, and/or the extra options for
# afm2tfm, and/or the name of the base font for the VF.
#
# allow for real narrow AFM files
#
    $_=$FontName;
    $AFMfile=$FontName . "8a";
    if (/.*on$/) 
      {
# oblique narrow -> oblique
        $BaseName =~ s/on8r$/o8rn/;
        $AFMfile =~ s/on8a$/o8an/;	
        $AFMpath=`kpsewhich $AFMfile.afm`; 
        chop $AFMpath;
        if ($AFMpath eq "") {
            $AFMfile =~ s/8an$/8a/;	
            $AFMpath=`kpsewhich $AFMfile.afm`; 
            chop $AFMpath;
            $AtoToptions="-e .82";
        }
    }
    elsif (/.*rn$/) {
# upright narrow -> rm
      $BaseName =~ s/rrn8r$/r8rn/;
      $AFMfile =~ s/rn8a$/8an/;
      $AFMpath=`kpsewhich $AFMfile.afm`; 
      chop $AFMpath;
      if ($AFMpath eq "") {
	$AFMfile =~ s/8an$/8a/;
        $AFMpath=`kpsewhich $AFMfile.afm`; 
        chop $AFMpath;
        $AtoToptions="-e .82";
    }
     }
    elsif (/.*c$/) {
# caps and small caps -> rm
	$AFMfile =~ s/c8a$/8a/;
	$BaseName =~ s/c8r$/8r/;
        $vorV="-V";
     }
    elsif (/.*u$/) {
# unslanted italic -> italic
	$AFMfile =~ s/u8a$/i8a/;
        $AtoToptions="-s -.1763";
     }
    elsif (/.*re$/) {
# extended -> rm
	$AFMfile =~ s/re8a$/8a/;
	$BaseName =~ s/re8r$/r8re/;
        $AtoToptions="-e 1.2";
     }
    elsif (/.*o$/) {
# constructed oblique -> rm
	$AFMfile =~ s/o8a$/8a/;
        $AtoToptions="-s .167";
     }
}
print "now use $AFMfile.afm, and base of $BaseName\n" if $opt_verbose;
$AFMpath=`kpsewhich $AFMfile.afm`; 
chop $AFMpath;
if ($AFMpath eq "") { die "no AFM file found: $AFMfile.afm";}
$job="afm2tfm $AFMpath -u -p $BaseEnc -t $UserEnc $AtoToptions $vorV $FontName.vpl  $BaseName.tfm";
print "Run $job\n" if $opt_verbose;
open(JOB,"$job |" ) || die "cannot run $job";
open(MAP,">>$Outdir/dvips/$famcode.map") ;
while (<JOB>) {
    chop;
 print "..$_\n" if $opt_verbose;
 if (/Extend/) { print MAP "$_\n"; }
 elsif (/Slant/) { print MAP "$_\n"; }
 else { print "do not use map line $_\n" if $opt_verbose; }
}
close(JOB);
close(MAP);
# We don't want the raw tfms unless we had funny options
if ($AtoToptions eq "") { 
   print "remove  $BaseName.tfm\n" if $opt_verbose;
   unlink "$BaseName.tfm";	
}

# Times-Roman and obliqued Times-Roman can use the Greek letters from Symbol.
if ($FontName eq "ptmr")
 {
     ptmrGreek("$FontName.vpl");
 }
elsif ($FontName eq "ptmro")
 {
     ptmroGreek("$FontName.vpl");
 }

runsystem("vptovf $FontName.vpl $FontName.vf $FontName.tfm");
&buildfilelist;
print "** Installing PL files in $Outdir/pl\n" if $opt_verbose;
 for (grep(/.*\.pl/,@filenames)) { 
 print "Installing $_ \n" if $opt_verbose;
 if (! -r "$Outdir/pl/$_") { runsystem("mv $_ $Outdir/pl") ;  }
  }
print "** Installing VPL files in $Outdir/vpl\n" if $opt_verbose;
 for (grep(/.*\.vpl/,@filenames)) { 
 print "Installing $_ \n" if $opt_verbose;
 if (! -r "$Outdir/vpl/$_") { runsystem("mv $_ $Outdir/vpl") ;  }
  }
print "** Installing TFM files in $Outdir/tfm\n" if $opt_verbose;
 for (grep(/.*\.tfm/,@filenames)) { 
 print "Installing $_ \n" if $opt_verbose;
 if (! -r "$Outdir/tfm/$_") { runsystem("mv $_ $Outdir/tfm") ;  }
  }
print "** Installing VF files in $Outdir/vf\n" if $opt_verbose;
 for (grep(/.*\.vf/,@filenames)) {
  print "Installing $_ \n" if $opt_verbose;
  if (! -r "$Outdir/vf/$_") { runsystem("mv $_ $Outdir/vf") ; }
 }
remove_duplicates ("$Outdir/dvips/$famcode.map");
&Cleanup;


print "Done\n" if $opt_verbose;

sub ptmrGreek {
     local($file) = @_;
 open(IN,$file);
 open(OUT,">$file.new");
while (<IN>) {
if (/\(VTITLE/)
 { 
   s/\)/, then edited for Greek)/ ; 
   print OUT; 
}
elsif (/LIGTABLE/) 
 {    print OUT <<THATSIT;
(MAPFONT D 1
   (FONTNAME psyr)
   )
THATSIT
print OUT ;

 }
else
 {print OUT;}
}
print OUT <<THATSIT;
(CHARACTER O 0 (comment Gamma)
   (CHARWD R 603)
   (CHARHT R 689)
   (CHARIC R 6)
   (MAP
      (SELECTFONT D 1)
      (SETCHAR C G)
      )
   )
(CHARACTER O 1 (comment Delta)
   (CHARWD R 612)
   (CHARHT R 689)
   (MAP
      (SELECTFONT D 1)
      (SETCHAR C D)
      )
   )
(CHARACTER O 2 (comment Theta)
   (CHARWD R 741)
   (CHARHT R 689)
   (CHARDP R 7)
   (MAP
      (SELECTFONT D 1)
      (SETCHAR C Q)
      )
   )
(CHARACTER O 3 (comment Lambda)
   (CHARWD R 686)
   (CHARHT R 689)
   (MAP
      (SELECTFONT D 1)
      (SETCHAR C L)
      )
   )
(CHARACTER O 4 (comment Xi)
   (CHARWD R 645)
   (CHARHT R 689)
   (MAP
      (SELECTFONT D 1)
      (SETCHAR C X)
      )
   )
(CHARACTER O 5 (comment Pi)
   (CHARWD R 768)
   (CHARHT R 689)
   (MAP
      (SELECTFONT D 1)
      (SETCHAR C P)
      )
   )
(CHARACTER O 6 (comment Sigma)
   (CHARWD R 592)
   (CHARHT R 689)
   (MAP
      (SELECTFONT D 1)
      (SETCHAR C S)
      )
   )
(CHARACTER O 7 (comment Upsilon1)
   (CHARWD R 620)
   (CHARHT R 689)
   (MAP
      (SELECTFONT D 1)
      (SETCHAR O 241)
      )
   )
(CHARACTER O 10 (comment Phi)
   (CHARWD R 763)
   (CHARHT R 689)
   (MAP
      (SELECTFONT D 1)
      (SETCHAR C F)
      )
   )
(CHARACTER O 11 (comment Psi)
   (CHARWD R 795)
   (CHARHT R 689)
   (MAP
      (SELECTFONT D 1)
      (SETCHAR C Y)
      )
   )
(CHARACTER O 12 (comment Omega)
   (CHARWD R 768)
   (CHARHT R 689)
   (MAP
      (SELECTFONT D 1)
      (SETCHAR C W)
      )
   )
(CHARACTER O 13 (comment arrowup)
   (CHARWD R 603)
   (CHARHT R 907)
   (MAP
      (SELECTFONT D 1)
      (SETCHAR O 255)
      )
   )
(CHARACTER O 14 (comment arrowdown)
   (CHARWD R 603)
   (CHARHT R 907)
   (CHARDP R 7)
   (MAP
      (SELECTFONT D 1)
      (SETCHAR O 257)
      )
   )
THATSIT
close (OUT);
close(IN);
unlink $file;
rename ("$file.new",$file);
}

sub ptmroGreek {
 local($file) = @_;
 open(IN,$file);
 open(OUT,">$file.new");
while (<IN>) {
if (/\(VTITLE/)
 { 
   s/\)/, then edited for Greek)/ ; 
   print OUT; 
}
elsif (/LIGTABLE/) 
 {    print OUT <<THATSIT;
(MAPFONT D 1
   (FONTNAME psyro)
   )
THATSIT
print OUT ;

 }
else
 {print OUT;}
}
print OUT <<THATSIT;
(CHARACTER O 0 (comment Gamma)
   (CHARWD R 603)
   (CHARHT R 689)
   (CHARIC R 118)
   (MAP
      (SELECTFONT D 1)
      (SETCHAR C G)
      )
   )
(CHARACTER O 1 (comment Delta)
   (CHARWD R 612)
   (CHARHT R 689)
   (CHARIC R 111)
   (MAP
      (SELECTFONT D 1)
      (SETCHAR C D)
      )
   )
(CHARACTER O 2 (comment Theta)
   (CHARWD R 741)
   (CHARHT R 689)
   (CHARDP R 7)
   (CHARIC R 87)
   (MAP
      (SELECTFONT D 1)
      (SETCHAR C Q)
      )
   )
(CHARACTER O 3 (comment Lambda)
   (CHARWD R 686)
   (CHARHT R 689)
   (CHARIC R 109)
   (MAP
      (SELECTFONT D 1)
      (SETCHAR C L)
      )
   )
(CHARACTER O 4 (comment Xi)
   (CHARWD R 645)
   (CHARHT R 689)
   (CHARIC R 66)
   (MAP
      (SELECTFONT D 1)
      (SETCHAR C X)
      )
   )
(CHARACTER O 5 (comment Pi)
   (CHARWD R 768)
   (CHARHT R 689)
   (CHARIC R 89)
   (MAP
      (SELECTFONT D 1)
      (SETCHAR C P)
      )
   )
(CHARACTER O 6 (comment Sigma)
   (CHARWD R 592)
   (CHARHT R 689)
   (CHARIC R 109)
   (MAP
      (SELECTFONT D 1)
      (SETCHAR C S)
      )
   )
(CHARACTER O 7 (comment Upsilon1)
   (CHARWD R 620)
   (CHARHT R 689)
   (CHARIC R 104)
   (MAP
      (SELECTFONT D 1)
      (SETCHAR O 241)
      )
   )
(CHARACTER O 10 (comment Phi)
   (CHARWD R 763)
   (CHARHT R 689)
   (CHARIC R 89)
   (MAP
      (SELECTFONT D 1)
      (SETCHAR C F)
      )
   )
(CHARACTER O 11 (comment Psi)
   (CHARWD R 795)
   (CHARHT R 689)
   (CHARIC R 100)
   (MAP
      (SELECTFONT D 1)
      (SETCHAR C Y)
      )
   )
(CHARACTER O 12 (comment Omega)
   (CHARWD R 768)
   (CHARHT R 689)
   (CHARIC R 83)
   (MAP
      (SELECTFONT D 1)
      (SETCHAR C W)
      )
   )
(CHARACTER O 13 (comment arrowup)
   (CHARWD R 603)
   (CHARHT R 907)
   (CHARIC R 120)
   (MAP
      (SELECTFONT D 1)
      (SETCHAR O 255)
      )
   )
(CHARACTER O 14 (comment arrowdown)
   (CHARWD R 603)
   (CHARHT R 907)
   (CHARDP R 7)
   (CHARIC R 116)
   (MAP
      (SELECTFONT D 1)
      (SETCHAR O 257)
      )
   )
THATSIT
close (OUT);
close(IN);
unlink $file;
rename ("$file.new",$file);
}


