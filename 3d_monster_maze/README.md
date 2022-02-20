# 3D Monster Maze for the Jupiter Ace (16k)/ Minstrel 4th

This is a port of the classic ZX81 game "3D Monster Maze" to the Jupiter Ace and Minstrel 4th.

The game was written by Malcolm Evans and published by J.K. Greye software in 1982. It was one of the first examples of a 3D arcade game for a home computer and was considered an amazing feat, given the limited capabilities of the humble ZX81 computer.

The Jupiter Ace had many similarities to the ZX81, built around the Z80 processor and with a simple, character-based display: but, whereas the ZX81 shipped with BASIC as its built-in language, the Jupiter Ace shipped with FORTH.

FORTH was chosen for the Jupiter Ace, because it produced lean and fast programs, allowing the user to write effective programs even within the constrained memory of the base model (3 kilobytes).

This port of 3D Monster Maze aims to exploit the capabilities of the Jupiter Ace's built-in FORTH interpetter, while reproducing the original game as accurately as possible, favouring FORTH over machine code whenever possible.

There are two version of the 3D-viewer code: one (almost) completely written in FORTH; and one part-ported to machine code for extra speed.

To switch between the two, edit the word PLAYMAZE, and replace the word DRAWVIEW (machine code) with DRAWVIEWF (FORTH version), or vice versa.

## Playing the Game

To play the game in an emulator:

1. Open "3d_monster_maze.TAP" in your preferred emulator.
2. Enter `LOAD 3DMM` (case of filename is important).
3. Type `3DMM` (case does not matter).

To play the game on a Jupiter Ace (with 16KB RAM pack) or a Minstrel 4th:

1. Connect the audio output from your PC to the Ear socket on your Ace/ Minstrel 4th using a suitable audio lead.

2. Open "3d_monster_maze.WAV" in your preferred media player.

3. Enter `LOAD 3DMM` (case of filename is important) on you Ace/ Minstrel 4th.

3. Start audio playback on the PC (with volume set to loud). The game takes around 90 seconds to load and success is confirmed with an OK prompt.

4. Type `3DMM` (case does not matter).

Loading games into a real Ace/ Minstrel 4th may require a little trial and error to get the volume correct.

Instructions are included in the game. The aim of the game is to find the exit from the maze before Rex catches you. You can move around the maze using `5` to turn left, `6` to move forward, and `8` to turn right.

## To-do List

Bugs and missing features that need attention:

- [x] Fix flickering status message
- [x] Fix late score update, when reaching the exit
- [x] Fix issue when can walk through Rex
- [x] Make timing more consistent, when approaching a dead-end
- [x] Test Rex's movement pattern and speed
- [x] Update keyboard options for List, Cont, Stop, etc.
- [x] Reflow instruction text, to remove errors (inherited from ZX81 version)
- [x] Create WAV file for use on real hardware
- [x] Add option to exit game, if you get caught
- [ ] Test pure FORTH version
- [x] Add testing for status-message code
- [ ] Fix Rex movement timing (four iters per move when player stationary)
- [ ] Improve maze view to include player location
- [ ] Add Rex's footprints and update maze map accordingly
