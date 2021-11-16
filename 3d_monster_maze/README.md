# 3D Monster Maze for the Jupiter Ace (16k)/ Minstrel 4th

This is a port of the classic ZX81 game "3D Monster Maze" to the Jupiter Ace and Minstrel 4th.

The game was written by Malcolm Evans and published by J.K. Greye software in 1982. It was one of the first examples of a 3D arcade game for a home computer and was considered an amazing feat, given the limited capabilities of the humble ZX81 computer.

The Jupiter Ace had many similarities to the ZX81, built around the Z80 processor and with a simple, character-based display: but, whereas the ZX81 shipped with BASIC as its built-in language, the Jupiter Ace shipped with FORTH.

FORTH was chosen for the Jupiter Ace, because it produced lean and fast programs, allowing the user to write effective programs even within the constrained memory of the base model (3 kilobytes).

This port of 3D Monster Maze aims to exploit the capabilities of the Jupiter Ace's built-in FORTH interpetter, while reproducing the original game as accurately as possible, favouring FORTH over machine code whenever possible.

There are two version of the 3D-viewer code: one (almost) completely written in FORTH; and one part-ported to machine code for extra speed.

To switch between the two, edit the word TEST, and replace the word DRAWVIEW (machine code) with DRAWVIEWF (FORTH version), or vice versa.

## Preview

You can run the in-progress implementation, using the following steps:

1. Open "3d_monster_maze.TAP" in your preferred emulator.
2. Enter `LOAD 3DMM`.
3. Set up UDGs with `SETUPUDG`.
4. Set up maze with `CLEARMAZE`, `CREATEMAZE`, `MAKEEXIT`, `PLACEREX`. Note that the create-maze step takes around 15 seconds to complete.
5. Optionally, view maze with `CLS`, `PRINTMAZE`.
6. Start demo with `TEST`.
7. You can move around the maze using `5` to turn left, `6` to move forward, and `8` to turn right.

You can break out of the demo, using `Shift-SPACE`.

This is an in-progress project, so some elements of the game have not yet been ported. Further, timing and game-play is still to be tuned. However, a first version of the exit animation has been implemented (though reaching the exit does not end the game) and Rex is present in the maze (though does not move nor catch you).

## To-do List

In simple terms:

- Movement of Rex
- Test for being caught by Rex
- Test for reaching the exit (win the game)
- Scoring
- Opening screen and instructions
