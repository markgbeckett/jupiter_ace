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
- [x] Improve maze view to include player location
- [ ] Optimise `PRINTMAZE` routine 
- [ ] Add Rex's footprints and update maze map accordingly

## Background

I had two motives for porting 3D Monster Maze to the Minstrel 4th (and Jupiter Ace). First, I wanted to contribute to the small but growing range of new software available for the machine(s). Second, I wanted to further understand the scope for using Forth as a production programming language (avoiding the need to write in machine code).

The Minstrel 4th version is ported directly from the ZX81 version and this has been significantly aided by Paul Farrow's [commented disassembly of the original game](http://www.fruitcake.plus.com/Sinclair/ZX81/Disassemblies/MonsterMaze.htm) and by the [description of the game mechanics](https://softtangouk.wixsite.com/soft-tango-uk/3d-monster-maze) by Soft Tango UK.

Having spent some time studying the sources above and playing the original ZX81 game, I decided to tackle the port in eight stages:

1. Maze generation
2. 3D renderer
3. Player movement
4. Exit rendering
5. Rex's rendering
6. Rex's movement
7. Scoring and game loop
8. Introduction and instructions

My original aim was to write the port entirely in Forth though, as you will read, I subsequently decided to rewrite the 3D renderer in machine code.

Maze generation was relatively straightforward to port, following the same approach as taken in the ZX81 version. The maze is held in a block of memory referenced by the word MAZE. In this version, the maze size is (sort of) configurable. The height and width are stored in two constants `MAZEH` and `MAZEW`, which are then referenced throughout the program. To change the maze size is should be enough to redefine these constants and then recreate the buffer used to hold the maze. However, there are some machine code routines that sit above the maze in the dictionary and the calls into some of these routines need to be updated as well.

The code to generate a maze is held in words `CLEARMAZE`, `CREATEMAZE`, `MAKEEXIT`, and `PLACEREX`. The procedure should be relatively clear, if read in conjunction with Soft Tango UK's description.

Having addressed maze generation, I moved on to the 3D renderer, which gives the player's view of the maze during gameplay. Here I took a different approach to the ZX81 version, which looks to be over-complicated. As Soft Tango UK notes, it looks as if the original plan was to support a more flexible maze design with a possibility of corridors wider than one cell. Because of this, there is some unnecessary complexity in the ZX81 version.

Given that I wanted to create a 3D renderer in Forth, I decided to start from scratch, focusing on speed and efficiency. 

To be continued ...
