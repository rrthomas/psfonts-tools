#
# Make new .tfm files for a variety of
# Adobe and Monotype PostScript fonts, 
# and appropriate virtual font files, for T1, OT1 and TS1 encodings.
#
# Sebastian Rahtz January 1992, March 1992, May 1992, October 1992,
# December 1992, March 1993, May 1993, July 1993, January 1994,
#
# from February 1994, uses fontinst
#
# May 1994, June 1994, February 1995, March 1995, April 1995, August 1995,
#
# October 14th 1995 (Berthold Baskerville)
# October 15th 1995 (-narrow calls from David Hull)
# Adapted to generate checksums / Piet Tutelaers (Nov. 1995)
# checked again and updated / SPQR / Nov 22 1995
# added Adobe Centaur / SPQR / Nov 22 1995
# cleaned again, added $(ZAP), and misc target / SPQR / Dec 11 1995
# cleaned again, / SPQR / Jan 26 1996
#==================================================================
# reworked considerably / SPQR / Jan 22 1997
#   with rewrite of make-fam in Perl. removed some of the functionality
#   which Piet had carefully added
# reworked again / SPQR / May 11 1998, added some Softmaker fonts
#
# hacked UV / May 1998
#   added targets for Lucida and Monotype TrueType fonts in Solaris 2.6
#
# SPQR 1998/07/04: changed a few target names for consistency with fontname
#--------------------------
# I am using gnu names as default
MKDIR=gmkdir -p
SORT=gsort
RM=rm
CP=cp
MV=mv
OPTIONS=
OUTDIR=..
#OPTIONS="-debug "
SHELL=/bin/sh
# program names
MAKEFAM=perl make-fam.pl $(OPTIONS)
MAKEONE=perl make-one.pl $(OPTIONS)
AFM2TFM=afm2tfm
AFMTOTFM=perl afm-to-tfm.pl $(OPTIONS)
RM=rm
MV=mv
CP=cp

# location of output directories
STDOUT=$(OUTDIR)/stdcooked
URWOUT=$(OUTDIR)/stdcooked
ADOBEOUT=$(OUTDIR)/cooked
MONOOUT=$(OUTDIR)/cooked
BITOUT=$(OUTDIR)/cooked
BHOUT=$(OUTDIR)/cooked
IBMOUT=$(OUTDIR)/cooked
SUNOUT=$(OUTDIR)/cooked
ADOBEOUTX=$(OUTDIR)/xcooked
MONOOUTX=$(OUTDIR)/xcooked
BITOUTX=$(OUTDIR)/xcooked
BHOUTX=$(OUTDIR)/xcooked
URWOUTX=$(OUTDIR)/xcooked

STANDARD= \
	adobe-avantgar \
	adobe-bookman \
	adobe-courier \
	adobe-helvetic \
	adobe-ncntrsbk \
	adobe-palatino \
	adobe-times \
	adobe-zapfchan \
	adobe-mathptm 

SPECIAL= \
	adobe-symbol \
	adobe-zapfding 

USTANDARD= \
	urw-avantgar \
	urw-bookman \
	urw-courier \
	urw-helvetic \
	urw-ncntrsbk \
	urw-palatino \
	urw-times \
	urw-zapfchan \
	urw-misc \

USPECIAL= \
	urw-symbol \
	urw-zapfding 

LUCIDA=	\
	bh-lucidabright \
	bh-lucidamaths

SUNLUCIDA= \
	sun-lucidabright

SUNTRUETYPE=\
	sun-monotype-avantgar \
	sun-monotype-bembo \
	sun-monotype-bookman \
	sun-monotype-courier \
	sun-monotype-gillsans \
	sun-monotype-helvetic \
	sun-monotype-ncntrsbk \
	sun-monotype-palatino \
	sun-monotype-rockwell \
	sun-monotype-symbol \
	sun-monotype-times \
	sun-monotype-zapfchan 


ADOBEOTHER = \
	adobe-univers \
	adobe-garamond \
	adobe-agaramon \
	adobe-gillsans \
	adobe-baskervi \
	adobe-baskerbe \
	adobe-bbasker \
	adobe-centaur \
	adobe-optima \
	adobe-utopia \
	adobe-bembo \
	adobe-minion \
	adobe-sabon \
	adobe-janson \
	adobe-stone

MISC2 = \
	bit-charter

IBM = ibm-timesnew

MONOTYPE = \
	monotype-abadi \
	monotype-albertus \
	monotype-amasis \
	monotype-apollo \
	monotype-arial \
	monotype-ashleysc \
	monotype-avantgar \
	monotype-basker \
	monotype-bell \
	monotype-bembo \
	monotype-biffo \
	monotype-binnyos \
	monotype-blado \
	monotype-bodoni \
	monotype-bookman \
	monotype-braggado \
	monotype-calisto \
	monotype-calvert \
	monotype-centaur \
	monotype-clarendo \
	monotype-clarion \
	monotype-clearfac \
	monotype-centuros 

MONOTYPE2=  \
	monotype-cntursbk \
	monotype-cntursbp \
	monotype-compacta \
	monotype-coronet \
	monotype-courier \
	monotype-dorchesc \
	monotype-egyptext \
	monotype-ehrhardt \
	monotype-ellingtn \
	monotype-falstaff \
	monotype-figaro \
	monotype-forte \
	monotype-garamond \
	monotype-gill \
	monotype-gloucest \
	monotype-goudy \
	monotype-grotesq \
	monotype-headline \
	monotype-horleyos \
	monotype-imprint \
	monotype-inflex \
	monotype-ionic \
	monotype-italnos \
	monotype-janson \
	monotype-joanna \
	monotype-klang \
	monotype-mercursc \
	monotype-modern \
	monotype-monolisc \
	monotype-nberolin \
	monotype-nclarend \
	monotype-newsgth \
	monotype-nimrod \
	monotype-nsplanti \
	monotype-octavian \
	monotype-oldengli \
	monotype-oldstyle \
	monotype-onyx \
	monotype-palacesc \
	monotype-pepita \
	monotype-perpetua \
	monotype-photina \
	monotype-poliphil \
	monotype-sabon \
	monotype-scotchro \
	monotype-script \
	monotype-spectrum \
	monotype-swing \
	monotype-symbol \
	monotype-timesnew \
	monotype-twentyc \
	monotype-typewrit \
	monotype-vandijck \
	monotype-walbaum \
	monotype-zantiqua \
	monotype-zapfchan \
	monotype-zapfding \
	monotype-zeitgeic \
	monotype-zeitgeis 

#
# these cause fontinst to louse up; Monotype Times Cyrillic is
# handled in the separate cyr directory.
#
MONOFUNNY= \
	monotype-bernard \
	monotype-engraver \
	monotype-felix 	 \
	monotype-Mcastellar \
	monotype-clearface \
	monotype-courier \
	monotype-NeographikMT \
	monotype-gillsana \
	monotype-runic 


all: $(STANDARD) $(SPECIAL) $(USTANDARD) $(USPECIAL) $(ADOBEOTHER) \
	$(MONOTYPE) $(MONOTYPE2) $(LUCIDA) $(MISC1) $(IBM)

foo: $(MONOTYPE2)

tools: cs 

cs: checksums/cs.c 
	(cd checksums; make; $(MV) cs ../cs)

#-------------
# interesting targets
standard: $(STANDARD) special

ustandard: $(USTANDARD) uspecial

special: $(SPECIAL)

uspecial: $(USPECIAL)

lucida: $(LUCIDA)

other: $(ADOBEOTHER)

monotype: $(MONOTYPE)

monofunny: $(MONOFUNNY)

misc: $(MISC1) 

ibm: $(IBM)

sun: $(SUNTRUETYPE) $(SUNLUCIDA)

##################################################################
test:
	$(MAKEFAM) -outdir $(STDOUT) -sans -nosty phv 

adobe-avantgar:
	$(MAKEFAM) -outdir $(STDOUT) -sans -nosty pag 
	$(AFMTOTFM) pagk -outdir $(STDOUT)/adobe/avantgar
	$(AFMTOTFM) pagko -outdir $(STDOUT)/adobe/avantgar
	$(AFMTOTFM) pagd -outdir $(STDOUT)/adobe/avantgar
	$(AFMTOTFM) pagdo -outdir $(STDOUT)/adobe/avantgar
	$(AFMTOTFM) pagkc -outdir $(STDOUT)/adobe/avantgar
	$(AFMTOTFM) pagdc -outdir $(STDOUT)/adobe/avantgar

adobe-bookman:
	$(MAKEFAM) -outdir $(STDOUT) -nosty pbk 
	$(AFMTOTFM) pbkl -outdir $(STDOUT)/adobe/bookman
	$(AFMTOTFM) pbkli -outdir $(STDOUT)/adobe/bookman
	$(AFMTOTFM) pbkd -outdir $(STDOUT)/adobe/bookman
	$(AFMTOTFM) pbkdi -outdir $(STDOUT)/adobe/bookman
	$(AFMTOTFM) pbklo -outdir $(STDOUT)/adobe/bookman
	$(AFMTOTFM) pbkdo -outdir $(STDOUT)/adobe/bookman
	$(AFMTOTFM) pbklc -outdir $(STDOUT)/adobe/bookman
	$(AFMTOTFM) pbkdc -outdir $(STDOUT)/adobe/bookman

adobe-courier:
	$(MAKEFAM)  -outdir $(STDOUT) -tt pcr 
	$(AFMTOTFM) pcrr -outdir $(STDOUT)/adobe/courier
	$(AFMTOTFM) pcrro -outdir $(STDOUT)/adobe/courier
	$(AFMTOTFM) pcrb -outdir $(STDOUT)/adobe/courier
	$(AFMTOTFM) pcrbo -outdir $(STDOUT)/adobe/courier
	$(AFMTOTFM) pcrrc -outdir $(STDOUT)/adobe/courier
	$(AFMTOTFM) pcrbc -outdir $(STDOUT)/adobe/courier

adobe-helvetic:
	$(MAKEFAM) -outdir $(STDOUT) -sans -nosty phv 
	$(AFMTOTFM) phvr -outdir $(STDOUT)/adobe/helvetic
	$(AFMTOTFM) phvro -outdir $(STDOUT)/adobe/helvetic
	$(AFMTOTFM) phvrrn -outdir $(STDOUT)/adobe/helvetic
	$(AFMTOTFM) phvron -outdir $(STDOUT)/adobe/helvetic
	$(AFMTOTFM) phvb -outdir $(STDOUT)/adobe/helvetic
	$(AFMTOTFM) phvbo -outdir $(STDOUT)/adobe/helvetic
	$(AFMTOTFM) phvbrn -outdir $(STDOUT)/adobe/helvetic
	$(AFMTOTFM) phvbon -outdir $(STDOUT)/adobe/helvetic
	$(AFMTOTFM) phvrc -outdir $(STDOUT)/adobe/helvetic
	$(AFMTOTFM) phvbc -outdir $(STDOUT)/adobe/helvetic
	sed -e 's/ssub \* phv\/l\/it/ssub \* phv\/m\/sl/' \
	 $(STDOUT)/adobe/helvetic/tex/t1phv.fd > x
	sed -e 's/ssub \* phv\/l\/ui/ssub \* phv\/m\/n/' \
	 x > $(STDOUT)/adobe/helvetic/tex/t1phv.fd
	sed -e 's/ssub \* phv\/l\/it/ssub \* phv\/m\/sl/' \
	 $(STDOUT)/adobe/helvetic/tex/ot1phv.fd > x
	sed -e 's/ssub \* phv\/l\/ui/ssub \* phv\/m\/n/' \
	 x > $(STDOUT)/adobe/helvetic/tex/ot1phv.fd
	sed -e 's/ssub \* phv\/l\/it/ssub \* phv\/m\/sl/' \
	 $(STDOUT)/adobe/helvetic/tex/8rphv.fd > x
	sed -e 's/ssub \* phv\/l\/ui/ssub \* phv\/m\/n/' \
	 x > $(STDOUT)/adobe/helvetic/tex/8rphv.fd
	$(RM) x

adobe-ncntrsbk:
	$(MAKEFAM) -outdir $(STDOUT) -nosty pnc 
	$(AFMTOTFM) pncr -outdir $(STDOUT)/adobe/ncntrsbk
	$(AFMTOTFM) pncri -outdir $(STDOUT)/adobe/ncntrsbk
	$(AFMTOTFM) pncb -outdir $(STDOUT)/adobe/ncntrsbk
	$(AFMTOTFM) pncbi -outdir $(STDOUT)/adobe/ncntrsbk
	$(AFMTOTFM) pncro -outdir $(STDOUT)/adobe/ncntrsbk
	$(AFMTOTFM) pncbo -outdir $(STDOUT)/adobe/ncntrsbk
	$(AFMTOTFM) pncrc -outdir $(STDOUT)/adobe/ncntrsbk
	$(AFMTOTFM) pncbc -outdir $(STDOUT)/adobe/ncntrsbk

adobe-palatino:
	$(MAKEFAM) -outdir $(STDOUT) -nosty ppl 
	$(AFMTOTFM) pplr -outdir $(STDOUT)/adobe/palatino
	$(AFMTOTFM) pplri -outdir $(STDOUT)/adobe/palatino
	$(AFMTOTFM) pplb -outdir $(STDOUT)/adobe/palatino
	$(AFMTOTFM) pplbi -outdir $(STDOUT)/adobe/palatino
	$(AFMTOTFM) pplrre -outdir $(STDOUT)/adobe/palatino
	$(AFMTOTFM) pplrrn -outdir $(STDOUT)/adobe/palatino
	$(AFMTOTFM) pplro -outdir $(STDOUT)/adobe/palatino
	$(AFMTOTFM) pplbo -outdir $(STDOUT)/adobe/palatino
	$(AFMTOTFM) pplru -outdir $(STDOUT)/adobe/palatino
	$(AFMTOTFM) pplbu -outdir $(STDOUT)/adobe/palatino
	$(AFMTOTFM) pplrc -outdir $(STDOUT)/adobe/palatino
	$(AFMTOTFM) pplbc -outdir $(STDOUT)/adobe/palatino

adobe-mathptm: 
	perl makemptm.pl $(OPTIONS) -outdir $(STDOUT)

adobe-times:
	$(MAKEFAM) -outdir $(STDOUT) -nosty ptm 
	$(AFMTOTFM) ptmr -outdir $(STDOUT)/adobe/times 
	$(AFMTOTFM) ptmri -outdir $(STDOUT)/adobe/times
	$(AFMTOTFM) ptmb -outdir $(STDOUT)/adobe/times
	$(AFMTOTFM) ptmbi -outdir $(STDOUT)/adobe/times
	$(AFMTOTFM) ptmrre -outdir $(STDOUT)/adobe/times
	$(AFMTOTFM) ptmrrn -outdir $(STDOUT)/adobe/times
	$(AFMTOTFM) ptmro -outdir $(STDOUT)/adobe/times
	$(AFMTOTFM) ptmbo -outdir $(STDOUT)/adobe/times
	$(AFMTOTFM) ptmrc -outdir $(STDOUT)/adobe/times
	$(AFMTOTFM) ptmbc -outdir $(STDOUT)/adobe/times
	${AFM2TFM} psyr.afm -s .167 psyro >> $(STDOUT)/adobe/times/dvips/ptm.map
	${AFM2TFM} psyr.afm >> $(STDOUT)/adobe/times/dvips/ptm.map
	$(CP) psyro.tfm $(STDOUT)/adobe/times/tfm
	$(CP) psyr.tfm  $(STDOUT)/adobe/times/tfm
	$(RM) psyr.tfm psyro.tfm

adobe-symbol: psyr.afm
	$(MAKEONE) -outdir $(STDOUT) psyr 

adobe-zapfchan:
	$(MAKEFAM)  -outdir $(STDOUT) -nosty pzc 
	$(AFMTOTFM) pzcmi -outdir $(STDOUT)/adobe/zapfchan

adobe-zapfding:
	$(MAKEONE) -outdir $(STDOUT) pzdr 

adobe-agaramon:
	$(MAKEFAM)  -outdir $(ADOBEOUT) -download -nosty pad 
	$(MAKEFAM)  -outdir $(ADOBEOUTX) -download -expert x pad 

adobe-garamond:
	$(MAKEFAM)  -outdir $(ADOBEOUT) -download -nosty pgm 

adobe-sabon:
	$(MAKEFAM)  -outdir $(ADOBEOUT) -download psb

adobe-stone:
	$(MAKEFAM)  -outdir $(ADOBEOUT) -download pst 

adobe-stonesans:
	$(MAKEFAM)  -outdir $(ADOBEOUT) -download ps8 

adobe-stoneinf:
	$(MAKEFAM)  -outdir $(ADOBEOUT) -download psi 

adobe-minion:
	$(MAKEFAM)  -outdir $(ADOBEOUT) -download pmn 

adobe-baskerbe:
	$(MAKEFAM)  -outdir $(ADOBEOUT) -download peb 

adobe-utopia:
	$(MAKEFAM)  -outdir $(ADOBEOUT) -download -nosty put 

adobe-bembo:
	$(MAKEFAM)  -outdir $(ADOBEOUT) -download -nosty pbb 
	$(MAKEFAM)  -outdir $(ADOBEOUTX) -download -expert x pbb 

adobe-gillsans:
	$(MAKEFAM)  -outdir $(ADOBEOUT) -sans -download pgs 

adobe-bbasker:
	$(MAKEFAM)  -outdir $(ADOBEOUT) -download pbv 

adobe-centaur:
	$(MAKEFAM)  -outdir $(ADOBEOUT) -download pur 
	$(MAKEFAM)  -outdir $(ADOBEOUTX) -download -expert x pur 

adobe-baskervi:
	$(MAKEFAM)  -outdir $(ADOBEOUT) -download -nosty pnb 

adobe-optima:
	$(MAKEFAM)  -outdir $(ADOBEOUT) -sans -download pop 

adobe-janson:
	$(MAKEFAM)  -outdir $(ADOBEOUT) -download pjn 

adobe-plantin:
	$(MAKEFAM)  -outdir $(ADOBEOUT) -download mpi 
	$(MAKEFAM)  -outdir $(ADOBEOUTX) -download -expert x mpi 

adobe-univers:
	$(MAKEFAM)  -outdir $(ADOBEOUT) -sans -download pun 


sun-lucidabright:
	$(MAKEFAM)  -outdir $(SUNOUT) -download -lucida slh 
	$(MAKEFAM)  -outdir $(SUNOUT) -download -lucida -sans sls 
	$(MAKEFAM)  -outdir $(SUNOUT) -download -lucida -tt slst
 

bh-lucidabright:
	$(MAKEFAM)  -outdir $(BHOUT) -download -lucida hlh 
	$(MAKEFAM)  -outdir $(BHOUT) -download -lucida -sans hls 
	$(MAKEFAM)  -outdir $(BHOUT) -download -lucida -tt -narrow 850 hlct
	$(MAKEFAM)  -outdir $(BHOUT) -download -lucida -tt -narrow 850  hlst
	$(MAKEFAM)  -outdir $(BHOUT) -download -lucida hlx 
	$(MAKEFAM)  -outdir $(BHOUT) -download -lucida hlcf 
	$(MAKEFAM)  -outdir $(BHOUT) -download -lucida hlcn 
	$(MAKEFAM)  -outdir $(BHOUT) -download -lucida hlcw 
	$(MAKEFAM)  -outdir $(BHOUT) -download -lucida hlce 


bh-lucidamaths:	
	$(MKDIR) $(BHOUT)/bh/lumath/tfm
	$(MKDIR) $(BHOUT)/bh/lumath/dvips
	$(CP)  lucmath/*.tfm $(BHOUT)/bh/lumath/tfm
	echo 'hlcdim LucidaNewMath-DemiItalic <hlcdim.pfb' >> $(BHOUT)/bh/lumath/dvips/hlcm.map
	echo 'hlcdima LucidaNewMath-AltDemiItalic <hlcdima.pfb' >> $(BHOUT)/bh/lumath/dvips/hlcm.map
	echo 'hlcrim LucidaNewMath-Italic <hlcrim.pfb' >> $(BHOUT)/bh/lumath/dvips/hlcm.map
	echo 'hlcrima LucidaNewMath-AltItalic <hlcrima.pfb' >> $(BHOUT)/bh/lumath/dvips/hlcm.map
	echo 'hlcdy LucidaNewMath-Symbol-Demi <hlcdy.pfb' >> $(BHOUT)/bh/lumath/dvips/hlcm.map
	echo 'hlcra LucidaNewMath-Arrows <hlcra.pfb' >> $(BHOUT)/bh/lumath/dvips/hlcm.map
	echo 'hlcda LucidaNewMath-Arrows-Demi <hlcda.pfb' >> $(BHOUT)/bh/lumath/dvips/hlcm.map
	echo 'hlcrv LucidaNewMath-Extension <hlcrv.pfb' >> $(BHOUT)/bh/lumath/dvips/hlcm.map
	echo 'hlcry LucidaNewMath-Symbol <hlcry.pfb' >> $(BHOUT)/bh/lumath/dvips/hlcm.map
	echo 'hlcdm LucidaNewMath-Demibold <hlcdm.pfb' >> $(BHOUT)/bh/lumath/dvips/hlcm.map
	echo 'hlc$(RM) LucidaNewMath-Roman <hlcrm.pfb' >> $(BHOUT)/bh/lumath/dvips/hlcm.map


ibm-timesnew:
	$(MAKEFAM)  -outdir $(IBMOUT) -download -nosty nnt 

monotype-amasis:
	$(MAKEFAM)  -outdir $(MONOOUT) -download ma2 

monotype-arial:
	$(MAKEFAM)  -outdir $(MONOOUT) -download -sans ma1 

monotype-ashleysc:
	$(MAKEFAM)  -outdir $(MONOOUT) -download mah 

monotype-basker:
	$(MAKEFAM)  -outdir $(MONOOUT) -download mbv 
	$(MAKEFAM)  -outdir $(MONOOUTX) -download -expert x mbv 

monotype-bembo:
	$(MAKEFAM)  -outdir $(MONOOUT) -download mbb 
	$(MAKEFAM)  -outdir $(MONOOUTX) -download -expert x mbb 

monotype-bernard:
	$(MAKEFAM)  -outdir $(MONOOUT) -download mbn 

monotype-biffo:
	$(MAKEFAM)  -outdir $(MONOOUT) -download mbf 

monotype-binnyos:
	$(MAKEFAM)  -outdir $(MONOOUT) -download mb2 

monotype-bodoni:
	$(MAKEFAM)  -outdir $(MONOOUT) -download mbd 

monotype-calisto:
	$(MAKEFAM)  -outdir $(MONOOUT) -download mc1 

monotype-calvert:
	$(MAKEFAM)  -outdir $(MONOOUT) -download mc8 

monotype-centaur:
	$(MAKEFAM)  -outdir $(MONOOUT) -download mur 
	$(MAKEFAM)  -outdir $(MONOOUTX) -download -expert x mur 

monotype-clearface:
	$(MAKEFAM)  -outdir $(MONOOUT) -download mcf 

monotype-clearfac:
	$(MAKEFAM)  -outdir $(MONOOUT) -download mcf 

monotype-compacta:
	$(MAKEFAM)  -outdir $(MONOOUT) -download mc7 

monotype-coronet:
	$(MAKEFAM)  -outdir $(MONOOUT) -download mot 

monotype-courier:
	$(MAKEFAM)  -outdir $(MONOOUT) -download -tt mcr 

monotype-dorchesc:
	$(MAKEFAM)  -outdir $(MONOOUT) -download mds 

monotype-ehrhardt:
	$(MAKEFAM)  -outdir $(MONOOUT) -download met 
	$(MAKEFAM)  -outdir $(MONOOUTX) -download -expert x met 

monotype-engraver:
	$(MAKEFAM)  -outdir $(MONOOUT) -download men 

monotype-felix:
	$(MAKEFAM)  -outdir $(MONOOUT) -download mfx 

monotype-garamond:
	$(MAKEFAM)  -outdir $(MONOOUT) -download mgm 
	$(MAKEFAM)  -outdir $(MONOOUTX) -download -expert x mgm 

monotype-gill:
	$(MAKEFAM)  -outdir $(MONOOUT) -download -sans mgs 

monotype-gillsana:
	$(MAKEFAM)  -outdir $(MONOOUT) -download -sans mga 

monotype-goudy:
	$(MAKEFAM)  -outdir $(MONOOUT) -download mgo 
	$(MAKEFAM)  -outdir $(MONOOUT) -download mgy 
	$(MAKEFAM)  -outdir $(MONOOUT) -download mg4 
	$(MAKEFAM)  -outdir $(MONOOUT) -download mg5 
	$(MAKEFAM)  -outdir $(MONOOUT) -download mgt 

monotype-joanna:
	$(MAKEFAM)  -outdir $(MONOOUT) -download mjo 

monotype-abadi:
	$(MAKEFAM)  -outdir $(MONOOUT) -download mai 

monotype-albertus:
	$(MAKEFAM)  -outdir $(MONOOUT) -download mal 

monotype-apollo:
	$(MAKEFAM)  -outdir $(MONOOUT) -download map 

monotype-avantgar:
	$(MAKEFAM)  -outdir $(MONOOUT) -download mag 

monotype-bell:
	$(MAKEFAM)  -outdir $(MONOOUT) -download mbe 

monotype-blado:
	$(MAKEFAM)  -outdir $(MONOOUT) -download mb1 

monotype-bookman:
	$(MAKEFAM)  -outdir $(MONOOUT) -download mbk 

monotype-braggado:
	$(MAKEFAM)  -outdir $(MONOOUT) -download mb3 

monotype-castella:
	$(MAKEFAM)  -outdir $(MONOOUT) -download mtl 

monotype-centuros:
	$(MAKEFAM)  -outdir $(MONOOUT) -download mcu 

monotype-cntursbp:
	$(MAKEFAM)  -outdir $(MONOOUT) -download mcs 

monotype-cntursbk:
	$(MAKEFAM)  -outdir $(MONOOUT) -download mnc 

monotype-clarion:
	$(MAKEFAM)  -outdir $(MONOOUT) -download mc6 

monotype-egyptext:
	$(MAKEFAM)  -outdir $(MONOOUT) -download mee 

monotype-ellingtn:
	$(MAKEFAM)  -outdir $(MONOOUT) -download mel 

monotype-falstaff:
	$(MAKEFAM)  -outdir $(MONOOUT) -download mfs 

monotype-figaro:
	$(MAKEFAM)  -outdir $(MONOOUT) -download mfi 

monotype-forte:
	$(MAKEFAM)  -outdir $(MONOOUT) -download mfe 

monotype-gloucest:
	$(MAKEFAM)  -outdir $(MONOOUT) -download mgr 

monotype-grotesq:
	$(MAKEFAM)  -outdir $(MONOOUT) -download mgq 

monotype-headline:
	$(MAKEFAM)  -outdir $(MONOOUT) -download mhd 

monotype-horleyos:
	$(MAKEFAM)  -outdir $(MONOOUT) -download mho 

monotype-imprint:
	$(MAKEFAM)  -outdir $(MONOOUT) -download mii 

monotype-inflex:
	$(MAKEFAM)  -outdir $(MONOOUT) -download mif 

monotype-ionic:
	$(MAKEFAM)  -outdir $(MONOOUT) -download mio 

monotype-italnos:
	$(MAKEFAM)  -outdir $(MONOOUT) -download mis 

monotype-janson:
	$(MAKEFAM)  -outdir $(MONOOUT) -download mjn 

monotype-klang:
	$(MAKEFAM)  -outdir $(MONOOUT) -download mkl 

monotype-modern:
	$(MAKEFAM)  -outdir $(MONOOUT) -download mmo 

monotype-nclarend:
	$(MAKEFAM)  -outdir $(MONOOUT) -download mnn 

monotype-oldengli:
	$(MAKEFAM)  -outdir $(MONOOUT) -download moe 

monotype-oldstyle:
	$(MAKEFAM)  -outdir $(MONOOUT) -download mos 

monotype-onyx:
	$(MAKEFAM)  -outdir $(MONOOUT) -download mox 

monotype-poliphil:
	$(MAKEFAM)  -outdir $(MONOOUT) -download mpz 

monotype-sabon:
	$(MAKEFAM)  -outdir $(MONOOUT) -download msb 

monotype-scotchro:
	$(MAKEFAM)  -outdir $(MONOOUT) -download ms1 

monotype-spectrum:
	$(MAKEFAM)  -outdir $(MONOOUT) -download msm 

monotype-symbol:
	$(MAKEONE)  -outdir $(MONOOUT) -download msyr 

monotype-twentyc:
	$(MAKEFAM)  -outdir $(MONOOUT) -download mtw 

monotype-vandijck:
	$(MAKEFAM)  -outdir $(MONOOUT) -download mvd 

monotype-walbaum:
	$(MAKEFAM)  -outdir $(MONOOUT) -download mwb 

monotype-zantiqua:
	$(MAKEFAM)  -outdir $(MONOOUT) -download mza 

monotype-zapfchan:
	$(MAKEFAM)  -outdir $(MONOOUT) -download mzc 

monotype-zapfding:
	$(MAKEONE)  -outdir $(MONOOUT) -download mzdr 

monotype-mercursc:
	$(MAKEFAM)  -outdir $(MONOOUT) -download mme 

monotype-monolisc:
	$(MAKEFAM)  -outdir $(MONOOUT) -download mm1 

monotype-clarendo:
	$(MAKEFAM)  -outdir $(MONOOUT) -download mcd 

monotype-neographik:
	$(MAKEFAM)  -outdir $(MONOOUT) -download mnk 

monotype-nberolin:
	$(MAKEFAM)  -outdir $(MONOOUT) -download mnr 

monotype-newsgth:
	$(MAKEFAM)  -outdir $(MONOOUT) -download mng 

monotype-nsplanti:
	$(MAKEFAM)  -outdir $(MONOOUT) -download mnp 

monotype-nimrod:
	$(MAKEFAM)  -outdir $(MONOOUT) -download mni 

monotype-octavian:
	$(MAKEFAM)  -outdir $(MONOOUT) -download mov 

monotype-palacesc:
	$(MAKEFAM)  -outdir $(MONOOUT) -download mp1 

monotype-pepita:
	$(MAKEFAM)  -outdir $(MONOOUT) -download mp2 

monotype-perpetua:
	$(MAKEFAM)  -outdir $(MONOOUT) -download mpp 
	$(MAKEFAM)  -outdir $(MONOOUTX) -download -expert x mpp 

monotype-photina:
	$(MAKEFAM)  -outdir $(MONOOUT) -download mph 

monotype-runic:
	$(MAKEFAM)  -outdir $(MONOOUT) -download mru 

monotype-script:
	$(MAKEFAM)  -outdir $(MONOOUT) -download ms2 

monotype-swing:
	$(MAKEFAM)  -outdir $(MONOOUT) -download msw 

monotype-timesnew:
	$(MAKEFAM)  -outdir $(MONOOUTX) -download -expert x mnt 
	$(MAKEFAM)  -outdir $(MONOOUT) -download mnt 
	$(MAKEFAM)  -outdir $(MONOOUT) -download mns 

monotype-typewrit:
	$(MAKEFAM)  -outdir $(MONOOUT) -download -tt mty 

monotype-zeitgeic:
	$(MAKEFAM)  -outdir $(MONOOUT) -download zmz 
	$(MAKEFAM)  -outdir $(MONOOUTX) -download -expert x zmz 

monotype-zeitgeis:
	$(MAKEFAM)  -outdir $(MONOOUT) -download mzt 
	$(MAKEFAM)  -outdir $(MONOOUTX) -download -expert x mzt 

sun-monotype-avantgar:
	$(MAKEFAM) -outdir $(MONOOUT) -nosty -sans mag

sun-monotype-bembo:
	$(MAKEFAM) -outdir $(MONOOUT) -nosty mbb

sun-monotype-bookman:
	$(MAKEFAM) -outdir $(MONOOUT) -nosty mbk

sun-monotype-courier:
	$(MAKEFAM) -outdir $(MONOOUT) -nosty -tt mcr

sun-monotype-gillsans:
	$(MAKEFAM) -outdir $(MONOOUT) -nosty -sans mgs

sun-monotype-hevetica:
	$(MAKEFAM) -outdir $(MONOOUT) -nosty -sans mhv 

sun-monotype-ncntrsbk:
	$(MAKEFAM) -outdir $(MONOOUT) -nosty mnc 

sun-monotype-palatino:
	$(MAKEFAM) -outdir $(MONOOUT) -nosty mpl 

sun-monotype-rockwell:
	$(MAKEFAM) -outdir $(MONOOUT) -nosty mrw

sun-monotype-times:
	$(MAKEFAM) -outdir $(MONOOUT) -nosty mtm 

sun-monotype-zapfchan:
	$(MAKEFAM) -outdir $(MONOOUT) -nosty mzc

sun-monotype-symbol:
	$(MAKEONE) -outdir $(MONOOUT) msyr 

urw-misc:
	$(MAKEFAM) -outdir $(URWOUT)  -download uaq 
	$(MAKEFAM) -outdir $(URWOUT)  -download ugq 
	$(MAKEFAM) -outdir $(URWOUT)  -download unm 
	$(MAKEFAM) -outdir $(URWOUT)  -download -sans unms 
	$(AFMTOTFM) unmr -outdir $(URWOUT)/urw/nimbus
	-$(RM) -f *.vpl
	-grep Extend map >> $(URWOUT)/urw/nimbus/dvips/unm.map
	-grep Slant map >> $(URWOUT)/urw/nimbus/dvips/unm.map
	$(SORT) $(URWOUT)/urw/nimbus/dvips/unm.map | uniq > map
	$(CP) map $(URWOUT)/urw/nimbus/dvips/unm.map 
	$(RM) map
	$(AFMTOTFM) unmrs -outdir $(URWOUT)/urw/nimbus
	-$(RM) -f *.vpl
	-grep Extend map >> $(URWOUT)/urw/nimbus/dvips/unms.map
	-grep Slant map >> $(URWOUT)/urw/nimbus/dvips/unms.map
	$(SORT) $(URWOUT)/urw/nimbus/dvips/unms.map | uniq > map
	$(CP) map $(URWOUT)/urw/nimbus/dvips/unms.map 
	$(RM) map
	$(AFMTOTFM) uaqrrc -outdir $(URWOUT)/urw/antiqua
	-$(RM) -f *.vpl
	-grep Extend map >> $(URWOUT)/urw/antiqua/dvips/uaq.map
	-grep Slant map >> $(URWOUT)/urw/antiqua/dvips/uaq.map
	$(SORT) $(URWOUT)/urw/antiqua/dvips/uaq.map | uniq > map
	$(CP) map $(URWOUT)/urw/antiqua/dvips/uaq.map 
	$(RM) map
	$(AFMTOTFM) ugqb -outdir $(URWOUT)/urw/grotesq
	-$(RM) -f *.vpl
	$(SORT) $(URWOUT)/urw/grotesq/dvips/ugq.map | uniq > map
	$(CP) map $(URWOUT)/urw/grotesq/dvips/ugq.map 
	$(RM) map

urw-avantgar:
	$(MAKEFAM) -download -outdir $(URWOUT) -nosty -sans uag 

urw-bookman:
	$(MAKEFAM) -download -outdir $(URWOUT) -nosty ubk 

urw-courier:
	$(MAKEFAM) -download -outdir $(URWOUT) -nosty -tt ucr 

urw-helvetic:
	$(MAKEFAM) -download -outdir $(URWOUT) -nosty -sans uhv 

urw-ncntrsbk:
	$(MAKEFAM) -download -outdir $(URWOUT) -nosty unc 

urw-palatino:
	$(MAKEFAM) -download -outdir $(URWOUT) -nosty upl 

urw-times:
	$(MAKEFAM) -download -outdir $(URWOUT) -nosty utm 

urw-zapfchan:
	$(MAKEFAM) -download -outdir $(URWOUT) -nosty uzc 

urw-symbol:
	$(MAKEONE) -download -outdir $(URWOUT) usyr 

urw-zapfding:
	$(MAKEONE) -download -outdir $(URWOUT) uzdr 


clean:
	$(RM) *.done
