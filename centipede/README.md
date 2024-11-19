# Centipede on the Minstrel 4th and 4D

## Introduction

Centipede is an arcade game, launched by Atari in 1981. It was very popular and spawned a number of micro conversions including, in 1984, a decent port by Colin Dooley to the Jupiter Ace. Colin's port is very playable with a strong resemblence to the original (accepting there is no spider and everything is monochrome). It is also one of the few Jupiter Ace games that supports both the Boldfield Soundbox and the Boldfield joystick interface.

If you have read my [post about Valkyr](../valkyr-minstrel/README.md), you will know that by adding an RC2014 YM2149 sound card to the Minstrel 4th or 4D gives a Soundbox-like experience, accept that the port addresses used for controlling the card are different.

Centipede runs fine on the Minstrel 4th and 4D though does not have the enhanced sound support. I have therefore updated Colin Dooley's original, so that you can play the game in all of it's original glory, Plus, if you have a joystick interface, you can get the full experience.

** Playing the game

To run Centipede on your Minstrel 4th/ 4D, simply load the game from the TAP or WAV file with `LOAD centipede` and type `centipede` to run.

A reminder about the keyboard controls is provided at the beginning of the game: to fire, you press 'A', to move you press 'J' and 'L' to move left and right, 'I' and 'M' for up and down. Joystick controls, if you have a suitable interface, are also available.

** Sound Support

Centipede produces sound on both the built-in speaker and, if plugged in, an RC2014 YM2419 sound card. By default, the program assumes the RC2014 YM2419 sound card Rev 5 default addressing (that is, the Register port is D8h and the Data port is D0h). If you have a Rev 6 card or your card is configured to use different ports, you can update the program using the built-in `PATH` word.

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
