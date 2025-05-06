# Loading programs from WAV files

It is possible to load programs, on emulator tape files, into your Minstrel 4th using your PC and a couple of utilities.

This is not the only way to do this, but seems reliable for me.

First, grab a copy of the Castool utility which is distributed with the [MAME emulator](https://docs.mamedev.org/tools/castool.html). Castool will convert emulator tape files (e.g., Ace TAP files) into WAV audio format.

Castool supports lots of different emulators and formats, but a typical invokation for an Ace file is:

```
castool convert jupiter <program>.tap <program>.wav
```

Then, load the WAV file into [Audacity](https://www.audacityteam.org/), and apply a low-pass filter (use Ctrl-A to highlight the whole file, then select <Effect><EQ and Filters><Low-Pass Filter ...>) with a frequency set to 2000 Hz (and default rolloff of 6 dB).

Connect your PC audio out to the Ear on the Minstrel 4th (ideally, using a mono, 3.5mm jack, as was supplied with the original Ace). Check the audio settings for the audio device you are using, at the PC end, and make sure that any audio effects (such as Enhanced Audio or Spatial Sound) are disabled and set the volume to maximum.

Finally, enter `LOAD <filename>`, and start playback. (Note: make sure you have selected the right playback device to avoid a loud surprise.) 

Hopefully, the Minstrel 4th will read the header and display the file name/ type and then load the body of the file without error.

If you see an `ERROR 10` message or the Minstrel 4th does not detect a program, you may need to experiment with the volume level. You may also wish to try amplifying the sound profile in Audacity.

If you are close, you should hear a quiet click, from the Minstrel 4th, when it finishes reading the header. This is a good sign and suggests your settings are close to suitable. If you hear a fast, repeating click (a couple of clicks per second), your volume level may be too high. 

If you are unable to read anything, and do not even manage to get an `ERROR 10` message, you might want to try a cheap and simple, external USB audio interface (I use [this one](https://nedis.com/en-us/product/computer-and-mobile/peripherals/sound/550670257/sound-card-51-usb-20-microphone-connection-1x-35-mm-headset-connection-35-mm-male)). It seems cheap interfaces do less to modify (that is, improve!) the sound and so provide a more accurate reproduction of the original tape audio. They may also produce a higher signal level.

The above is not a foolproof strategy. There are lots of variables here: the PC, the audio device, the Audacity settings, and the cable to name just a few. You may need to do some experimentation to get a reliable setup.

Good luck!
