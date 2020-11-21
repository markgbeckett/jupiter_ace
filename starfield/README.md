# Starfield Simulators in FORTH

Source code for several FORTH-based implementations of starfield simulator, initially inspired by @BreakIntoProg on Twitter.

## `starfield.fs` (Jupiter Ace)

`starfield.fs` is a Forth source code that can be typed into the Jupiter Ace or Minstrel 4th. Once entered, run with `STARS`.

Alternatively, if you have an Jupiter Ace emulator, you can use the TAP image `starfield.tap` directly. Open the TAP file in your preferred emulator and type:

`load stars`

`stars`

On the Minstrel 4th, you can get a better (that is, faster) starfield by running the clock at 6.5 MHz.


## `starfield_zxs_aber.fs` (ZX Spectrum with Abersoft FORTH)

While not a Jupiter Ace program, I thought it would be useful to see a ZX Spectrum implementation, as this includes high-resolution graphics, which are not (easily) available on the Ace.

`starfield_zxs_aber.fs` is the FORTH source file that can be used with Abersoft FORTH on the ZX Spectrum (https://worldofspectrum.org/archive/software/utilities/forth-abersoft).

If you wish to enter the program from source, you should first read the Abersoft manual and learn how to edit screens.


Alternatively, you can use the TZX image `starfield_zxs_aber.tzx`. Load Abersoft FORTH, then open the TZX image and type:

`LOADT`

`1 LOAD`

`STARS`
