# Machine-code routine to work out clock speed on Minstrel 4th

Minstrel 4th can be configured to run at either 3.25 MHz or 6.5 MHz. Sometimes you need to know the clock speed, to make sure your programs work properly -- for example, if using sound or loading/saving data from/to cassette.

This machine code routine can be CALL-ed from Forth and will return a value from which the (approximate) clock speed can be calculated, using the following simple formula:

Clock speed = ( (VALUE + 300) * 25 * 50

This is assuming a 50 Hz display (for 60 Hz models, replace the 50 above by 60).

As there are only two possible clock speeds (at time of writing), it is usually enough to check if VALUE is around 2,500 (for 3.25 MHz) or 5,300 (for 6.5 MHz).

Code is available pre-assembled in a relocatable code block in "clock-check.tap", which can be loaded into memory and run with, for example:

`  65280 15384 ! QUIT ( LOWER RAMTOP ) `

`  65280 0 BLOAD CLOCKCHCK ( LOAD M/CODE )`

`  CALL 65280 ( RUN ROUTINE )`

`  . ( PRINT RESULT )`



