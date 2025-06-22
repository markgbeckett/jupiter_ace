# Mandelbrot Set Plotting Routine 

This is a Mandelbrot Set plotting routine, written in Ace FORTH, and using integer arithmetic. It uses the Ace's built-in `PLOT` routine to give a resolution of 44 by 64 pixels.

## Running the Program

To run the program, `LOAD mandelbrot` from the [TAP image](mandelbrot.tap) or the [WAV file](mandelbrot.wav). Alternatively, you can type in the [source code](mandelbrot.fs) directly or, on the Minstrel 4D, via the serial interface.

Once loaded, you can run the program with `MANDEL`. It takes around 40 minutes to complete the plot. To avoid spurious text, you can enter `INVIS CLS MANDEL`.

## Using Integer Arithmetic

Although Ace FORTH has support for floating-point arithmetic, I decided to use only integer arithmetic in the hope of speeding up the calculation.

The implementation follows the naive escape-time approach of computing the first few iterations of the Mandelbrot equation "z(n+1) = z(n)^2 + c", starting from "z=0" for each point "c" in the plot to see if the series exceeds a cut-off magnitude (the escape condition) beyond which the series is assumed to diverge.

The default plot dimensions are a rectangle from (-2,-1) to (0.47,1) and the escape condition is set to be 4. Usually, one would use floating-point arithmetic to iterate the algorith. However, instead I use an integer representations which scales everything by 2^13 (or 8,192). So, for example, the floating point number 1.0 is represented by 8,192, and -2.5 is represented by -20,480. The representation is chosen to ensure the escape condition (represented by +32,768) can be checked. In fact, 32,768 is one too big to be represented in 16-bit signed arithmetic, but this is okay, as we can simply check for an overflow.

Using this representation, we need to remember to rescale the working value after any multiplication. Therefore, to compute z(re)^2, we have to compute z(re)*z(re) / 8192. For example, in floating point arithmetic, 1.5^2 is 2.25. In this integer representation 1.5 is represented by 12,288 and 1.5^2 = 12,288 *12,288 / 8,192 = 18,432 (which is the representation for 2.25).

Ace Forth has a very useful word `*/`, which multiplies the stack entries 3OS and 2OS and then divides by TOS. The key is that the intermediate value resulting from multiplying 2OS and 3OS is stored in a double-length (32-bit) integer, so we do not risk an overflow.

Therefore, to square the number on the top of the stack, simply execute `DUP 8192 */`.

The implementation is based on one provided on the [Rosetta Code website](https://rosettacode.org/wiki/Mandelbrot_set#Forth), ported to work on Ace Forth. I have added extensive comments to help others to understand how it works. It is quite a complicated implementation, involving lots of stack acrobatics. It may take a little perseverence to fully understand what is going on.

