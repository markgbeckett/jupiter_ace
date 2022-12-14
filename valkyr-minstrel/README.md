# Valkyr for the Minstrel 4th

## Introduction

[Valkyr](http://www.jupiter-ace.co.uk/sw_Valkyr.html) is a space invaders-style arcade game written by Colin Dooley for the Jupiter Ace and released by Stusoft in 1985. There is a bit of uncertainty as to whether the game was actually published. In an interview with the postmaster of the Jupiter Ace Archive, Colin noted that he did not think it had been. However, a cassette with printed inlay has been recovered from an Ace owner, suggested some copies did make it out to the public.

The game has several unusual features. First, it is one of the few games that support the enhanced sound capabilities of an add-on for the Ace called the Boldfield Soundbox. Also, it is compatible with the Boldfield Joystick Interface.

It is also a rare example of a program that will not work, as is, on the Minstrel 4th. The program uses the Z80's Interrupt Mode 2 (IM2) and relies on the databus having the value 32 (or 20h) when an interrupt is generated. Sadly, this is not the case for the Minstrel 4th: normally, but not always, the Minstrel 4th will have 128 (or 80h) on the data bus.

Some emulators also put the wrong value on the data bus, so have problems running Valkyr. For example, versions of Eightyone up to and including Version 1.23 put the value 255 (0xFF) on the databus when an interrupt is generated, so will not be able to run Valkyr. In fact, the bug in Eightyone has been corrected and versions since 1.24 can run Valkyr.

However, in the interim, a patched version of the game was uploaded to the Jupiter Ace Archive that will work in Eightyone Version 1.23 and earlier. The patch changes the location of the vector table for IM2 and then pokes the address for the interrupt routine at location 0xFF in that table.

Buulding on that approach, I have further updated the patch so that it does work with the Minstrel 4th. To do this, I have moved the vector table into the top half of memory, at 8000h, and filled the table with the value 7F, so that the interrupt will call a routine at address 0x7F7F, whatever value is found on the databus. Then, at address 0x7F7F, I have insert a machine code sequence C3h, 90h, 3Ch, which represents `JP 3C90h` (3C90h is the real entry point for the interrupt routine).

The original game also relied on being able to use any even port address to drive the internal speaker; whereas, on the Minstrel 4th, I/O is fully decoded and so you have to use port FEh to control the internal speaker. I have corrected all code that drives the internal speaker to use port FEh so, even if you do not have an RC2014 sound card, you can enjoy the basic sound effects (which are pretty good).

Valkyr does not require memory above 7000h so, while seeming a little wasteful, the above patch keeps the patch code well clear of the game code.

## Playing the game

To run Valkyr on your Minstrel 4th, simply load the game from the TAP or WAV file with `LOAD valkyr` and type `valkyr` to run.

The word `EM` is a wrapper for the game routine, which first updates the interrupt vector table.

Full instructions are provided within the game. In summary, you use 'J' and 'L' to move left and right, respectively, and 'A' to fire. To launch your pulse bomb (when charged) press 'A' and 'S' simultaneously.

Joystick controls, if you have a suitable interface, are also available. You have to wiggle the joystick up and down to fire your pusle bomb.

## Sound Support

As noted above, Valkyr also supports the Boldfield Soundbox, which was a sound board built around an AY-3-8910 sound chip. A program communicates with the AY-3-8192 (to create sounds and music) via two ports -- the data port and the register port. On the Soundbox, the register port is accessed at address 253 (FDh) and the data port is accessed at address 255 (FFh). 

A similar sound device is available for the Minstrel 4th via the RC2014 bus -- the YM2149 Sound Card for RC2014. Unfortunately, the YM2149 Sound Card exposes the sound chip on different ports to those used on the Soundbox. By default, a Rev 5 YM2149 sound board exposes the register port via address D8h and the data port via address D0h.

I have patched Valkyr to work with the RC2014 sound card, by searching for instances of Z80 instructions, such as `IN A, FFh` and `OUT A, FDh`, checking that they were indeed communications with the Soundbox, and replacing them with the corresponding YM2149 port. So, for example, `OUT FDh, A` would be replaced by `OUT D8h, A`.

Slightly unexpectedly, Valkyr reads a register on the AY-3-8910 via the data port, whereas usually one would read the register port. Because of this. I also updated reads from the data port to be reads from the register port.

The game, as provided, will work with the YM2149 Sound Card for RC2014 Rev 5 with default port settings. Simply select 'Soundbox (EME/Boldfield)' from the options screen.

### Using Different Sound Card Port Settings

I have included a word `PATCH` that is used to update the port settings for the sound card. This in turn relies on a word PATCHK to search for and replace sound-card input and output in sections of memory. You can use `PATCH` to update the game to work with different port settings.

Before proceeding, it is best to switch to hexidecimal numbers, by using `DECIMAL 16 BASE C!`. In hexidecimal, as supplied, `PATCHK` looks like:

```
PATCHK
    D8D3 D8D3 4 PICK 4 PICK REPL ( OUT (reg_port), A )
    D0D3 D0D3 4 PICK 4 PICK REPL ( OUT (data_port), A )
    D8DB D8DB 4 ROLL 4 ROLL REPL ( IN (reg_port), A )
;
```

Unfortunately, `LIST PATCHK` prints signed integers, so D8D3 is printed as -272D, and so on. However, it is possible to enter unsigned integers when you edit it.

The second number on each line represents the original code to search for (with bytes reversed, as it is in Little-endian format) and the first number represents the replacement code.

To update PATCHK for your sound card, you need to replace the first number on each line with the correct code sequence for your sound card. For example, if your sound card had the register port listing on F8h and the data port on address F0h, you would replace the first number on each line with F8D3, F0D3, and F8DB, respectively.

Remember to 'REDEFINE PATCHK' once you have completed your edits and then run the command 'PATCH'. After a few seconds, patching will be completed, and you can type 'EM' to run the game and enjoy enhanced in-game sound. Once you have a working version of the game, you may want to save it to a new tape or TAP file.
