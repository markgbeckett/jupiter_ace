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
