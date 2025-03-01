# Centipede on the Minstrel 4th and 4D

## Introduction

Centipede is an arcade game launched by Atari in 1981. It was very popular and spawned a number of micro conversions including, in 1984, a port by Colin Dooley for the Jupiter Ace. Colin's port is very playable with a strong resemblence to the original (accepting everything is monochrome and some of the enemies are missing). It is also one of the few Jupiter Ace games that supports both the Boldfield Soundbox and, apparently, a joystick interface.

If you have read my [post about Valkyr](../valkyr-minstrel/README.md), you will know that by adding an RC2014 YM2149 sound card to the Minstrel 4th or 4D, you can get a Soundbox-like experience (except that the port addresses used for controlling the card are different).

The Ace version of Centipede runs without issue on the Minstrel 4th and 4D, though does not have the enhanced sound support, because of the different port requirements of the sound card. I was also unable to get the game to work with a joystick. I therefore set about updating Colin Dooley's original, so that you play the game in all of its three-channel-audio glory using either a joystick or keyboard, on the Minstrel 4th/ 4D.

In short, I have created a new version of the game that runs well on the Minstrel 4th/ 4D, supports the RC2014 sound card, and the Boldfield/ Tynemouth interface. Plus, it has some extra features as I reveal below.

If you just want to play the game, follow the instructions in the next section. If you want to read about my experience of disassembling the game, have a look at the section below titled "Disassembling Centipede".

## Playing the game

There are three different versions of the game, named [centipede-m4_sb.tap](centipede-m4_sb.tap), [centipede-m4_rev5.tap](centipede-m4_rev5.tap), and [centipede-m4_rev6.tap](centipede-m4_rev6.tap), for the Boldfield Soundbox, the YM2149 sound card Revision 5 (default configuration), and the YM2149 sound card Revision 6 (MSX configuration), respectively.

To play Centipede on your Minstrel 4th/ 4D, simply copy the tape image to the SD card and load using the menu system (choose to load the game "CENTIPEDE" but not to auto-run). Once loaded, start the game by entering `GO`.

To play the game in an emulator (for example, EightyOne), choose the Soundbox version. If your emulator supports Soundbox audio, you will get enhanced sound.

A reminder about the keyboard controls is provided at the beginning of the game: to fire, you press 'A', to move you press 'J' and 'L' to move left and right, 'I' and 'M' for up and down.

Joystick controls, if you have a suitable interface, are also available. Press 'H' to switch to joystick controls, while playing the game. Press 'K' to switch back to keyboard controls.

## Disassembling Centipede

My original plan had been to make fairly lightweight changes to the code that handled sound in the original game (effectively, changing the port numbers used in the relevant `IN` and `OUT` commands, which I found by setting a breakpoint in EightyOne on any interactions with the Soundbox I/O ports 0xFD and 0xFF), so that it would work with the RC2014 sound card on a Minstrel 4th/ 4D. I did this though, in so doing, I found myself hunting for evidence of joystick support within the program.

In an interview with the curator of the [Jupiter Ace website](https://www.jupiter-ace.co.uk/sw_centipede.html), Colin Dooley noted that the game could also be controlled by joystick. As the Minstrel 4D has a built-in joystick interface that is compatible with the original Boldfield joystick interface, I assumed this would work straight away and was surprised when it did not.

I then read Colin's comments more carefully and realised that he had implemented his own joystick interface using the I/O ports on the AY-3-8910 (in the Soundbox interface).

I was a little surprised as I thought I had found all interactions with the sound card, when updating the sound support, even though none of those looked to interact with the I/O ports on the sound chip. I therefore started to delve further into the game code and created a partial disassembly of the code, concentrating on the section that handles game controls.

By running the game on the [EightyOne emulator](https://sourceforge.net/projects/eightyone-sinclair-emulator/) and pausing mid-game, I was able to step through the return addresses on the stack and find the main game loop. It was located at address 3C80h and consisted of a sequence of eight calls to six different subroutines in a continuous loop:

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

Single-stepping the code, I quickly found the routine that checks for fire being pressed (the subroutine at address 3F28h). There was no evidence of an attempt to read from the joystick: the routine only checked for the 'A' key.

I also found the code that checked the direction keys (the subroutine at address 3EF0h). Again, there was no evidence of joystick support.

I started to wonder if there were multiple versions of the program code and I was looking at a version without joystick support. Either way, I strongly suspected the joystick support was for a custom interface; so to support the Boldfield (and Tynemouth) joystick would require new code. Therefore I decided to add joystick support to this version of the game.

The machine code of the main game is stored in the Centipede dictionary in two words named `DATA` and `MORECODE`. The program code is not relocatable and the game entry point is expected to be at address 3C60h. This made it difficult to modify the existing code, since changes to the dictionary are likely to move subsequent words in memory and stop the game from working. Therefore I initially elected to add new game-control routines (one for fire and one for directions) at the end of the dictionary and then find the appropriate place to call out to those routines from within the original game code.

I created a new word, named `GAMECTRL`, at the end of the dictionary, in which to hold the new code. (The easiest way to do this is to use `CREATE` to create a basic word and then use `ALLOT` to expand the parameter field to be large enough to hold the machine code). In this case, the parameter field for `GAMECTRL` started at address 5580h, so that is where I located the new code.

I started with the routine that checked for the Fire button, as this seemed the easier of the two. The routine at 3F28h is relatively self-contained so I set about making a new version of it that would also check the fire button on the joystick. The routine first checks to see if there is already a bullet in flight. If so, there is nothing to do and control is returned the game loop. Otherwise, it checks if fire is pressed and, if so, jumps to a routine at 3F3Fh to implement the fire mechanism.

Originally, I planned to have joystick support enabled all the time and to check both keyboard controls and joystick controls. However, I discovered that if no joystick interface is connected, then reading the joystick port can produce a misleading result, as described by Dave Curran in [Valkyr - One Game, so many changes](http://blog.tynemouthsoftware.co.uk/2022/10/valkyr-one-game-so-many-changes.html). For example, on EightyOne, reading the port will typically return 20h (or 00100000 in binary) and, unfortunately, bit 5 is linked to the fire button, so this means the game thinks fire on the joystick is being pressed constantly.

Given this, I decided to update the game so the user could turn on and turn off joystick support. An easy way to do this, which did not require significant changes to the original code, was to check for additional keys within the routine handling fire. Specifically, I extended the routine to check for 'H' and 'K', which I mapped to joystick-support on and joystick-support off, respectively. The 'J' key is more obvious than 'H' but this is already mapped to the move-left command.

I then moved on to look at the routine that checks the direction controls. That routine is more complicated than the routine that checks for fire, fulfilling various functions. However, after a little studying I found a call out to a subroutine at address 3E60h which is where the keyboard controls are checked. Again, I wrote a new version of this routine to check the keyboard or the joystick port, according to which control was active.

To complete the port, I then had to change the call instructions (one at address 3C86h, one at address 3C8Fh and one at address 3F03h) to point to my new versions of the routines, save the new version of the game, and get testing.

I also considered changing the keyboard controls, as I found them slighty awkward to use and thought it might be easier to play with the typical 'Q', 'A', 'O', 'P', and 'M' controls. However, looking back at pictures of the original Centipede arcade machine, I remembered that it used a trackball for control (possibly, Centipede was the first arcade game to use that control) and realised that Colin's control choice sort of mimicked that setup. Thus, I decided it was best to leave it as Colin had designed it. With all of the testing, I was also getting more used to the controls anyway.

The work to add joystick support to Centipede piqued my interest: I started to look into other game-loop routines and soon decided I would try to created a full, commented disassembly of the game, which you can study in [centipede.asm](centipede.asm).

In creating the disassembly, I learned a lot about the game and how it was written. I think it is an interesting program to study, for someone with a reasonably understanding of Z80 machine code.

I made the following interesting discoveries while disassembling the code:

- There is quite a lot of unused memory in the program, evidenced by sequences of `nop` statements between routines. Given that Colin Dooley wrote this game by hand-assembling code into hexadecimal opcodes and poking them into memory on an actual Ace, I think this is reasonable. I suspect Colin left space between routines to allow later changes/ expansion, without a need to relocate subsequent routines -- something that would be painful to do when hand-assembling a program.

- I did not find any evidence of joystick support. Possibly there is another version of the game, which includes the support, or possibly Colin mis-remembered this aspect of writing the game.

- The first routine in the main game loop returns immediately. I had originally wondered if this was a placeholder for an additional game feature -- such as the bouncing spider from the Atari original --  though, having disassmbled the whole program I realised it is, in fact, a debugging routine. Beyond the first command in the routine (which is a `ret`), there is code that checks for the Space key being pressed and, if so, exits back to Forth. You can reinstate the routine by replacing the `ret` statement at address 41C8h with `push af`: something that proved useful when I went on to do further work on the program.

- My suspicion that the first game-loop routine was a place-holder for the spider was wrong. However, Colin did at least consider adding a spider to his game as, during initialisation, two graphics are set up that constitute the left and right halves of a spider. This graphic is never used in the original game.

- I have found five bugs in the game (look for comments beginning with "BUG:" in the [source code](centipede.asm)). Three of them have no significant impact, one might cause problems in very specific circumstances when a centipede meets the flea, but the other bug does definitely affect game play. That bug relates to initalising a new flea. There should be a 50/50 chance that the flea drops slowly or quickly. However, the calculation is broken meaning the flea almost always drops quickly.

- There are a few instances of redundant code and of absolute jumps that could be replaced by relative jumps (look for comments beginning with "NOTE:" in the source code). However, these are not meant to be criticisms of the original programming. As noted above, Colin wrote this game on an actual Jupiter Ace, using hand assembly. This is an impressive feat which requires great skill, organisation, and stamina. A genuine example of bedroom coding in action!

## Finishing Colin Dooley's Work

Having disassembled the program, and having discovered the spider graphic, I decided it would be fitting to try to add the spider feature and to properly integrate Boldfield joystick support, to finish off Colin's work.

I have tried to find a contact address for Colin so I can tell him about this project, though have so far failed. Hopefully, Colin will be happy with what I have done.

Before adding spider support, I decided to do a modest refactor of the program, removing the space that was left between many of the routines. I did this to hopefully free up enough space to add in the extra features that I planned without overspilling the words `DATA` and `MORECODE`.

Also, as `DATA` and `MORECODE` were held consecutively in memory, I edited the link field in the subsequent word `CENTIPEDE`, so that `MORECODE` is effectively deleted and `DATA` has an expanded parameter field also covering the dictionary space previously occupied by `MORECODE`. This means I did not have to worry about preserving the location and correctness of the `MORECODE` header, which is located in the middle of the source code.

I decided to implement the spider in a similar way to the flea. In simple terms, they are alike, in that they are enemies to be shot or avoided that progress across the screen until they are done.  The special feature of the flea is that it deposits mushrooms as it falls down the screen. Whereas the spider eats mushroom that it passes over. Looking at recordings of someone playing the Atari original game, I saw that the spider had a reasonably complex movement pattern, zigzaging its way across the screen. I decided to consult a disassembly of the [original game code](https://6502disassembly.com/va-centipede/Centipede_rev4.html) by Andy McFadden to find out more.

It took me a little while to get to grips with the original code. It is written in 6502 assembly language which I am less familiar with and I was original confused by two elements: the game checks if it is being played on a "cocktail table" in which case it inverts the screen for Player 2; and the game has a demo mode which is referred to as "attract mode".

Once I was aware of the cocktail and attract modes, it was somewhat easier to work out what was going on and I was surprised to discover that my recollection of how the spider moved was wrong. It turns out the spider either moves from left-to-right or right-to-left and never reverses its direction. During its travels, there is a chance it will stop moving horizontally and just move vertically for a while, before resuming its journey. I tried to work out the speed and the probability of it changing how it moved at any point, and then implemented that in Z80 machine code.

Then I had to tackle the bit I had been most dreading: adding sound effects. Colin's original version helped a little here, in that it only used two of the three sound channels on the AY-3-8910 chip, so I was able to use the third channel (Channel C) without any risk of corrupting existing sound effects. I thought for a while about how to do this, and considered reaching out to the community for help. However, in the end, I decided to reverse engineer the implementation on the Atari original, which used a special chip called the Pokey chip, for which there is [online documentation](http://visual6502.org/images/C012294_Pokey/pokey.pdf).

I worked out how to translate between the Pokey chips implementation of sound frequencies and the AY-3-8910's implementation and then created a small spreadsheet to convert the sound sequence for the spider.

The final result is not 100% accurate, but I think it is close enough, and sounds good with the rest of the game sounds.

Having implemented the spider enemy, I also fixed the bugs I had found in the original code, and reinstated joystick support -- though embedded in the main code rather that in an extra Forth word at the end of the dictionary.

The [source code](centipede_m4.asm) of the modified version of the game is also available if anyone wants to study my changes or to make further enhancements to the game. It should assemble with most of the common cross-assemblers. I have used [z80asm](https://savannah.nongnu.org/projects/z80asm). Having assembled the source -- e.g. `z80asm -o centipede.bin centipede_m4.asm` -- you should load Centipede into an emulator, such as EightyOne, and then load the assembled binary file at memory address 0x3C5C.

The game employs basic security to prevent unauthorised copying and overloads the meaning of various words including `SAVE`. To work around this, you need to use `EXECUTE` and point to the code field of the original SAVE word. For example, enter:

```
6452 EXECUTE centipede
```

--in decimal mode.

Finally, write a new tape image from EightyOne with your modified version of the game and enjoy.

