# 3D Monster Maze for the Jupiter Ace (16k)/ Minstrel 4th

This is a port of the classic ZX81 game "3D Monster Maze" to the Jupiter Ace and Minstrel 4th.

The game was written by Malcolm Evans and published by J.K. Greye software in 1982. It was one of the first examples of a 3D arcade game for a home computer and was considered an amazing feat, given the limited capabilities of the humble ZX81 computer.

The Jupiter Ace had many similarities to the ZX81, built around the Z80 processor and with a simple, character-based display: but, whereas the ZX81 shipped with BASIC as its built-in language, the Jupiter Ace shipped with FORTH.

FORTH was chosen for the Jupiter Ace, because it produced lean and fast programs, allowing the user to write effective programs even within the constrained memory of the base model (3 kilobytes).

This port of 3D Monster Maze aims to exploit the capabilities of the Jupiter Ace's built-in FORTH interpetter, while reproducing the original game as accurately as possible, favouring FORTH over machine code whenever possible.

There are two version of the 3D-viewer code: one (almost) completely written in FORTH; and one part-ported to machine code for extra speed.

To switch between the two, edit the word PLAYMAZE, and replace the word DRAWVIEW (machine code) with DRAWVIEWF (FORTH version), or vice versa.

## Preview

The current version is  a technology preview. It is a candidate, complete game but needs a little tuning to get timing right. To play the game,

1. Open "3d_monster_maze.TAP" in your preferred emulator.
2. Enter `LOAD 3DMM` (case of filename is important).
3. Type `3DMM` (case does not matter).

You can move around the maze using `5` to turn left, `6` to move forward, and `8` to turn right.

## To-do List

Bugs and missing features that need attention:

- [x] Fix flickering status message
- [x] Fix late score update, when reaching the exit
- [x] Fix issue when can walk through Rex
- [x] Make timing more consistent, when approaching a dead-end
- [ ] Test Rex's movement pattern and speed
- [ ] Update keyboard options for List, Cont, Stop, etc.
- [ ] Reflow instruction text, to remove errors (inherited from ZX81 version)
- [ ] Create WAV file for use on real hardware
- [ ] Add option to exit game, if you get caught
- [ ] Test pure FORTH version
- [ ] Add testing for status-message code
- [ ] Fix Rex movement timing (four iters per move when player stationary)
- [ ] Improve maze view to include player location
- [ ] Add Rex's footprints and update maze map accordingly
