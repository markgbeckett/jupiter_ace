# Additional Utilities for Jupiter Ace and/ or Minstrel 4th

This directory contains a selection of word definitions that I have found useful and I think are worth sharing with others.

Those filenames that have names postfixed with "_zxf4" are for the modified Tree Forth for the Minstrel 4th. Typically, these are provided as WAV files which can be loaded into the editor screen and compiled. Each utility starts from Screen 1 and utilities that spam multiple screens are chained with `-->`. Thus, the utility can be loaded with `CON 1 LOAD`, which should load an compile the full set of screens.

- [random_number_generator.tap](random_number_generator.tap) - a copy of the random-number generator from the Jupiter Ace manual.

- [debugging_tools.tap](debugging_tools.tap) - some words, for Ace Forth, to help with debugging.

- [floating_point.fs](floating_point.fs) - a selection of additional words to help with handling floating-point numbers and arithmetic.

- [llist_zxf4.wav](llist_zxf4.wav) - a small selection of words that enhance Tree Forth's ZX Printer support.

- [clock_zxf4.wav](clock_zxf4.wav) - a version of the clock demonstration, from the Tree Forth manual, but updated for PAL-based, 50 Hz systems. This demonstrator depends on [llist_zxf4.wav]

- [loading_from_tape.md](loading_from_tape.md) - guidance on loading software via the cassette tape interface (either from a real cassette player or a computer audio adaptor).

- [jupiter_chars.asm](jupiter_chars.asm) - a Z80 source file, which assigns labels to the Jupiter Ace character set (helps with portability of code to other Z80-based systems, which use different character encoding).

```
: SPRINT 0 DO C>N TX LOOP ;
```
