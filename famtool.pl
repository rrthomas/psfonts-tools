#
# Perl subroutines to support the AFM to TFM font conversion
# scripts using fontinst
#
# Sebastian Rahtz, January 1997
#
# 1.0 January 1997
# 1.1 1997/02/09
# 1.2 1997/02/13
# 1.3 1997/09/17
# 1.4 1997/10/04
# 1.5 1998/05/19, with help from Ulrik Vieth
# 1.6 1998/06/02, correction from UV
# 1.7 1998/07/04, small changes for fontinst 1.8 and other cleanups
#-----------------------------------------------------------------
sub texSetup {
#
# get the date right
#
($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) =
						localtime(time);
$year = $year + 1900;
$mon = $mon +1 ;
if ($mon < 10) { $mon= "0" . $mon; } 
if ($mday < 10) { $mday= "0" . $mday; } 
$Inidir = getcwd();
if (&IsWin32) {
$ENV{TFMFONTS}=".;";
}
else
{
$ENV{TFMFONTS}=".:";
}

}
sub Setup {
my ($JOB) = @_;
&texSetup;
if ($opt_outdir eq "") { $opt_outdir=$Inidir; }
&readfontnames;
$_=$JOB;
($sname,$fname,$famextra) = /(.)(..)(.*)/;
$Famcode=$sname . $fname;
$Foundry=$Foundries{$sname};
$Family=$Typefaces{$fname};
$ShortFamily=$Shortnames{$fname} . $opt_extra;
$Outdir="$opt_outdir/$Foundry/$ShortFamily";
if (! -d "$opt_outdir")
 { mkdir("$opt_outdir",0777) 
	|| die ("cannot make $opt_outdir"); }
if (! -d "$opt_outdir/$Foundry")
  { mkdir("$opt_outdir/$Foundry",0777) 
	|| die ("cannot make $opt_outdir/$Foundry"); }
mkdir("$opt_outdir/$Foundry/$ShortFamily",0777);
mkdir("$Outdir/dvips",0777);
mkdir("$Outdir/tfm",0777);
mkdir("$Outdir/vf",0777);
mkdir("$Outdir/vpl",0777);
mkdir("$Outdir/pl",0777);
mkdir("$Outdir/tex",0777);
print "work on $Famcode$opt_expert ($famextra) / $ShortFamily / $Family\n"  if $opt_verbose;
print "TeX search path is $ENV{TEXINPUTS}\n";
#
# convert relative path to absolute, since we are operating from /tmp
#
chdir("$Outdir") || die ("cannot change directory to $Outdir");
$Outdir = getcwd();
print "results to $Outdir\n";
if (! -d "/tmp/Fam_$$")
  { mkdir("/tmp/Fam_$$",0777)
	|| die ("cannot make dir /tmp/Fam_$$"); }
chdir("/tmp/Fam_$$")      || die ("cannot change dir to /tmp/Fam_$$");
}

#-----------------------------------------------------------------
sub buildfilelist {
    opendir(DIR,'.') 
    || die ("ERROR: cannot open directory");
    @filenames =grep(!/^\.\.?$/,readdir(DIR));
    closedir(DIR);
}
#-----------------------------------------------------------------
sub readfontnames
{
my $colA,$colB,$ColC,$ColD;
open(SH,"kpsewhich supplier.map |") 
    || die "cannot run kpsewhich to get supplier.map"; 
 $path=<SH>;
 chop $path;
 close(SH); 

open(INF,"$path") || die "cannot open $path";
 while (<INF>){  
    if (!/^@/) { 
      ($ColA,$ColB,$ColC)=split;
      $Foundries{$ColA} =$ColB; 
       }
    }
close(INF);
open(SH,"kpsewhich typeface.map |") 
    || die "cannot run kpsewhich to get supplier.map"; 
 $path=<SH>;
 chop $path;
 close(SH); 
open(INF,"$path") || die "cannot open $path";
 while (<INF>){  
    if (!/^@/) { 
      ($ColA,$ColB,$ColC,$ColD)=split;
      $Typefaces{$ColA} =$ColC; 
      $Shortnames{$ColA} =$ColB; 
       }
    }
close(INF);
}

#-----------------------------------------------------------------
sub readAFMfile {
     my ($AFMfile) = @_;
     my $FontName;
     open(AFM,$AFMfile);
     while (<AFM>) {
        if (/^FontName /) 
            { ($FontName) = /^FontName ([A-z0-9\-]*)/ ; return $FontName; }
      }
     close(AFM);
     return "";
}
#-----------------------------------------------------------------
sub installDvips {
$TeXBaseEncoding=`kpsewhich -format='dvips config' 8r.enc`; 
chop $TeXBaseEncoding;
open(MAP,">>$Outdir/dvips/$Famcode$opt_extra$famextra.map");
# 8r names
print "** Making map entries for 8r *.pl files\n";
for (grep(/.{3,}8r.*\.pl/,@filenames)) { 
   s/\.pl//;
   $Basefile=$_;
   s/8r([a-z]?)$/8a$1/;
   $AFMfile=`kpsewhich $_.afm`;
   if ($AFMfile eq "")
   {
      $_=$Basefile;
      s/8r[a-z]?$/8a/;
      $Rawfile=$_;
      $AFMfile=`kpsewhich $_.afm`;
   }
   else
   {
      $Rawfile=$_;
   }
   chop $AFMfile ;
   if ($AFMfile ne "")
   {
    $FontName=&readAFMfile($AFMfile);
    $FullNames{$Basefile}=$FontName;
    print MAP "$Basefile $FontName \"TeXBase1Encoding ReEncodeFont \" <8r.enc ";
    if ($opt_download) { print MAP "<$Rawfile.pfb"; }
    print MAP "\n";
    &make_tfm($Basefile,$AFMfile,"-e$TeXBaseEncoding");
    }
}
# 8x names
print "** Making map entries for 8x *.pl files\n" if $opt_verbose;
for (grep(/.*8x.*\.pl/,@filenames)) { 
   s/\.pl//;
   $Basefile=$_;
   $AFMfile=`kpsewhich $_.afm`;
   chop $AFMfile ;
   if ($AFMfile ne "")
   {
    $FontName=&readAFMfile($AFMfile);
    $FullNames{$Basefile}=$FontName;
    print MAP "$Basefile $FontName ";
    if ($opt_download) { print MAP "<$Basefile.pfb"; }
    print MAP "\n";
    &make_tfm($Basefile,$AFMfile,"");
    }
 }
print "** Making map entries for faked fonts\n" if $opt_verbose;
open LOG,"grep \"^Faking \" *.log| " 
    || die "cannot open grep for Faking";
while (<LOG>) {
 ($Style,$Fake,$Real)=/Faking (.*) font (.*) from (.*)/;
 $_=$Real;
# Up must match at least 3 chars, because of StoneSans ps8 family....
 ($Up,$Enc,$Suf) = /(.{3,})(8.)(.*)/;
# print "SHOW ME $Up, $Enc, $Suf from $Real\n";
 $Basefile="$Up$Enc$Suf";
 $Enc =~ s/8r/8a/;
 $Rawfile="$Up$Enc$Suf";
 $AFMfile=`kpsewhich $Rawfile.afm`;
 chop $AFMfile ;
 $csargs="";
 if ($AFMfile ne "")
   {
   $FontName=&readAFMfile($AFMfile);
   print MAP "$Fake $FontName \"";
   if ($Style eq "narrow") {    
               print MAP " $opt_narrow ExtendFont" ;
	       $csargs=" -E$opt_narrow "; 
	       }
   elsif ($Style eq "oblique")  {    
                print MAP " $opt_slant SlantFont" ; 
	        $csargs=" -S$opt_slant "; 
	       }
   if ($Enc ne "8x") { 
        print MAP " TeXBase1Encoding ReEncodeFont \" <8r.enc"; 
	$csargs .= "-e$TeXBaseEncoding ";
	}
   else { print MAP "\"";}
   if ($opt_download) { print MAP " <$Rawfile.pfb " ; }
   print MAP "\n";
   &make_tfm($Fake,$AFMfile,$csargs);
  }
}
close LOG;
close MAP;
open CONFIG,">>$Outdir/dvips/config.$Famcode$opt_extra";
print CONFIG  "p +$Famcode$opt_extra.map$famextra\n" ;
close CONFIG;
}

#-----------------------------------------------------------------

sub installMetrics {
print "** Making virtual fonts with vptovf\n" if $opt_verbose;
for (grep(/.*\.vpl/,@filenames)) { 
    s/.vpl//;
    my $Basename=$_;
    processVPL($Basename);
 }
 &buildfilelist;
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
print "** Installing VPL files in $Outdir/vpl\n" if $opt_verbose;
 for (grep(/.*\.vpl/,@filenames)) {
  print "Installing $_ \n" if $opt_verbose;
  if (! -r "$Outdir/vpl/$_") { runsystem("mv $_ $Outdir/vpl") ; }
 }
print "** Installing PL files in $Outdir/pl\n" if $opt_verbose;
 for (grep(/.*\.pl/,@filenames)) {
  print "Installing $_ \n" if $opt_verbose;
  if (! -r "$Outdir/pl/$_") { runsystem("mv $_ $Outdir/pl") ; }
}
}

#-----------------------------------------------------------------
sub make_tfm {
# Add CHECKSUM in the same way as AFM2TFM and PS2PK do
# This is originally by Piet Tutelaers <rcpt@urc.tue.nl>
   local($texname,$afmfile,$csargs) = @_;
   local $cs = 0;
   if (-r "$texname.tfm") { 
          chop($cs = `cs -o "$texname.tfm"`);
          return $cs; 
    }
   chop($cs = `cs -n -o $csargs $afmfile`);
   print "make tfm $texname, $afmfile, $csargs\n" if $opt_debug;
   die "[addchecksum] cs: exit code ", ($? >>8) & 255, "\n" if $cs == 0 && $?;

   die "[addchecksum] Wrong checksum for $texname\n" if "$cs" eq "";
   print "$texname.pl: cs -n -o $csargs $afmfile -> $cs\n" if $opt_verbose;
   die "[addchecksum] Can not open $texname.pl\n" unless open(PL, "<$texname.pl");
	 $csadded = 0;
   open(TMPPL, ">tmp.pl");
   print TMPPL "(COMMENT new CHECKSUM added)\n";
   while (<PL>) {
      if (/CHECKSUM/) {
         print TMPPL "(CHECKSUM O $cs)\n";
	 $csadded = 1;
	 next;
      }
      if ($csadded == 0 && /FONTDIMEN/) {
         print TMPPL "(CHECKSUM O $cs)\n";
	 $csadded = 1;
      }
      print TMPPL;
   }
   close(PL); close(TMPPL);
   unlink("$texname.pl");
   rename("tmp.pl", "$texname.pl");
   print "pltotf $texname.pl $texname.tfm\n" if $opt_debug;
   runsystem("pltotf $texname.pl $texname.tfm");
   die "[addchecksum] pltotf: exit code ", ($? >>8) & 255, "\n" if $?;
   return $cs;
}

#-----------------------------------------------------------------
sub processVPL { 
# This is originally by Piet Tutelaers <rcpt@urc.tue.nl>
   local($font) = @_;
   print "Processing $font.vpl\n" if $opt_verbose;
   open(VPL,"$font.vpl") 
    || die "cannot open VPL $font.vpl";
   open(TMPVPL, ">tmp.vpl");
   print TMPVPL "(COMMENT new FONTCHECKSUMs added)\n";
   while (<VPL>) {
      $vpl = $_;
      next if (/FONTCHECKSUM/);
      if (/FONTNAME/) {
         $offset = index($vpl, "FONTNAME");
         $offset = index($vpl, ")", $offset);
         die "[addchecksum] Expected a closing brace after FONTNAME in line:",
             "\n$vpl" if $offset == -1;
         ($fontname) =  ($vpl =~ /FONTNAME\s+(\w+)/);
         $cs = 0;
	 if (-r "$fontname.tfm")
           {
            chop($cs = `cs -o "$fontname.tfm"`);
	    print "Read $cs from $fontname.tfm\n" if $opt_verbose;
	    }
         elsif (-r "$fontname.pl") {
            $_=$fontname;
            s/8r[a-z]?$/8a/;
            $AFMfile=`kpsewhich $_.afm`;
            chop($AFMfile);
            if ($AFMfile eq "")
	       { die "No AFM file found for font $_\n"; }
            else
	    {
              $cs= &make_tfm($fontname,$AFMfile,"");
  	      print "Generated $cs from $fontname.pl\n" if $opt_verbose;
	      die "[addchecksum] $fontname: invalid checksum" unless $cs != 0;
	      }
             }
         else {
# see it exists on the system
	    $TFMfile=`kpsewhich $fontname.tfm`;
	    chop($TFMfile);
            if ($TFMfile ne "") {
              chop($cs = `cs -o "$TFMfile"`);
	      print "Read $cs from $TFMfile\n" if $opt_verbose;
             }
	    else
             { die "[addchecksum] No font for $fontname\n"; }
         }
         die "[addchecksum] cs: exit code ", ($? >>8) & 255, "\n" if $cs == 0 && $?;
         substr($vpl, $offset+1, 0) = " (FONTCHECKSUM O $cs) ";
      }
      print TMPVPL $vpl;
   }
   close(VPL); 
   close(TMPVPL);
   unlink("$font.vpl");
   rename("tmp.vpl", "$font.vpl");
   runsystem("vptovf $font.vpl $font.vf $font.tfm");
   die "[addchecksum] vptovf: exit code ", ($? >>8) & 255, "\n" if $?;
}

#-----------------------------------------------------------------

sub runTeX {
 open(TEX,">Fam_$$.tex") 
    || die ("Cannot open Fam_$$.tex");
 if ($opt_verbose)
   { print TEX "\\nonstopmode\n" ; } 
 else
   { print TEX "\\batchmode\n" ; } 
 print TEX "\\input fontinst.sty\n";
 print TEX "\\def\\SlantAmount{",$opt_slant * 1000,"}\n";
 if ($opt_narrow) { print TEX "\\fakenarrow{$opt_narrow}\n" ; }
 print TEX "\\latinfamily{$Famcode$opt_expert$famextra}{$ExtraFDcode}\n";
 print TEX "\\end\n";
 close TEX;
 runsystem("tex -ini -progname=fontinst ./Fam_$$");
}

#-----------------------------------------------------------------
sub installTeX {
local $encoding;
for (grep(/.*\.fd/,@filenames)) { 
if (! -r "$Outdir/tex/$_") { 
 if (/^ot1/) { $encoding = "ot1"; } else { $encoding="other";}
 open NEWFD,">$Outdir/tex/$_";
 open OLDFD,"$_";
 while (<OLDFD>) {
 if ($opt_lucida)
 {
s/DeclareFontShape/DeclareLucidaFontShape/;
s/^\\DeclareFontFam/\\\@ifundefined{DeclareLucidaFontShape}{\%\n\\def\\DeclareLucidaFontShape#1#2#3#4#5#6{\%\n\\DeclareFontShape{#1}{#2}{#3}{#4}{<->#5}{#6}}}{}\n\\DeclareFontFam/;
s/^   <-> //;
if (/sub /) { s/Lucida//; }
 }
 if (/endinput/ && $encoding eq "ot1" ) { 
    print NEWFD "\\DeclareFontShape{OT1}{$Famcode$opt_expert$famextra}{m}{ui}{<->ssub * $Famcode$opt_expert$famextra/m/it}{}\n"; 
    print NEWFD "\\DeclareFontShape{OT1}{$Famcode$opt_expert$famextra}{b}{ui}{<->ssub * $Famcode$opt_expert$famextra/b/it}{}\n"; 
    print NEWFD "\\endinput\n";
        }
    else { print NEWFD ; }
}
    close OLDFD;
    close NEWFD;
  }
}
# now we have to fix the silly OML and OMS files. bleeargh.
#
 if (!$opt_lucida) {
open(CAT,">$Outdir/tex/oms$Famcode$opt_expert$famextra.fd")  
    || die ("cannot open $Outdir/tex/oms$Famcode$opt_expert$famextra.fd");
print CAT <<EOFCAT;
\\ProvidesFile{oms$Famcode$opt_expert$famextra.fd}
\\DeclareFontFamily{OMS}{$Famcode$opt_expert$famextra}{\\skewchar\\font48}
\\DeclareFontShape{OMS}{$Famcode$opt_expert$famextra}{m}{n}
   {<-> ssub * cmsy/m/n}{}
\\DeclareFontShape{OMS}{$Famcode$opt_expert$famextra}{m}{it}
   {<-> ssub * cmsy/m/n}{}
\\DeclareFontShape{OMS}{$Famcode$opt_expert$famextra}{m}{sl}
   {<-> ssub * cmsy/m/n}{}
\\DeclareFontShape{OMS}{$Famcode$opt_expert$famextra}{m}{sc}
   {<-> ssub * cmsy/m/n}{}
\\DeclareFontShape{OMS}{$Famcode$opt_expert$famextra}{b}{n}
   {<-> ssub * cmsy/b/n}{}
\\DeclareFontShape{OMS}{$Famcode$opt_expert$famextra}{b}{it}
   {<-> ssub * cmsy/b/n}{}
\\DeclareFontShape{OMS}{$Famcode$opt_expert$famextra}{b}{sl}
   {<-> ssub * cmsy/b/n}{}
\\DeclareFontShape{OMS}{$Famcode$opt_expert$famextra}{b}{sc}
   {<-> ssub * cmsy/b/n}{}
\\endinput
EOFCAT
close CAT;
open (CAT,">$Outdir/tex/oml$Famcode$opt_expert$famextra.fd") 
    || die ("cannot open $Outdir/tex/oml$Famcode$opt_expert$famextra.fd");
print CAT <<EOFCAT;
\\ProvidesFile{oml$Famcode$opt_expert$famextra.fd}
\\DeclareFontFamily{OML}{$Famcode$opt_expert$famextra}{\\skewchar\\font127}
\\DeclareFontShape{OML}{$Famcode$opt_expert$famextra}{m}{n}
   {<-> ssub * cmm/m/it}{}
\\DeclareFontShape{OML}{$Famcode$opt_expert$famextra}{m}{it}
   {<-> ssub * cmm/m/it}{}
\\DeclareFontShape{OML}{$Famcode$opt_expert$famextra}{m}{sl}
   {<-> ssub * cmm/m/it}{}
\\DeclareFontShape{OML}{$Famcode$opt_expert$famextra}{m}{sc}
   {<-> ssub * cmm/m/it}{}
\\DeclareFontShape{OML}{$Famcode$opt_expert$famextra}{b}{n}
   {<-> ssub * cmm/b/it}{}
\\DeclareFontShape{OML}{$Famcode$opt_expert$famextra}{b}{it}
   {<-> ssub * cmm/b/it}{}
\\DeclareFontShape{OML}{$Famcode$opt_expert$famextra}{b}{sl}
   {<-> ssub * cmm/b/it}{}
\\DeclareFontShape{OML}{$Famcode$opt_expert$famextra}{b}{sc}
   {<-> ssub * cmm/b/it}{}
\\endinput
EOFCAT
}
&install_README;
if ($opt_nosty) { return 0; }
open(CAT,">$Outdir/tex/$opt_expert$ShortFamily.sty");
print CAT <<EOFCAT;
\\ProvidesPackage{$opt_expert$ShortFamily}[$year/$mon/$mday:
PSNFSS v.2 LaTeX package loading $Foundry $Family. S. Rahtz]
EOFCAT
print CAT "\\renewcommand{",$Type,"default}{$Famcode$opt_expert$famextra}\n";
print CAT "\\endinput\n";
close(CAT);
}

sub install_README {
open(README,">$Outdir/README");
print "Installing README in $Outdir\n"  if $opt_verbose;
print README <<EOFCAT;
This set of metric files for the $Foundry $Family font family was
created on $year/$mon/$mday by Sebastian Rahtz, his famtool package, 
using Alan Jeffrey's fontinst TeX macros, version 1.8.
It consists of :
 + tfm files for use by TeX in old TeX encoding
     and new Cork TeX encoding 
 + vf (virtual font) files for dvi drivers 
 + tfm files for the raw fonts (TeXBase1 encoded) to use with the vf files
 + .fd (font description) files for use with LaTeX
 + a file $Famcode$opt_extra$famextra.map which lists the raw font names and their
    full PostScript names. This can be added to eg the psfonts.map file
    of dvips to ensure that the driver recognizes the names as those
    of PostScript fonts
 + a dvips config file config.$Famcode$opt_extra$famextra which can be used to tell dvips
   about the new fonts if you do not want to change the default psfonts.map
   (usage: dvips -P$Famcode$opt_extra$famextra to tell dvips about the $Family fonts)
EOFCAT
#
if ($opt_nosty) { close (README); return 0; }
print README <<EOFCAT;
 + a simple LaTeX package $ShortFamily.sty to use the new font
   family as appropriate for its type (roman, sans or typewriter).

EOFCAT
close(README);
}
sub install_symbol_README {
open(README,">$Outdir/README");
print "Installing README in $Outdir\n"  if $opt_verbose;
print README <<EOFCAT;
This set of files for the $Foundry $Family font family was
created on $year/$mon/$mday by Sebastian Rahtz, his famtool package, 
using Tom Rokicki's afm2tfm. It consists of :
 + a tfm file for use by TeX 
 + .fd (font description) file for use with LaTeX
 + a file $Famcode.map which lists the font names and their
    full PostScript names. This can be added to eg the psfonts.map file
    of dvips to ensure that the driver recognizes the names as those
    of PostScript fonts
 + a dvips config file config.$Famcode which can be used to tell dvips 
   about the new fonts if you do not want to change the default 
   psfonts.map (usage: dvips -P$Famcode to tell dvips about the $Family fonts)
EOFCAT
close(README);
}
#-----------------------------------------------------------------

sub remove_duplicates {
# read a file and remove duplicates lines
   local($filename) = @_;
   print "Reading $filename to remove duplicate lines\n" if $opt_verbose;
   local %Lines;
   open (TMP,$filename) 
     || die "Cannot read $filename to remove duplicates";
   while (<TMP>) {
      $Lines{$_} = 1;
    }
   close(TMP);
   open (TMP,">$filename") 
       || die "Cannot write $filename to remove duplicates";
   foreach $l (sort keys %Lines) {
       print TMP $l;
    }
   close(TMP);
   
}
#
# remove all files corresponding to a pattern
#
sub killfiles {
    local($killpatt) = @_;
    for (grep(/$killpatt/,@filenames)) { 
        print "NOTE: removing $_\n" if ($opt_debug);
        unlink $_ ; 
    }
    &buildfilelist;
}

sub runsystem {
    local($job) = @_;
    $result=system($job);
    print "Result $result from $job\n";
}
sub IsWin32 {
    return $^O =~ 'MSWin32';
}

sub Cleanup {
if ($opt_debug) {   print "Working files are left in /tmp/Fam_$$\n";  }
else  { print "remove files from /tmp/Fam_$$\n";
        &buildfilelist;
	for (@filenames) { unlink $_; }         
	chdir($Inidir);
	rmdir("/tmp/Fam_$$") ;
	}
}
1;
