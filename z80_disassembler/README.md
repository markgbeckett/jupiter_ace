# Introduction

A Z80 disassembler is a useful tool to have to hand, both for developing and debugging machine-code programs and for interrogating the computer's ROM routines.

This project takes a compact Z80 disassembler, developed by Toni Baker and described in her book (Machine Code Programming for Your ZX Spectrum)[https://ia600604.us.archive.org/view_archive.php?archive=/1/items/World_of_Spectrum_June_2017_Mirror/World%20of%20Spectrum%20June%202017%20Mirror.zip&file=World%20of%20Spectrum%20June%202017%20Mirror/sinclair/books/m/MasteringMachineCodeOnYourZXSpectrum.pdf], and generalises it so it can be used on a range of Z80-based microcomputers (specifically, targetting the Minstrel 4th and Minstrel 2).

Toni's Z80 disassembler is designed to be as compact as possible, occupying around 1.25 kB, meaning it can easily coexist with other development tools and any program being developed. further, for the Minstrel 4th, it can be added to the Ace Forth ROM, in the extra space at 0x2800--03BFF (see (Minstrel Goes Forth)[http://blog.tynemouthsoftware.co.uk/2020/05/minstrel-goes-forth.html]).


## Further reading
