# Using the "YM2149 Sound Card for RC2014 Retro Computer" with the Minstrel 4th

## Introduction

The ["YM2149 Sound Card for RC2014 Retro Computer"](https://www.tindie.com/products/semachthemonkey/ym2149-sound-card-for-rc2014-retro-computer/)--a 3-channel sound add-on for retrocomputers, designed by Ed Brindley--can be plugged into the Minstrel 4th, via the RC2014 edge connector, to boost the audio capabilities of the computer.

![Minstrel 4th with YM2149 sound card](minstrel_4th_with_sound_card.jpg)

The card supports the General Instruments AY-3-8910, the Yamaha 2149, and (with an adaptor) the General Instruments AY-3-8912. However, from the point of sound generation, the three chips are indistinguishable. Below I refer to the AY-3-8910 chip, only because that is the sound chip I have. Either of the others will work equally well.

## Building the Card

Build the card following the instructions for the RC2014 computer, using the same jumper settings. The only jumper, on the sound card, that may need adjusting is the clock-divide setting (JP5). If you run your Minstrel 4th at 6.5 MHz, then you should select divide-by-4 option. Whereas, if you run your Minstrel 4th at 3.25 MHz, you should select divide-by-2.

You also need to configure the Z80 Clock jumper on the Minstrel 4th board to pass through the clock signal to the RC2014 bus. Do this by bridging pins 5 and 6 (labelled RC2014/1). This is in addition to bridging either pins 1 and 2 (for 3.25 MHz clock) or pins 3 and 4 (for 6.5 MHz clock).

![Minstrel 4th Clock Configuration](minstrel_4th_clock-config.png)

## Testing the Card

Ed Brindley has created a repository of useful information and tools for the sound card on [GitHub](https://github.com/electrified/rc2014-ym2149), including a simple BASIC test script. A Forth version of the script, suitable for the Minstrel 4th, is as follows:

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

You can also use S.V. Bulba's PT2/PT3 player, which is available from Ed Brindley's repository, to provide a more interesting test of the sound card. Assemble the source code, using the RC2014 configuration (set `RC=1` at the beginning of the source). However, you also need to disable interrupts by, for example, inserting the `DI` command immediately after the `ORG` directive. This is to work around the fact that the player makes extensive use of the IX register pair, which is also used by the Minstrel 4th's built-in monitor program.

## PLAY Utility

Once you have built and tested your card, you will want to start getting creative. To help you do this, I have created a PLAY utility, written in FORTH and machine code, to make it easier to make your own music on your Minstrel. It processes up to three strings (one per sound channel), which should contain instructions in the same format as for the ZX Spectrum `PLAY` command.

The FORTH word, PLAY, is a defining word. That is, it creates a new word encapsulating the note sequence you want to play, which is then invoked whenever you enter the defined word. For example,

```
PLAY SCALE cdefgabC ( DEFINE WORD TO PLAY SCALE )
SCALE ( PLAY THE SCALE )
``` 

The current version of the code only supports a subset of the ZX Specttum PLAY features, as follows:

- Play notes from a ten-octave range of notes (including sharp and flat notes)
- Set volume independently on each channel
- Set the tempo for all three channels
- Select whether each channel plays tones, white noise, or some combination of the two.
- Enable envelope volume effects.

### Loading

The PLAY utility can be loaded from tape/ WAV audio in two parts (a dictionary file and a block of machine code), using the following commands:

```
49152 15384 ! ( LOWER RAMTOP TO MAKE ROOM FOR MCODE )
LOAD PLAY ( LOAD DICTIONARY )
49152 0 BLOAD PLAYC ( LOAD MACHINE CODE )
```

All going well, you should see some additional words in your dictionary: most importantly, you should see a PLAY command.

The syntax for PLAY is very similar to that of the ZX Spectrum version (for example, see the [ZX Spectrum +3 User Guide, Chapter 8, Part 19](https://worldofspectrum.org/ZXSpectrum128+3Manual/chapter8pt19.html)), though the arguments to PLAY do not need to be enclosed in double quotes. As with many FORTH word that accept string arguments, the strings are placed after the word, not before.

As well as standard notes, PLAY also supports flats and sharps, which are indicated by prefixing the particular note by `$` or `#`, respectively. So, to play the C minor scale, enter

```
PLAY MSCALE cd$efg$a$bC
MSCALE
```

When you enter the above, you will see a new word in your dictionary, called MSCALE, which you can run as many times as you like. Sadly, as with all DEFINER words on the Minstrel 4th, you cannot list nor edit their definition. If you make a mistake, the best thing to do is redefine the word. E.g.,

```
PLAY MSCALE cd$efg$a$
MSCALE ( OOPS, SOME NOTES MISSING )
PLAY MSCALE cd$efg$a$bC
REDEFINE MSCALE
MSCALE ( THAT'S BETTER )
```

When specifying notes, capitalisation is important. Lower-case notes are taken from the current octave, upper-case notes are taken from the octave above. All commands (see below) must be typed in capitals.

You can also play rest notes, by adding `&` to the PLAY string. For example:

```
PLAY EX1 cdefgabC&Cdagfedc
EX1
```

To change the current octave, for a particular channel, use the sequence `O<octave-number>`. Again, capitalisation is important. The default octave if 5, that is `O5`, which covers the range of the treble clef (c, d, e, f, g, a, b, C, D, E, F, G, A, B). So, for example, to play a simple two-channel tune, try:

```
PLAY EX2 O4cCcCgGgG O6CaCe$bd$bD
EX2
```

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

N.B. Triplet notes (which, on the ZX Spectrum correspond to 10, 11, and 12, are not yet implemented).

There is also a dummy note `N`, which can be used to separate two numeric arguments. For example, if you want to play a minim-length high-C, you could type `O6N7c`. That is, change to Octave 6, set note length to minim, and play a C.

To change the volume on a channel, you use the sequence `V<volume>`, where the volume can be anything from 0 (silent) to 15 (maximum volume).

Bringing all of this together, you could play the first four bars of "The Hall of The Mountain King" with the following:

```
PLAY HOMK O5N3e#fgabg5b3#a#f5#a3af5aN3e#fgabgbENDbgb7D O5V10N3b#C#DE#F#D5#FN3G#D5G3#F#D5#FN3b#C#DE#F#D5#FN3G#D5G7#F O5T160V8N3Dbgb7DN5&E7&N5&E7&N3e#fgabgbE
HOMK
```

The default tempo for your music is 120 crochets per minute (see Timing for more information about this). You can change the timing with the sequence `T<crochets-per-minute>`. So for example, to double the speed of your tune, try something like:

```
PLAY FASTTUNE T240O4cCcCgGgG O6CaCe$bd$bD
FASTTUNE
```

Note, as for the ZX Spectrum, you can only specify a new tempo in the first channel's PLAY string. If you instead, typed the following:

```
PLAY NOTFAST O4cCcCgGgG T240O6CaCe$bd$bD
NOTFAST
```

--the tempo change would be ignored, and the tune would continue to play at 120 beats per minute.

The sound card is able to create variable-volume effects, as well as constant volume levels. A volume effect can be applied to none or any of the three sound channels, though only one volume effect can be active at a time. So, all channels that have volume effect enabled will have the same effect.

To enable the volume effect for a channel, add `U` to the channel string. The volume effect overrides any previously set volume levels (`V` commands).

There are two aspects of the volume effect to control. First, the type of effect is defined using `W<effect>`, where the wave pattern for each of the eight supported effects is shown below:

```
	   \
	0   \_________________     0 - single decay then off.
	
	    /|
	1  / |________________     1 - single attack then off.
	      ________________
	   \ |
	2   \|                     2 - single decay then hold.
	     _________________
	    /
	3  /                       3 - single attack then hold.
	
	   \ |\ |\ |\ |\ |\ |\
	4   \| \| \| \| \| \|      4 - repeated decay.
	
	    /| /| /| /| /| /|
	5  / |/ |/ |/ |/ |/ |/     5 - repeated attack.
	
	    /\  /\  /\  /\  /\
	6  /  \/  \/  \/  \/       6 - repeated attack-decay.
	
	   \  /\  /\  /\  /\
	7   \/  \/  \/  \/  \/     7 - repeated decay-attack.

```

Second, the duration/ period of the effect can be set with `X<period>`. Period values between 1 and 65,535 are possible (actually `X0` corresponds to a period length of 65,536). For repeating patterns (wave pattern 4, ...,7), values of 100--5,000 are typically good. For non-repeating patterns (wave pattern 0, ..., 3), values above 2,000 are generally best.

So, for example, a variation on our major C scale would be:
```
PLAY ENVELOPE W0X5000UcdefgabC
ENVELOPE
```

The sound card is capable of playing both musical notes (tones) and white noise. White noise is useful for sound effects or, used carefully, can add to musical pieces. You can control what combination of tone and white noise is played using the command `M<value>`, where value is calculated using the following table.

```
        .--------+-----------------+-----------------.
	|        |  Tone channels  | Noise channels  |
        |        |-----+-----+-----+-----+-----+-----|
	|        |  A  |  B  |  C  |  A  |  B  |  C  |
        |--------+-----+-----+-----+-----+-----+-----|
        | Number |  1  |  2  |  4  |  8  | 16  | 32  |
        `--------+-----+-----+-----+-----+-----+-----'
```
For each channel, and each effect you wish to enable, add the corresponding number to the command argument. For example, to enable tone on channels B and C, and white noise on channel A, specify the command `M14`.


### Timing

Timing is important in two places. First, the clock signal that is passed to the sound card determines the pitch of notes. The AY-3-8910 is designed to operate at around 2 MHz. With one of the Minstrel 4th configurations suggested above, the sound card will receive a clock signal of 1.625 MHz, which is close enough. I have worked out the pitch values, associated with notes based on that clock speed. If you have a different clock speed, or if you want to port the Play utility to a different computer, you will want to recompute the pitch values. To help do this, I have created a spreadsheet `tone_value_calculator.xlsx` into which you merely need to enter the clock signal you will pass to the sound card and then copy the source code from column K into an assembler source file. You then need to assemble the source again, to get a new version of the machine-code driver (see Building From Source).

The clock speed of the Minstrel 4th is also important. The PLAY Utility beat timing is calibrated to a Minstrel 4th running at 3.25 MHz. If, instead, you run your Minstrel 4th at 6.5 MHz, then you will find that your tunes play at double-tempo (though the pitch of notes will not be affected). The easiest way to correct this discrepancy is using the T command, halving the usual value. So, for example, to achieve a timing of 120 beats per minutes use the command `T60` rather than `T120`.

If you use S.V. Bulba's PT2/PT3 player, you do not have a chance to adjust either of these timing parameters (or, at least, I have not worked out how to adjust them), so you may find tunes do not play quite as they are intended. The sound card timing seems reasonable, so the pitch of notes should be okay. However, if you run at 3.25 MHz, the tempo will be slow: running the Minstrel 4th at 6.5 MHz give a better result.

### Building from Source

I have provided assembler source code and a Makefile to make it easy for you to modify and re-build the machine-code driver. If you are comfortable with Z80 machine code, and writing assembly language, this should be straightforward.

Some notes to get you started:

- I have used the [SJASMPLUS](https://github.com/z00m128/sjasmplus) assembler, though the source should work with most assemblers. The one point of portability problems may be the IFDEF / ENDIF directives, which could be removed, if you only want to support a single platform.
- By default, the code is assembled to address 0xC000 in memory and run from address 0xC006. Before executing the code, you need to populate the three channel information areas, the address of which are stored at 0xC000, 0xC002, and 0xC004, respectively. See the source-code comments for information on these structures.
- The driver should be reasonably portable to other Z80-based computers. The key areas of difference are likely to be: the address used to reference the sound-card ports, plus the exit and error-handling routines. As the source code supports either a Minstrel 4th or a ZX Spectrum you can easily find the sections of code that you will need to change by searching for IFDEF directives.
- The pitch values used for the supported octave range are read from a separate source file, which is included towards the end of `play.asm`. I have provided pitch files for a 1.625 MHz clock (e.g., default configuration of the Minstrel 4th) and a 1.77 MHz clock (e.g., as for the ZX Spectrum 128k). If you create additional pitch-value tables, update the `include` command accordingly.
- When developing the driver, I did lots of early testing using a ZX Spectrum+  128k machine. The reason was that I could test the code in an emulator (there is no emulator of a Jupiter Ace/ Minstrel 4th, with an RC2014 sound card). The ZX Spectrum has full PLAY support built in to the BASIC. However, if you want to use the driver, here, on a ZX Spectrum, just define the variable ZXSPECTRUM -- e.g., change the second line of the Makefile to `AFLAGS = --sym=play.sym --raw=play.bin -DZXSPECTRUM`.
