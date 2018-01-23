/*

KICKBLAST
by Micah Frank 2018
https://github.com/chronopolis5k
micah@puremagnetik.com		

*/
 
<CsoundSynthesizer>
<CsOptions>
-odac
</CsOptions>
<CsInstruments>

sr = 48000
ksmps = 128
nchnls = 1
0dbfs = 1.0

giGenerations = 50 ;define how many kicks to generate

seed 0 
;;function tables
gi1 ftgen 1,0,129,10,1 ;sine
gi2 ftgen 2,0,129,10,1,0,1,0,1,0,1,0,1 ;odd partials
gi3 ftgen 3, 0, 16384, 10, 1, 0 , .33, 0, .2 , 0, .14, 0 , .11, 0, .09 ;odd harmonics
gi4 ftgen 4, 0, 16384, 10, 0, .2, 0, .4, 0, .6, 0, .8, 0, 1, 0, .8, 0, .6, 0, .4, 0,.2 ; saw
gi5 ftgen 5,0,129,21,1 ;white noise
gi7 ftgen 7,0,129,9,.5,1,0 ;half sine
gi10 ftgen     0, 0, 2^10, 10, 1, 0, -1/9, 0, 1/25, 0, -1/49, 0, 1/81

schedule 1, 0, 10000 ;prime globals

instr settings, 1
gicounter init 0
reset:

;; QUICK PARAMETERS

;kick sustain values
gikicksustain random 0.5, 4 ;generates kick btwn 0.5 & 2 sec long. Try long values (~4 sec) for some interesting results
gikickfreq random 50, 300 ;kick freq
gikickres random 0, 0.5 ;kick resonance. Careful!
ginitpitch random 0.001, 5 ;pitch env init point (factor of gikickfreq 0.0 - 1.0)
giPDecayFactor random 0.1, 0.9 ;pitch decay (factor of gikicksustain 0.0 - 1.0)

;kick attack values
giatkdur random 0.005, 0.05 ; kick attack duration - default 0.015, 0.005
giatkfreq random 50, 400 ;kick attack freq - default 50, 400
giatklvl random 0.1, 0.5 ;attack portion level - default 0.1, 0.5
giFilterInit random 1000, 16000

gSatrb strcpy "kick-" ;file descriptor prefix (e.g. "long-", "kick-Jan12-" etc..)

prints "reset. new kick generating...\n"
;prints "kick length is %f seconds\n", gikicksustain


ktime init 0
ktime timeinsts 

if gicounter < giGenerations then
		if ktime > gikicksustain then ;reset when elapsed time is greater than steps
		schedule 98, 0, gikicksustain ;prime sequencer
		schedule 100, 0, gikicksustain ; prime recorder
		gicounter += 1
		reinit reset
		endif
	else 
		event "e", 0, 0
endif


endin

instr kick, 2

;kick sustain waveform array and selection
ikickSusArray[] fillarray gi1, gi7, gi10
ikickArrayselect1 random 0,2
iKickSelection1 = ikickSusArray[round(ikickArrayselect1)]

;kick attack waveform array and selection
ikickAtkArray[] fillarray gi2, gi3, gi4, gi5
ikickAtkSelect1 random 0,3
iKickAtkSelection1 = ikickAtkArray[round(ikickAtkSelect1)]

;;kick sustain
isuswave  =  iKickSelection1 ;choose waveform
kpenv expseg ginitpitch, giatkdur, 1, (gikicksustain-giatkdur)*giPDecayFactor, 0.01  ;modulate pitch.

kamp expseg 0.9, gikicksustain, 0.001

;;kick attack
iatkwave = iKickAtkSelection1 ; attack wave
katkenv expseg giatklvl, giatkdur, 0.01 ;attack envelope

asus oscili kamp, gikickfreq*kpenv, isuswave
aatk oscili katkenv, giatkfreq, iatkwave

kfiltenv expseg giFilterInit, gikicksustain*0.25, 20

afilteredsig moogvcf2 asus+aatk, kfiltenv, gikickres

a1 limit afilteredsig, -0.9, 0.9 ;limiter

out a1

endin


instr drumsSeq, 98
ktrig metro 1/gikicksustain

if ktrig = 1 then
		event "i", "kick", 0, gikicksustain	
endif	

endin

instr recorder, 100
;; random word generator
icount init 0
iwordLength random 2,4 ; how long will the random word be (when this number is doubled)
iwordLength = int(iwordLength)
StringAll =       "bcdfghjklmnpqrstvwxz"
StringVowels =     "aeiouy"
Stitle = ""
cycle:
if icount < iwordLength then 
	irandomLetter  random 1,20
	irandomVowel  random 1,6	
	Ssrc1 strsub StringAll, irandomLetter,irandomLetter+1
	Ssrc2 strsub StringVowels, irandomVowel,irandomVowel+1
	Ssrc1 strcat Ssrc1, Ssrc2 ; combine consonants and vowels
	Stitle strcat Stitle, Ssrc1 ;add to previous string iteration
                icount += 1
                goto cycle
endif

aout1 monitor

;;file writing
Sfilename strcat gSatrb, Stitle 
Sfilename strcat Sfilename, ".aif"
fout Sfilename, 24, aout1

endin


</CsInstruments>
<CsScore> 
e 2
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>100</x>
 <y>100</y>
 <width>320</width>
 <height>240</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="nobackground">
  <r>255</r>
  <g>255</g>
  <b>255</b>
 </bgcolor>
</bsbPanel>
<bsbPresets>
</bsbPresets>
