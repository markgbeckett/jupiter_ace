# Centipede on the Minstrel 4th and 4D

## Introduction

Centipede is an arcade game, launched by Atari in 1981. It was very popular and spawned a number of micro conversions including, in 1984, a decent port by Colin Dooley to the Jupiter Ace. Colin's port is very playable with a strong resemblence to the original (accepting there is no spider and everything is monochrome). It is also one of the few Jupiter Ace games that supports both the Boldfield Soundbox and the Boldfield joystick interface.

If you have read my [post about Valkyr](../valkyr-minstrel/README.md), you will know that by adding an RC2014 YM2149 sound card to the Minstrel 4th or 4D gives a Soundbox-like experience, except that the port addresses used for controlling the card are different.

The Ace version of Centipede runs okay on the Minstrel 4th and 4D though does not have the enhanced sound support. I have therefore updated Colin Dooley's original, so that you can play the game in all of it's original glory, Plus, if you have a joystick interface, you can get the full experience.

## Playing the game

To run Centipede on your Minstrel 4th/ 4D, simply load the game from the TAP or WAV file with `LOAD centipede` and type `centipede` to run.

A reminder about the keyboard controls is provided at the beginning of the game: to fire, you press 'A', to move you press 'J' and 'L' to move left and right, 'I' and 'M' for up and down.

Joystick controls, if you have a suitable interface, are also available. Press 'H' to switch to joystick controls. Press 'K' to switch back to keyboard controls.

## Sound Support

Centipede produces sound on both the built-in speaker and, if plugged in, an RC2014 YM2419 sound card. By default, the program assumes the RC2014 YM2419 sound card Rev 5 default addressing (that is, the Register port is D8h and the Data port is D0h). If you have a Rev 6 card or your card is configured to use different ports, you can update the program using the built-in `PATCH` word.

However, because of copy-protection, some of the usual Ace Forth commands (such as SAVE and REDEFINE) are not available. To work around this, you need to use EXECUTE with the code-field address of the built-in words.

In the code sample below, substitute `<REG_PORT>` and `<DAT_PORT>` with the appropriate values for your sound card.

```
16 BASE C! ( SWITCH TO HEX FOR EASIER CODING )
<REG_PORT> CONSTANT REG
13FD EXECUTE REG ( REDEFINE )
<DATA_PORT> CONSTANT DAT
13FD EXECUTE DAT ( REDEFINE )
PATCH
1934 EXECUTE centipede ( SAVE )
```

## Porting the Game to Minstrel 4th/ 4D

The porting approach for Centipede is reasonably straightforward. Controlling the Boldfield Soundbox involved interacting with two different ports which are connected to the AY-3-8910 sound chip: the Register port (address FDh) and the Data port (address FFh). Three operations are important to consider:

- Writing to the Register port to select the active register
- Reading from the Register port to read the value stored in the active register
- Writing to the Data port to set the value stored in the active register.

Interacting with the RC2014 YM2419 sound card is similar, though not identical, in that to read the value stored in the active register, you read from a different port. For Rev 5 boards, you read the value from the Data port and on the Rev 6 board you read the value from a third, different port.

Thankfully, games like Centipede often only write data to the sound chip, rather than reading it. So, I needed to find `OUT` instructions within the program code that address either FDh or FFh.

This is straightforward to do with the debugger in (a recent version of) the EightyOne emulator: you can set two breakpoints to be triggered whenever you write to one of those two ports. Having done that, you then need to play the game to see what you find, noting down the addresses of the relevant OUT instructions as they trigger breakpoints.

Unfortunately, creating sounds often involves sending multiple commands (i.e., writes) to the sound chip, so the breakpoint will be tripped repeatedly by the same addresses. Furthermore, there is a chance that some instructions will only be reached in unlikely game scenarios -- e.g., you achieve a high score or unlock a special bonus feature. Because of this, having found the first few instances of instructions, I then start to look for occurances of the same byte pattern elsewhere in the code.

For Centipede and using the breakpoints based on `OUT` instructions, I quickly found instructions that communicate with the Soundbox at addresses 3CF4h (`OUT A,(FDh)`) and 3CF8h (`OUT A,(FFh)`). The breakpoint was also tripped by the same instructions at 4A7Eh, 4A81h,  4A8Ah, and 4A8Fh, so I was reasonably confident I understood how the programmer interacted with the Soundbox. Next, I searched (again using EightyOne Debugger) for other candidate instructions, represented by the byte sequence D3h, FDh or D3h, FFh.  This identified a number of candidates, at address 4A77h and 4A7A, plus repeats of the previously identified instructions at 30F4h, 30F8h, 34F0h, 34F8h, 38F0h, and 38F8h (iniitally, I did not remember that user memory on the Ace in the interval 3C00h--3FFFh is mirrored to 3000h-33FFh, 3400h--37FFh, 3800h--3BFFh, so I was curious at the apparent multiple copies of the same code).

I was fairly confident that the additional candidates were indeed interactions with the sound card though, noting it could be data that coincidentally has the same byte pattern, I deleted the original breakpoints (looking for `OUT`) and replaced them with breakpoints that stopped if code is executed at the candidate addresses. Then, I began playing the game again though, having set more targetted breakpoints, the action was not stopped by the previously identified instructions. Soon enough the emulator tripped over each candidate address, so I had my list of instructions to be changed: `3CF4h`, `3CF8h`, `4A77h`, `4A7Ah`, `4A7Eh`, `4A81h`, `4A8Ah`, and `4A8Fh` (noting, in each case, whether the instruction accessed the Register port or the Data port).

The final step was then to edit the port address for each of these instructions, replacing the original value (e.g., 'FDh' for Register port) with the corresponding value for the RC2014 sound card (e.g., 'D8' for a Rev 5 board with default port configuration). Note that the port address is the second byte of the two-byte `OUT A,(XX)` instruction, so I needed to change the value at `3CF5h`, `3CF9h`, and so on. I wrote a FORTH word `PATCH` to do this, using constants `REG` and `DAT` to allow someone to adjust the replacement addresses according to the particular settings of their card.

Having patched and re-saved the program, I was able to test on the Minstrel 4th and confirm by ear that things sounded correctly.

As a final check, I ran the patched version of the program in EightyOne and confirmed there was no sound from the Soundbox (indicating I had not missed any instructions).

Finally, it was time to play some Centipede!
