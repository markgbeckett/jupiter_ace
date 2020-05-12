# Tut-tut for the Jupiter Ace

[Tut-tut](http://www.zx81keyboardadventure.com/2019/10/zx81-game-tut-tut.html) is an Egyptian-themed retro-arcade game, written by David Stephenson, for the Sinclair ZX Spectrum and subsequently Sinclair ZX81 microcomputers.

As an intrepid archaeologist, you have to work your way through successively more challenging levels, working out a path to the exit, finding keys to let you slide moveable walls, collecting treasure, and avoiding the mummies that guard the tombs.

This version is a further port of Tut-tut to the [Jupiter Ace microcomputer](https://en.wikipedia.org/wiki/Jupiter_Ace). A less well-known contemporary of the Sinclair machines, the Ace stood out for its choice of built-in language; using Forth instead of the otherwise ubiquitous BASIC.

The Ace designers' expectation was that Forth would allow programmers to develop effective and performant applications within the constrained resources of a microcomputer, in a way that was not possible for sluggish and bloated BASIC programs.

Hopefully, Tut-tut for the Jupiter Ace--which is written almost entirely in Forth--demonstrates they were right even if the choice of Forth looks to have condemned the Ace to weak sales and its producers (Jupiter Cantab) to a relatively short existence.

If you wish to just play the game, you can download a pre-compiled tape archive 'tut-tut.tap', which should work on a range of emulators, including the [EightyOne emulator](https://sourceforge.net/projects/eightyone-sinclair-emulator/).

Once you have started the emulator, (if necessary) switch to Jupiter Ace emulation mode, make sure the 16kb RAM pack is enabled, open the tape archive 'tut-tut.tap', and type the following commands:

`load TUTTUT`

`tuttut`

Ace Forth is not usually case-sensitive, though the file-name 'TUTTUT' in the `load` command is.

However, I have also published the source code in the hope that some people will be inspired to type it in themselves (as was common practice in the early 1980s) and then adapt/ improve on the basic game.

Enjoy!

## Tips

1. Some levels have to be completed in a certain way. Moving the wrong sliding wall might make the level impossible. You can pause the action, by pressing 'W', and take a moment to plan your route.
2. Bracelets ($ on ZX81) not only net you lots of points, they also have mystic powers and can paralyze the mummies. However, use prudently, because their power only lasts for a short time.
3. Amulets (£ signs on ZX81) need to be handled with care. They net lots of points, but also paralyse you temporarily, leaving you at the mercy of nearby mummies.
4.  If you get really stuck, you can restart a level by pressing 'R'. But only do it if you really have to, as your score is halved!
5. Mummies will chase after you if they see you. However, they aren't that clever; it's easy to hide from them, if you get used to how they move.
6. You need to demonstrate your worthiness to access Tut's treasury, by securing enough points. Make sure to collect all gems, amulets, and bracelets; finish levels quickly; and try not to get caught by mummy nor restart a level.
7. For a slightly more challenging game, on Jupiter Ace, use FAST mode to get a ~20% speed-up (though note you won't then be able to break into the game, except when a sound is playing). If it turns out too much, switch back to SLOW mode.

## Further reading

More information on the process of porting Tut-tut to the Jupiter Ace can be found in two blog posts on the ZX81 Keyboard Adventures blog site, managed by David Stephenson:

- http://www.zx81keyboardadventure.com/2020/05/tut-tut-on-jupiter-ace-part-1.html
- http://www.zx81keyboardadventure.com/2020/05/tut-tut-on-jupiter-ace-part-2.html
