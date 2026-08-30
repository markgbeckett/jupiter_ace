# Example Forth Codes

## Canonical Pile Calculator

The sightly dull-sounding Forth example Canonical Pile Calculator, from Leo Brodie's book [Starting Forth](https://forth.com/starting-forth/12-forth-code-example/) is well worth studying, if you want to learn Forth. 

I have created a port of this example to Ace Forth. To use this port, either:

* Open the TAP file (canonical_pile_calculator.tap) in your preferred emulator.
* Enter `LOAD pile`.
* Use `VLIST` and `LIST` to examine the source code.
* Run the code by selecting a material and then initiating a calculation. For example:

```
CEMENT
10 FOOT 6 INCH PILE
```

Alternatively, if you have a Minstrel 4th with a USB Keyboard Interface or a Minstrel 4D, you can transmit the source code (canonical_pile_calculator.fs) from your PC using a serial terminal.


## Maze Generator (based on Eller's Algorithm)

[Eller's Algorithm](https://weblog.jamisbuck.org/2010/12/29/maze-generation-eller-s-algorithm) is a method for generating a perfect maze (one in which any two points are connected by a single path). It progressively generates a maze row by row and the cost of generating the maze scales linearly with the maze dimensions. The algorithm is quite challenging to implement correctly. Hopefully, my attenpt is accurate.

This version creates a 16-by-16 maze. To run the program, enter the following:

```
LOAD eller
SETUP-UDG
MAKE-MAZE
```

You only need to run `SETUP-UDG` once, when you first load the program.

If you wish to redefine the maze size, you need to make the following changes:

```
<nn> CONSTANT WIDTH
REDEFINE WIDTH
<mm> CONSTANT HEIGHT
REDEFINE HEIGHT
CREATE SET-LIST WIDTH 1+ ALLOT
REDEFINE SET-LIST
CREATE MAZE WIDTH HEIGHT * 2 * ALLOT
REDEFINE MAZE
```

## AceSnow

Inspired by Xsnow, which probably adorned the desktops of many Unix workstations in the 1990s, I have created Acesnow featuring realistic snowfall and a surprise visitor!

To use, type in the source code, and then enter
```
INITSANTA
SNOW
```

Alternatively, if you have a Minstrel 4th with a USB Keyboard Interface or a Minstrel 4D, you can transmit the source code (acesnow.fs) from your PC using a serial terminal.


## Scroll

A Jupiter Ace (machine-code) implementation of the popular Commodore
scrolling-maze example.

A ready-to-run version is included in [scroll.tap](scroll.tap), which can be run using:

```
LOAD scroll
SCROLL
```

Note that the routine is an infinite loop: you need to reset the Ace to stop the program.

The Z80 [source code](scroll.asm) for the main routine is also provided, with brief instructions on how to assemble and use it.
