# FORTH Toolbox and Message Scroller for RC2014 Bubble Display Module

For some retro bling, you can connect an RC2014 Bubble Display to your Minstrel 4th and enjoy a genuine 1970s LED display.

![](rc2014_bubble_display_module_2.png "Bubble display in action")

The RC2014 Bubble Display module is simple to control via I/O ports 0x0000 and 0x0002 and Ace Forth is capable enough to produce some pleasing display effects.

[Shiela Dixon](https://peacockmedia.software/) was heavily involved in the development of the RC2014 Bubble Display Module and, as part of this work, she produced a [simple toolbox](https://github.com/shieladixon/Bubble-display-toolbox) and message scroller in FORTH (as well as BASIC and Z80 assembly language).

I have ported the FORTH source to work on the Minstrel 4th, applying some Minstrel 4th-specific optimisations to get the the best out of the system.

I have provided the updated source code in two files [bubtb.fs](bubtb.fs) and [scrollinp.fs](scrollinp.fs), containing the basic toolkit and a sample message scroller, as for the original. However, as the Ace does not support the  `include` directive, the TAP archive [scrollinp.tap](scrollinp.tap) contains both the toolkit and the scroller in one dictionary file.

If you wish to load only the toolkit--for example, to build your own application--you can use [bubtb.tap](bubtb.tap).

![](rc2014_bubble_display_module.png "Assembled RC2014 Bubble Display Module")

