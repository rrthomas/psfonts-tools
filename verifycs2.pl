#!/usr/local/bin/perl

# File:    verifycs.pl
# Purpose: Perl script written to check consistency of psfonts on CTAN.
#	   This 2.1 version should be more robust than its predecessors.
#	   This program depends upon the UNIX tool `find' to locate TFM
#	   and AFM files.
# Author:  Piet Tutelaers (rcpt@urc.tue.nl)
# Version: 1.0 (December 1995), 2.0 (January 1997) by S Rahtz
#          2.1 (February 1997) Piet Tutelaers
#          2.2 (May 1998) Sebastian Rahtz

$ENCPATH = "tools//";

die "Usage: verifycs AFMpath mapfile fontdir\n" unless @ARGV == 3;

$afmpath = $ARGV[0];	# path with possible `//' recursion 
$mapfile = $ARGV[1];	# just a single filename
$fontdir = $ARGV[2];	# single directory containing TFM and VF fonts

# Read the $mapfile and find all required AFM files via $afmpath
&read_mapfile($mapfile);
&find_afmfilenames($afmpath);

# Complain about missing AFM files
foreach (sort (keys %afmfilename)) {
   if ($afmfilename{$_} eq "required") {
      print "$_: no AFM file\n";
   }
}

@tfms = split(/\s+/, `find $fontdir -name "*.tfm" -print`);

# Loop through TFM files in $fontdir
foreach (@tfms) {
   $tfmfile = $_;
   ($texname) = m#([^/]+)\.tfm$#;
   $vffile = &psearch("$fontdir//", "$texname.vf");
   if ($vffile ne "") { # Virtual font
      # Verify checksums
      chop($csvf  = `cs -o $vffile`);
      chop($cstfm = `cs -o $tfmfile`);
      if ("$csvf" ne "$cstfm") {
         print "$tfmfile: CS=$cstfm\n";
         print "$vffile: CS=$csvf\n";
         next;
      }
   
      # Now verify fonts referenced in VF file
      # We look for information of the form
      #	(MAPFONT D 0
      #	   (FONTNAME ptmr8r)
      #	   (FONTCHECKSUM O 24364160751)
      #	   (FONTAT R 1.0)
      #	   (FONTDSIZE R 10.0)
      #	   )
      open(VF, "vftovp $vffile $tfmfile |");
      while (<VF>) {
         last if (/LIGTABLE/);
         if (/MAPFONT/) {
            $fontname =""; $checksum = "";
            while (<VF>) {
               ($fontname) = /FONTNAME\s+(\w+)/ if /FONTNAME/;
               ($checksum) = /FONTCHECKSUM\s+O\s+(\w+)/ if /FONTCHECKSUM/;
               last if /^\s+\)/;
            }
            if ("$checksum" ne "") {
	       $tfmfile = &psearch("$fontdir//", "$fontname.tfm");
   	       if ($tfmfile eq "") {
                  print "$vffile: $fontname referenced no TFM file found\n";
   	          next;
   	       }
               chop($cstfm = `cs -o $tfmfile`);
   	       if ("$checksum" ne "$cstfm") {
                  print "$vffile: mapped to $fontname (CS=$csvf)\n";
                  print "$vffile: real $fontname.tfm (CS=$cstfm)\n";
   	          next;
   	       }
   	       next;
            }
            print "$vffile: mapped to $fontname (missing FONTCHECKSUM)\n";
	    last;
         }
      }
      close(VF);
   }
   else { # Raw font: font mapped to PostScript font
      if (!defined $mapping{$texname}) {
	 warn "$mapfile: no mapping info for $texname\n";
	 next;
      }
      ($psname, $cs_args) = split(/:/, $mapping{$texname});
      if ($afmfilename{$psname} eq "required") {
	 warn "$psname: no AFM file for $texname\n";
	 next;
      }
      print "cs $cs_args $afmfilename{$psname}\n" if $debug;
      $cs = 0;
      chop($cs = `cs $cs_args $afmfilename{$psname}`);
      die "cs: exit code ", ($? >>8) & 255, "\n" if $cs == 0 && $?;
   
      chop($cstfm = `cs -o $tfmfile`);
      if ("$cstfm" ne "$cs") {
         print "$tfmfile: CS=$cstfm\n";
         print "$tfmfile: cs $cs_args $psname.afm ==> $cs\n";
      }
  }
}

#
# Next function returns the name of the file in the path or empty string
# when not available.
#
sub psearch {
   local($path, $filename) = @_;
   local($file, $subdir, @subdirectories);
   local($firstdir, $lastdir);

   # Loop through $path directories to find $filename
   foreach (split(/:/, $path)) {
      if (! m,//,) {
         return "$_/$filename" if -r "$_/$filename";
      }
      elsif (m,//$,) { s,//$,,;
         return "$_/$filename" if -r "$_/$filename";
         opendir(DIR, $_);
         @subdirectories=readdir(DIR);
         closedir(DIR);
         foreach $subdir (@subdirectories) {
            next if ($subdir eq '.' || $subdir eq '..');
            next unless -d "$_/$subdir";
print "Looking for $filename in $_/$subdir//\n" if $debug;
            $file = &psearch("$_/$subdir//", $filename);
            return $file unless $file eq "";
         }
      }
      elsif (m,//,) {
         ($firstdir, $lastdir) = m,^(.*)//(.*)$,;
	 return &psearch("$firstdir/$lastdir", $filename)
	    if -d "$firstdir/$lastdir";
         opendir(DIR, $firstdir);
         @subdirectories=readdir(DIR);
         closedir(DIR);
         foreach $subdir (@subdirectories) {
            next if ($subdir eq '.' || $subdir eq '..');
            next unless -d "$firstdir/$subdir";
print "Looking for $filename in $firstdir/$subdir//$lastdir\n" if $debug;
            $file = &psearch("$firstdir/$subdir//$lastdir", $filename);
            return $file unless $file eq '';
         }
      }
   }
   return "";
}

#
# Find the absolute AFM-filenames for all PostScript fonts ($psname) 
# referenced in the MAPFILE. Store them in %afmfilename{$psname}.
#
sub find_afmfilenames {
   local($path) = @_;
   local($afmfile, $fontname, $psname, @afms);

   # Loop through $path directories to find all AFM files
   select(STDOUT); $| = 1; # flush STDOUT
   foreach (split(/:/, $path)) {
      if (m,//,) {
         s,//.*$,,;
      }
      if (! -d $_) {
	 warn "$_: no valid directory name\n";
	 next;
      }
      print "Reading AFM files in $_ ...";
      @afms = split(/\s+/, `find $_ -name "*.afm" -print`);
      foreach $afmfile (@afms) {
	 $fontname = `grep FontName $afmfile 2>/dev/null`;
	 if ($fontname eq "") {
	    warn "$afmfile: can't determine FontName\n";
	    next;
	 }
	 chop($fontname);
	 ($psname) = ($fontname =~ /FontName\s+(\S+)$/);

         next unless $afmfilename{$psname} eq "required";
	 $afmfilename{$psname} = $afmfile;
      }
      print " done\n";
   }
}

# Read mapfile to find out
#  (a) what TeXnames are used ($texname)
#  (b) what PostScript name is used ($psname)
#  (b) what CHECKSUM relevant mapping info is provided ($cs_args)
#  (c) put this info in %mapping:
#	$mapping{$texname} = '$psname:$cs_args'
#  (d) trace needed AFM files ($afmfilenames{$psname} = "required")
sub read_mapfile{
   local($mapfile) = @_;
   local($texname, $psname, $enc, $extend, $slant);
   local(%encoding);

   die "$mapfile: can't read\n" unless -r $mapfile;
   open(MAP, "<$mapfile") || die "$mapfile: can't open\n";
   while (<MAP>) {
      chop;
      next if /^[*%]/ || /^$/;
      ($texname, $psname) = /\s?(\S+)\s+(\S+)/;
      ($enc) = /^.*<(.*\.enc)/;
      ($extend) = /.*[^\d.]([0-9.]+)\s+ExtendFont/;
      ($slant) =  /.*[^\d.]([0-9.]+)\s+SlantFont/;
      if (defined $mapping{$texname}) {
	 warn "$mapfile: $texname already defined (this one skipped)\n";
	 next;
      }
      else {
         $cs_args = "-n -o ";
	 if (!defined $encoding{$enc}) {
            $encfile = &psearch($ENCPATH, $enc);
            if ($encfile eq "") {
	       warn "$enc: no such encoding file found\n";
	       next;
            }
	    $encoding{$enc} = $encfile;
	 }
	 else {
	    $encfile = $encoding{$enc};
	 }
         $cs_args .= "-e$encfile " if $enc;
         $cs_args .= "-E$extend "  if $extend;
         $cs_args .= "-S$slant "   if $slant;
	 $mapping{$texname} = "$psname:$cs_args";
	 $afmfilename{$psname} = "required";
      }
   }
   close(MAP);
}


