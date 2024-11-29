# Centipede on the Minstrel 4th and 4D

## Introduction

Centipede is an arcade game, launched by Atari in 1981. It was very popular and spawned a number of micro conversions including, in 1984, a decent port by Colin Dooley to the Jupiter Ace. Colin's port is very playable with a strong resemblence to the original (accepting there is no spider and everything is monochrome). It is also one of the few Jupiter Ace games that supports both the Boldfield Soundbox and the Boldfield joystick interface.

If you have read my [post about Valkyr](../valkyr-minstrel/README.md), you will know that by adding an RC2014 YM2149 sound card to the Minstrel 4th or 4D, you can get a Soundbox-like experience (except that the port addresses used for controlling the card are different).

The Ace version of Centipede runs okay on the Minstrel 4th and 4D though does not have the enhanced sound support. I have therefore updated Colin Dooley's original, so that you can play the game in all of it's original glory, Plus, if you have a joystick interface, you can get the full experience.

## Playing the game

To run Centipede on your Minstrel 4th/ 4D, simply load the game from the TAP or WAV file with `LOAD centipede` and type `go` to run.

A reminder about the keyboard controls is provided at the beginning of the game: to fire, you press 'A', to move you press 'J' and 'L' to move left and right, 'I' and 'M' for up and down.

Joystick controls, if you have a suitable interface, are also available. Press 'H' to switch to joystick controls, while playing the game. Press 'K' to switch back to keyboard controls.

## Sound Support

This Minstrel 4th port of Centipede produces sound on both the built-in speaker and, if plugged in, an RC2014 YM2419 sound card. By default, the program assumes an RC2014 YM2419 sound card Rev 5 with default addressing (that is, the Register port is D8h and the Data port is D0h) is connected. If you have a Rev 6 card or your card is configured to use different ports, you can update the program using the included word `PATCH` (see below for details).

Because of copy-protection, some of the usual Ace Forth commands (such as SAVE and REDEFINE) are not available once Centipede is loaded: these words have been overloaded in the Centipede dictionary to make it more difficult for the user to access the program code. To work around this, you need to use `EXECUTE` with the code-field address of the built-in words you need.

To patch program for your particular sound-card configuration and save a new version of Centipede, enter the commands below.

```
16 BASE C! ( SWITCH TO HEX FOR EASIER CODING )
<REG_PORT> CONSTANT REG
13FD EXECUTE REG ( REDEFINE )
<DATA_PORT> CONSTANT DAT
13FD EXECUTE DAT ( REDEFINE )
PATCH
1934 EXECUTE centipede ( SAVE )
```

You should substitute `<REG_PORT>` and `<DAT_PORT>` with the appropriate values for your sound card. You do not need to enter the comments (in brackets).

## Porting the Game to Minstrel 4th/ 4D

The porting approach for Centipede is reasonably straightforward. Controlling the Boldfield Soundbox involved interacting with two different ports which are connected to the AY-3-8910 sound chip: the Register port (address FDh) and the Data port (address FFh). Three operations are important to consider:

- Writing to the Register port to select the active register
- Reading from the Register port to read the value stored in the active register
- Writing to the Data port to set the value stored in the active register.

Interacting with the RC2014 YM2419 sound card is similar, though not identical, in that to read the value stored in the active register, you read from a different port. For Rev 5 boards, you read the value from the Data port and on the Rev 6 board you read the value from a third port.

Thankfully, games like Centipede often only write data to the sound chip, rather than reading it. So, I needed to find `OUT` instructions within the program code that address either FDh or FFh.

This is straightforward to do with the debugger in (a recent version of) the EightyOne emulator: you can set two breakpoints to be triggered whenever you write to one of those two ports. Having done that, you then need to play the game to find the relevant instructions, noting down the addresses of the relevant OUT instructions as they trigger breakpoints.

Unfortunately, creating sounds often involves sending multiple commands (i.e., writes) to the sound chip, so the breakpoint will be tripped repeatedly by the same addresses. Furthermore, there is a chance that some instructions will only be reached in unlikely game scenarios -- e.g., you achieve a high score or unlock a special bonus feature. Because of this, having found the first few instances of instructions, I then start to look for occurances of the same byte pattern elsewhere in the code.

For Centipede and using the breakpoints based on `OUT` instructions, I quickly found instructions that communicate with the Soundbox at addresses 3CF4h (`OUT A,(FDh)`) and 3CF8h (`OUT A,(FFh)`). The breakpoint was also tripped by the same instructions at 4A7Eh, 4A81h,  4A8Ah, and 4A8Fh, so I was reasonably confident I understood how the programmer interacted with the Soundbox.

Next, I searched (again using the EightyOne Debugger) for other candidate instructions, represented by the byte sequence D3h, FDh or D3h, FFh.  This identified a number of candidates, at address 4A77h and 4A7A, plus repeats of the previously identified instructions at 30F4h, 30F8h, 34F0h, 34F8h, 38F0h, and 38F8h (iniitally, I did not remember that user memory on the Ace in the interval 3C00h--3FFFh is mirrored to 3000h-33FFh, 3400h--37FFh, 3800h--3BFFh, an I was confused by t the multiple copies of apparently the same code).

I was fairly confident that the additional candidates were indeed interactions with the sound card though, noting it could be data that coincidentally has the same byte pattern, I deleted the original breakpoints (looking for `OUT`) and replaced them with breakpoints that stopped if code is executed at the candidate addresses. Then, I began playing the game again though, having set more targetted breakpoints, the action was not stopped by the previously identified instructions. Soon enough the emulator tripped over each candidate address, so I had my list of instructions to be changed: `3CF4h`, `3CF8h`, `4A77h`, `4A7Ah`, `4A7Eh`, `4A81h`, `4A8Ah`, and `4A8Fh` (noting, in each case, whether the instruction accessed the Register port or the Data port).

The final step was then to edit the port address for each of these instructions, replacing the original value (e.g., 'FDh' for Register port) with the corresponding value for the RC2014 sound card (e.g., 'D8' for a Rev 5 board with default port configuration). Note that the port address is the second byte of the two-byte `OUT A,(XX)` instruction, so I needed to change the value at `3CF5h`, `3CF9h`, and so on. I wrote a FORTH word `PATCH` to do this, using constants `REG` and `DAT` to allow someone to adjust the replacement addresses according to the particular settings of their card. This is the purpose of the `PATCH` word.

Having patched and re-saved the program, I was able to test on the Minstrel 4th and confirm by ear that things sounded correctly.

As a final check, I ran the patched version of the program in EightyOne and confirmed there was no sound from the Soundbox (indicating I had not missed any instructions).

Finally, it was time to play some Centipede!


## Adding Joystick Support

In an interview with the curator of the [Jupiter Ace website](https://www.jupiter-ace.co.uk/sw_centipede.html), Colin notes that the game can also be controlled by joystick. As the Minstrel 4D has a built-in joystick interface, I assumed this would work straight away and was surprised when it did not.

I then read Colin's comments more carefully and realised that he had implemented his own joystick interface using one of the I/O ports on the AY-3-8910 (in the Soundbox interface). I was a little surprised as I thought I had found all interactions with the sound card, when porting the game to work with the RC2014 YM2419 sound card, even though none of them looked to control the I/O ports on the sound chip. I started to delve further into the game code.

By running the game on the EightyOne emulator and pausing it mid-game, I was able to step through the return addresses on the stack and find the main game loop. It was located at address 3C80h and consisted of a sequence of eight calls to subroutines in a continuous loop:

```
3C80	call 41C8h
3C83	call 3EE0h
3C86	call 3F28h
3C89	call 3EE0h
3C8C	call 3F28h
3C8F	call 3EF0h
3C92 	call 44E8h
3C95	call 46FEh
3C98	jp 3C80h
```

Single-stepping the code, I quickly found the routine that checks for fire being pressed (the subroutine at address 3F28h). Surpringly, there was no evidence of an attempt to read from the joystick: the routine only checked for the 'A' key.

I also found the code that checked the direction keys (the subroutine at address 3EF0h). However, again, there was no evidence of joystick support.

I started to wonder if there were multiple versions of the program code and I was looking at a version without joystick support, so I set about adding joystick support by replacing the two input routines with a version that checked both keyboard and joystick.

The machine-code of the main game is stored in the Centipede dictionary in a word named `DATA`. The program code is not relocatable and the game entry point is expected to be at address 3C60h. This makes it difficult to modify the existing code, since changes to the dictionary are likely to move subsequent words in memory and stop the game from working. Therefore I elected to add new game-control routines (one for fire and one for directions) at the end of the dictionary and then find the appropriate place to call out to those routines from within the original game code.

I created a new word, named `GAMECTRL`, at the end of the dictionary, in which to hold the new code. (The easiest way to do this is to use `CREATE` and then `ALLOT` enough space to hold the machine code in the word's parameter field). In this case, the parameter field for `GAMECTRL` started at address 5580h, so that is where I would locate the new code.

I started with the routine that checked for the Fire button, as this seemed the easier of the two. The routine at 3F28h is relatively self-contained so I set about making a new version of it that would also check the fire button on the joystick. The routine first checks to see if there is already a bullet in flight. If so, there is nothing to do and control is returned the game loop. Otherwise, it checks if fire is pressed and, if so, jumps to a routine at 3F3Fh to implement the fire mechanism.

Originally, I planned to have joystick support enabled all the time and to check both keyboard controls and joystick controls. However, I discovered that if no joystick interface is connected, then reading the joystick port can produce a misleading result. For example, on EightyOne, reading the port will typically return 20h (or 00100000 in binary) and, unfortunately, bit 5 is linked to the fire button, so this means the game thinks fire on the joystick is being pressed constantly.

Given this, I needed to update the game so the user could turn on and turn off joystick support. An easy way to do this, which did not require significant changes to the original code, was to check for additional keys within the routine handling fire. Specifically, I extended the routine to check for 'H' and 'K', which I mapped to joystick-support on and joystick-support off, respectively. The 'J' key is more obvious than 'H' but this is already mapped to the move-left command.

With this change, the user can switch back and forth between keyboard control and joystick control, while playing the game, by pressing 'H' and 'K'.

I then moved on to look at the routine that checks the direction controls. That routine is more complicated than the routine that checks for fire, with various different functions. However, after a little studying I found a call out to a subroutine at address 3E60h, from address 3F03h, which is where the keyboard controls are checked. Again, I wrote a new version of this routine which checked the keyboard or the joystick port, according to which control was active.

To complete the port, I then had to change the call instructions at address 3C86h and at address 3F03h to use my new versions of the routines, save the new version of the game, and get testing.

I also considered changing the keyboard controls, as I found them slighty awkward to use and thought it might be easier to play with the typical 'Q', 'A', 'O', 'P', and 'M' controls. However, looking back at pictures of the original Centipede arcade machine, I remembered that it used a trackball for control (possibly was the first arcade game to use that control) and realised that Colin's control choice sort of mimicked that setup. Thus, I decided it was best to leave it as Colin had designed it. With all of the testing, I was also getting more used to the controls anyway.

If you want to change the controls, I have included the source code of the [new game-control routines](gamectrl.asm). With the information above, it should be possible for anyone to make further changes to the game controls.

## Other Observations

When I was working on the port, I noted that the first routine in the game loop (at address 41C8h) points to an empty subroutine (returning immediately). Perhaps, Colin planned to include support for the spider, present in the original game, in this routine.
