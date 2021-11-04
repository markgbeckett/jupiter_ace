# 3D Monster Maze for the Jupiter Ace (16k)/ Minstrel 4th

This is a port of the classic, ZX81 game "3D Monster Maze" to the Jupiter Ace and Minstrel 4th.

The game was written by Malcolm Evans and published by J.K. Greye software in 1982. It was an one of the first examples of a 3D arcade game for a home computer and was considered an amazing feat, given the limited capabilities of the humble ZX81 computer.

The Jupiter Ace had many similarities to the ZX81, built around the Z80 processor and with simple, character-based display, but whereas the ZX81 shipped with BASIC as its built-in language, the Jupiter Ace shipped with FORTH.

This port aims to exploit the capabilities of the Jupiter Ace's built-in FORTH interpetter, while reproducing the original game as accurately as possible, though favouring FORTH over machine code whenever possible.

## Preview

You can run the in-progress implementation, using the following steps:

1. Open "3d_monster_maze.TAP" in your preferred emulator.
2. Enter `LOAD 3DMM`.
3. Set up UDGs with `SETUPUDG`.
4. Set up maze with `CLEARMAZE`, `CREATEMAZE`, `MAKEEXIT`. Note that the create-maze step takes around 15 seconds to complete.
5. Optionally, view maze with `CLS`, `PRINTMAZE`.
6. Start demo with `TEST`.
7. You can move around the maze using `6` to turn left, `8` to move forward, and `9` to turn right.

You can break out of the demo, using `Shift-SPACE`.

This is an in-progress project, so some elements of the game have not yet been ported. Further, timing and game-play is still to be tuned.
