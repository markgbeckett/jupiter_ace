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

PLAY is a machine-code utility to make it easier to create your own music on your Minstrel. It processes up to three strings (one per sound channel), which should contain instructions in the same format as for the ZX Spectrum `PLAY` command.

The current version of the code only supports a subset of the ZX Specttum PLAY features, as follows:

- Option to play notes from a ten-octave range of notes (including sharp and flat notes)
- Option to set volume independently on each channel
- Option to set the tempo for all three channels

The easiest way to start experimenting with the utility is using the simple PLAY word that is also provided. The syntax is very similar to that of the Spectrum version, though PLAY strings do not need to be enclosed in double quotes.

For example, to play the C major scale, simply enter the command

``PLAY cdefgabC``

Flats and sharps are indicated by prefixing the particular note by `$` or `#`, respectively. So, to play the C minor scale, enter

``PLAY cd$efg$a$bC``

When specifying notes, capitalisation is important. Lower-case notes are taken from the current octave, upper-case notes are taken from the octave above.

You can also play rest notes, by adding `&` to the the PLAY string. For example:

``PLAY cdefgabC&Cdagfedc``

To change the current octave, for a particular channel, use the sequence `O<octave-number>`. Again, capitalisation is important. The default octave if 5, that is `O5`. So, for example, to play a simple two-channel tune, try:

``PLAY O4cCcCgGgG O6CaCe$bd$bD``

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

``PLAY O5N3e#fgabg5b3#a#f5#a3af5aN3e#fgabgbENDbgb7D O5V10N3b#C#DE#F#D5#FN3G#D5G3#F#D5#FN3b#C#DE#F#D5#FN3G#D5G7#F O5T160V8N3Dbgb7DN5&E7&N5&E7&N3e#fgabgbE``

The default tempo for your music is 120 crochets per minute (see Timing for more information about this). You can change the timing with the sequence `T<crochets-per-minute>`. So for example, to double the speed of your tune, try something like:

``PLAY T240O4cCcCgGgG O6CaCe$bd$bD``

Note, as for the ZX Spectrum, you can only specify a new tempo in the first channel's PLAY string. If you instead, typed the following:

``PLAY O4cCcCgGgG T240O6CaCe$bd$bD``

--the tempo change would be ignored, and the tune would continue to play at 120 beats per minute.


