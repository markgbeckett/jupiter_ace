Inspired by a video on Tim's Retro corner (https://youtu.be/4sX05bnFuwc?si=C3DUPkzGvRP220mm), I have been experimenting with the I2C interface on the Minstrel 4th. Thanks to the RC2014 bus on the Minstrel 4th, there are various options for an I2C controller.

I am using the [Small Computer Central SC137](https://smallcomputercentral.com/rcbus/sc100-series/sc137-i2c-master-module-rc2014/) from Steve Cousins. The SC137 is an excellent kit, with through-hole components, very clear instructions and example code to get you started.

![Small Computer Centre Sc137](sc137_card.jpg)

As a first I2C peripheral, I used a [Texas Instruments LM75A digital temperature sensor](https://www.ti.com/product/LM75A?utm_source=google&utm_medium=cpc&utm_campaign=ti-null-null-xref-cpc-pf-google-ww_en_cons&utm_content=xref&ds_k=LM75A&dcm=yes&gclsrc=aw.ds&gad_source=1&gad_campaignid=23167718368&gclid=Cj0KCQjw6_HSBhCpARIsANvVltbx4UwIXEwhoU4tSVX0ZtXN4xTsuBVeuN6lcSwTbR4VB1l1UBybTU0aAhjWEALw_wcB). Again, the LM75A is supported by good-quality documentation from Texas Instruments.

My aim has been to develop an I2C library in Forth for the Minstrel 4th to allow people to use different I2C peripherals and easily develop software for them. My library is heavily based on Steve Cousin's Z80 demonstrator plus this [I2C tutorial](https://www.robot-electronics.co.uk/i2c-tutorial) helped me get up to speed with the I2C protocol. Finally, I checked the low-level operations using the [I2C standard](https://www.nxp.com/docs/en/user-guide/UM10204.pdf), which is very readable and worth checking.

I have provided two versions of the I2C library: one for Ace Forth and one for the Minstrel 4th port of Tree Forth. Tree Forth has multi-tasking functionality which is very useful for running several I2C devices as part of a bigger project. However, I started with Ace Forth, as I find the editor in Ace Forth easier to use, making experimentation more efficient.

The current library includes all the usual I2C operations (init, open, read, write, and close) plus an example for reading from the LM75A temperature sensor. The library assumes you are using the SC137 interface in its default configuration (listening on port 0x20). However, the I/O port and the bits used for the clock line (SCL) and data transmission (SDA) can be changed by redefining the relevant constant (`I2C_PORT`, `SCLBIT`, and `SDABIT`, respectively). For example, to change the I/O port to 48d in Ace Forth:

```
  DECIMAL
  48 CONSTANT I2C_PORT
  REDEFINE I2C_PORT
```

---or, on Tree Forth:

```
  DECIMAL
  48 TO I2C_PORT
```

For the Ace Forth version, I have provided a TAP file, which you could load with (for example) the Tynemouth Serial Card. I have also included a WAV file which you could load via the cassette interface. Finally, I have included the source code ([i2c_interface.fs](i2c_interface.fs)), so you can study the code. 

For the I2C library for the (Minstrel 4th port of) Tree Forth, I have provided a WAV file in which the source code is contained in six screens. To load the library into Tree Forth, switch to split-screen view and make the console active (using Shift-1). Then enter:
```
CON 1 LOAD
```
--and play the WAV file. A print-out of the source code is provided in [i2c_zxf4.bmp](i2c_zxf4.bmp), which has been made by listing each screen to the ZX Printer (emulated in EightyOne).


Enjoy!
