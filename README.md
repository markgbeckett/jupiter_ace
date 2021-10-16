# Software for the Jupiter Ace and Minstrel 4th

Some software I have developed for the [Jupiter Ace](http://www.jupiter-ace.co.uk/) / [Minstrel 4th](https://www.thefuturewas8bit.com/minstrel4th.html), which may be interesting or useful for others.

* `getting_started` - a quick introduction to using Forth on the Minstrel 4th (or Jupiter Ace).
* `bubble_led` - Minstrel 4th version of Forth toolbox and example message scroller for the RC2014 Bubble Display module.
* `case` - Many FORTH implementations include a CASE construct, which can be useful for choosing between different paths of execution based on a stack value. Sadly, Ace Forth does not, but it is relatively easy to add one, provided you can get to grips with the COMPILER and RUNS> words.
* `clock_check` - The Minstrel 4th can be run with a clock speed of either 3.25 MHz or 6.5 MHz (selected by a jumper on the board). Sometimes it is useful to be able to check, from software, which clock speed has been set, and adapt accordingly. This simple machine-code routine lets you check.
* `maze` - In May 2021, the curator of the Jupiter Ace archive put out a call for help to recover a corrupted game known simply as Maze. Here is the recovered game, with commented source, and a blog of the recovery process.
* `rc2014_source_card` - Inspired by the ZX Spectrum+ 128k's PLAY command, this is FORTH/ assembly language client for writing music for the RC2014 YM/AY Sound Card on your Minstrel 4th.
* `serial_int` - a library of Forth and machine-code routines to drive the RC2014 serial interface from your Minstrel 4th, including: simple send/ receive of bytes, echoing display output to the serial device, and transferring blocks of data to/ from the micro using the XMODEM protocol.
* `starfield` - inspired by posts on Twitter from @BreakIntoProg, here are several Forth implementations of a star-field simulator.
* `tut-tut` - an Ace FORTH implementation of David Stephenson's Egyptian-themed arcade game.
* `3d_monster_maze` - (work in progress) Ace FORTH port of the classic ZX81 game.
* `utilities` - additional words (mostly from the Jupiter Ace manual), which probably should have been in the Ace FORTH ROM.
