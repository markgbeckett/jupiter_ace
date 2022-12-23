# Programming in Machine Code on the Minstrel 4th/ 4D

Ace Forth is both fast and memory efficient, so there is less need to resort to machine-code than in, say, BASIC. However, if you do need (or want) to add some machine-code to your latest project, here are a couple of ways to do it.

Note that this document assumes a reasonable familiarity with Ace Forth.

## Storing machine code in the dictionary

It is relatively easy to add small machine-code routines to an Ace Forth
dictionary, and there are various ROM routines using which your code can
access the data stack.

The [Jupiter Ace Forth Programming manual](http://www.jupiter-ace.co.uk/documents_index.html) includes a Forth defining word
`CODE`, for creating small machine code-based words:

```
DEFINER CODE
DOES>
  CALL
;
```

Having defined your word, you insert hand-assembled machine code into
your newly created word one byte at a time, using `C,`. (It may be
easier to switch to hexidecimal numbers before starting -- e.g.,
`DECIMAL 16 BASE C!`.)

The Forth Programming manual highlights some important
considerations for your code:

- You return to Forth using `jp (iy)` rather than the usual `ret`.

- You should ensure the IX and IY registers' values are restored before
  returning.

- Moving the machine stack can be problematic (it is used by Ace Forth
  to hold the Return Stack).

When using the CODE construct, your machine code is stored within the
dictionary, so you should make sure it is relocatable. Editing words
earlier in the dictionary will potentially move your code in memory,
which is likely to lead to problems if the code is not relocatable.

The Ace Forth ROM has useful routines for working with the data stack
from your machine code:

- `rst 0x10` stacks the DE register pair onto the data stack (HL is
  corrupted).

- `rst 0x18` pops the top of data stack into the DE register pair
  (again, HL is corrupted).

- `call 0x084E` pops the top of stack into the BC register pair (again,
  HL is corrupted).

There are a couple of other useful Restart routines:

- `rst 0x08` prints the ASCII code in the A register to the screen (BC,
  DE, and HL are corrupted).

- `rst 0x20` is essentially `ABORT` and will return to the Forth
  interpreter. Follow the call with a single byte error code

Here is a simple example of a machine-code routine to check the clock
speed of the Minstrel 4th/ 4D:

```
DECIMAL 16 BASE C!

CODE CLOCKCHECK ( -- N )
    11 C, 00 C, 00 C, (        ld de, 0x0000 ; Init counter   )
    21 C, 2B C, 3C C, (        ld hl, FRAMES ; Internal clock )
    76 C,             (        halt          ; Wait for int   )
    7E C,             (        ld a, <hl>    ; Initial value  )
    13 C,             ( LOOP : inc de        ; Update counter )
    BE C,             (        cp <hl>       ; See if changed )
    28 C, FC C,       (        jr z, LOOP    ; Repeat, if not )
    D7 C,             (        rst 0x10      ; Stack DE       )
    FD C, E9 C,       (        jp <iy>       ; Exit to Forth  )
```

Note, you will need to remove the (Forth) comments before typing this
into the computer, as Ace Forth only permits comments in colon
definitions.

Then, to call `CLOCKCHECK`, you simply type:

```
CLOCKCHECK
. ( VALUE ON TOP OF STACK )
```

Values around 2,500 indicate computer is running at 3.25 MHz and values
around 5,000 indicate computer is running at 6.5 MHz.

For longer machine-code routines, hand assembly becomes tiring and
error-prone (though people have written whole games in this way!). If
you would prefer to use an assembler, then you can pre-allocate some
space in the dictionary for your machine code using:

```
  CREATE MYCODE
  <NUM_BYTES> ALLOT
```

You can then write your routine using an assembler, save as a code
block, and then `BLOAD` into the right place with `MYCODE 0 BLOAD
<FILENAME>`.

You could also write your routine on a PC and use a Z80 cross-assembler
to assemble it into a binary file, which you could then load into an
emulator, such as EightyOne with "Load Memory Block", having first
allocated some space in your dictionary as above.

I use the [GNU Z80
assembler](https://savannah.nongnu.org/projects/z80asm), which is easy
to use and has most of the features you are likely to want.

Having inserted the machine code, you can then save your dictionary as
usual with `SAVE`.

As with `CODE`, you need to either make your machine-code routine
relocatable or ensure you do not move the holding word (e.g., do not
edit anything earlier in the dictionary). You also need to make sure
your machine-code routine is not bigger than the space you have allotted,
otherwise, you will corrupt later dictionary definitions.

## Storing machine code in high memory

You can also store machine code high up in memory, outside of the
dictionary, to avoid the short-comings of keeping machine code in the
dictionary (relocatability). Before doing this, you need to reserve some
space that will not be used by Ace Forth monitor, by redefining the
system variable called RAM (stored at address 15,384). You do this, with the
following code:

``
<NEW_LIMIT> 15384 !
QUIT
``

The `QUIT` performs a warm restart and moves the data stack to just below the
new limit. (This is similar to `CLEAR <NEW_LIMIT>` in some versions of BASIC.)

For example, on the Minstrel 4th/ 4D, you can reserve 16 kilobytes at
the top of memory (between 49,152 and 65,535, inclusive), for your
machine code, using:

```
49152 15384 !
QUIT
```

You can then load machine code (or data) at or above 49,152 in any way you
wish. Once inserted, you can call your machine code with `<address>
CALL`. The same restrictions apply as for dictionary-based machine code
and, again, you return to the Ace Forth monitor using `jp (iy)`.

The downside of storing machine code in upper memory is that it is not
saved with the `SAVE` command. Instead you need to use `BSAVE`.

This also presents problems if using the SD card interface on the
Minstrel 4D, as the interface is designed to store one tape output per
SD card file. One way around this is to save the dictionary and machine
code as a single binary code block using `15409 <END_OF_PROGRAM> OVER -
BSAVE <FILENAME>. Of course, if your machine code is separated from your
dictionary by a lot of unused memory, this all gets saved to the file,
slowing down save and load times.

Note, the Minstrel 4D's SD card interface can happily read multiple
files from a TAP file, so you could create a multi-part loader on an
emulator and then load it into the Minstrel 4D. It is only writing
multi-part programs that is not supported on the 4D.
