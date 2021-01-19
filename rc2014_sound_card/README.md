# Using the "YM2149 Sound Card for RC2014 Retro Computer" with Minstrel 4th

## Introduction

The ["YM2149 Sound Card for RC2014 Retro Computer"](https://www.tindie.com/products/semachthemonkey/ym2149-sound-card-for-rc2014-retro-computer/), a 3-channel sound add-on for retrocomputers, designed by Ed Brindley, can be plugged into the Minstrel 4th, via the RC2014 edge connector, to boost the audio capabilities of the computer.

![Minstrel 4th with YM2149 sound card](minstrel_4th_with_sound_card.jpg)

## Building the Card

Build the card following the instructions for the RC2014 computer, using the same jumper settings. The only jumper, on the sound card, that may need adjusting is the clock-divide setting (JP5). If you run your Minstrel 4th at 6.5 MHz then you should select divide-by-4 option. Whereas, if you run your Minstrel 4th at 3.25 MHz, you should select divide-by-2.

You also need to configure the Z80 Clock jumper on the Minstrel 4th board to pass through the clock signal to the RC2014 bus. Do this by bridging pins 5 and 6 (labelled RC2014/1). You also need to bridge either pins 1 and 2 (for 3.25 MHz clock) or pins 3 and 4 (for 6.5 MHz clock).

![Minstrel 4th Clock Configuration](minstrel_4th_clock-config.png)

## Testing the Card

Ed Brindley has created a repository of useful information and tools for the sound card on [GitHub](https://github.com/electrified/rc2014-ym2149), including a simple BASIC test script. A Forth version of this script, suitable for the Minstrel 4th, is as follows:

```
216 CONSTANT REG
208 CONSTANT DAT

DEFINER CODE DOES> CALL ;

CODE HALT 118 C, 253 C, 233 C,

: TEST
 7 REG OUT
 62 DAT OUT

 8 REG OUT
 15 DAT OUT

 0 REG OUT

 BEGIN
  255 1
  DO
   I DAT OUT HALT
  LOOP
  0
 UNTIL ( INFINITE LOOP, BREAK TO EXIT )
;
```

You can also use S.V.Bulba's PT2/PT3 player, which is available from Ed Brindley's repository, to provide a more interesting test of the sound card.

Assemble the source code, using the RC2014 configuration (set `RC=1` at the beginning of the source). However, you also need to disable interrupts, by inserting the `DI` command immediately after the `ORG` directive. This is to work around the fact that the player makes extensive use of the IX register pair, which is also used by Minstrel 4th's built-in monitor program.

## PLAY Utility

PLAY is a utility, written in FORTH and machine code, to make it easier to create your own music on your Minstrel. It processes up to three strings (one per sound channel), which should contain instructions in the same format as for the ZX Spectrum `PLAY` command.

The FORTH word, PLAY, is a defining word. That is, it creates a new word encapsulating the note sequence you want to play, which is then invoked whenever you enter the defined word. For example,

``PLAY SCALE cdefgabC ( DEFINE WORD TO PLAY SCALE )``
``SCALE ( PLAY THE SCALE )`` 

The current version of the code only supports a subset of the ZX Specttum PLAY features, as follows:

- Option to play notes from a ten-octave range of notes (including sharp and flat notes)
- Option to set volume independently on each channel
- Option to set the tempo for all three channels

### Loading

The program can be loaded from tape/ WAV audio, in two parts (a dictionary file and a block of machine code) using the following commands:

``49152 15384 ! ( LOWER RAMTOP TO MAKE ROOM FOR MCODE )``
`` LOAD PLAY ( LOAD DICTIONARY )``
`` 49152 0 BLOAD PLAYC ( LOAD MACHINE CODE )``

All going well, you should see some additional words in your dictionary: most importantly, you should see a PLAY command.

The syntax for PLAY is very similar to that of the Spectrum version, though the arguments to PLAY do not need to be enclosed in double quotes. As with many string arguments to a FORTH word, they are placed after the word, not before.

As well as standard nodes, PLAY also supports flats and sharps, which are indicated by prefixing the particular note by `$` or `#`, respectively. So, to play the C minor scale, enter

``PLAY MSCALE cd$efg$a$bC``
``MSCALE``

When you enter the above, you will see a new word in your dictionary, called MSCALE, which you can run as many times as you like. Sadly, as with all DEFINER words on the Minstrel 4th, you can't list nor edit their definition. If you make a mistake, the best thing to do is redefine the word. E.g.,

``PLAY MSCALE cd$efg$a$``
``MSCALE ( OOPS, SOME NOTES MISSING )``
``PLAY MSCALE cd$efg$a$bC``
``REDEFINE MSCALE``
``MSCALE ( THAT'S BETTER )``

When specifying notes, capitalisation is important. Lower-case notes are taken from the current octave, upper-case notes are taken from the octave above.

You can also play rest notes, by adding `&` to the the PLAY string. For example:

``PLAY EX1 cdefgabC&Cdagfedc``
``EX1``

To change the current octave, for a particular channel, use the sequence `O<octave-number>`. Again, capitalisation is important. The default octave if 5, that is `O5`. So, for example, to play a simple two-channel tune, try:

``PLAY EX2 O4cCcCgGgG O6CaCe$bd$bD``
``EX2``

By default, the note duration is set to a crochet. To change the current default note duration, for a channel, use a numeric code, as follows:

- 1 -- semi-quaver
- 2 -- dotted semi-quaver
- 3 -- quaver
- 4 -- dotted quaver
- 5 -- crochet
- 6 -- dotted crochet
- 7 -- minim
- 8 -- dotted minim
- 9 -- semi-breve

N.B. Triplet notes (which, on the Spectrum correspond to 10, 11, and 12, are not yet implemented).

There is also a dummy note `N`, which can be used to separate two numeric arguments. For example, if you want to play a minim-length high-C, you could type `O6N7c`. That is, change to Octave 6, set note length to minim, and play a C.

To change the volume on a channel, you use the sequence `V<volume>`, where the volume can be anything from 0 (silent) to 15 (maximum volume).

Bringing all of this together, you could play the first four bars of "The Hall of The Mountain King" with the following:

``PLAY HOMK O5N3e#fgabg5b3#a#f5#a3af5aN3e#fgabgbENDbgb7D O5V10N3b#C#DE#F#D5#FN3G#D5G3#F#D5#FN3b#C#DE#F#D5#FN3G#D5G7#F O5T160V8N3Dbgb7DN5&E7&N5&E7&N3e#fgabgbE``
``HOMK``

The default tempo for your music is 120 crochets per minute (see Timing for more information about this). You can change the timing with the sequence `T<crochets-per-minute>`. So for example, to double the speed of your tune, try something like:

``PLAY FASTTUNE T240O4cCcCgGgG O6CaCe$bd$bD``
``FASTTUNE``

Note, as for the ZX Spectrum, you can only specify a new tempo in the first channel's PLAY string. If you instead, typed the following:

``PLAY NOTFAST O4cCcCgGgG T240O6CaCe$bd$bD``
``NOTFAST``

--the tempo change would be ignored, and the tune would continue to play at 120 beats per minute.
