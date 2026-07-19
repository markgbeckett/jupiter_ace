Inspired by a video on Tim's Retro corner (https://youtu.be/4sX05bnFuwc?si=C3DUPkzGvRP220mm), I have been experimenting with the I2C interface on the Minstrel 4th. Thanks to the RC2014 bus on the Minstrel 4th, there are various options for an I2C controller. I am using the [Small Computer Central SC137](https://smallcomputercentral.com/rcbus/sc100-series/sc137-i2c-master-module-rc2014/) from Steve Cousins. 

The SC137 is an excellent kit, with through-hole components, very clear instructions and example code to get you started.

As a first I2C peripheral, I used an [Texas Instruments LM75A digital temperature sensor](https://www.ti.com/product/LM75A?utm_source=google&utm_medium=cpc&utm_campaign=ti-null-null-xref-cpc-pf-google-ww_en_cons&utm_content=xref&ds_k=LM75A&dcm=yes&gclsrc=aw.ds&gad_source=1&gad_campaignid=23167718368&gclid=Cj0KCQjw6_HSBhCpARIsANvVltbx4UwIXEwhoU4tSVX0ZtXN4xTsuBVeuN6lcSwTbR4VB1l1UBybTU0aAhjWEALw_wcB). Again, the LM75A is supported by good-quality documentation from Texas Instruments.

My aim has been to develop an I2C library in Forth for the Minstrel 4th to allow people to use different I2C peripherals and easily develop software for them. My library is heavily based on Steve Cousin's Z80 demonstrator plus this [I2C tutorial](https://www.robot-electronics.co.uk/i2c-tutorial) helped me get up to speed with the interface.

My eventual aim will be to write a library for my port of Tree Forth for the Minstrel 4th. Tree Forth has multi-tasking functionality which should be very useful for running several I2C devices as part of a bigger project. However, I started with Ace Forth, as I find the editor in Ace Forth easier to use, making experimentation more efficient.

The current library includes all the usual I2C operations (init, open, read, write, and close) plus an example for reading from the LM75A temperature sensor. The library assumes you are using the SC137 interface in its default configuration (listening on port 0x20). However, the I/O port and the bits used for the clock line (SCL) and data transmission (SDA) can be changed by redefining the relevant constant. For example, to change the I/O port to 48d:

```
  DECIMAL
  48 CONSTANT I2C_PORT
  REDEFINE I2C_PORT
```

I have included a TAP version of the library, which you could load with (for example) the Tynemouth Serial Card. I have also included a WAV file which you could load via the cassette interface. Finally, I have included the source code ([i2c_interface.fs](i2c_interface.fs)), so you can study the code. You could paste the source code into the Minstrel 4th (using the Tynemouth Serial Card and `TTY` xommand) though you need to avoid in-line comments outside of colon definitions (since they are not supported by Ace Forth).

Enjoy!


