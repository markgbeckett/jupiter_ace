# A-Mouz-in-Mase

## Background

In May 2021, the curator of the [Jupiter Ace Archive](https://www.jupiter-ace.co.uk/) posted a [message on Twitter](https://twitter.com/JA_Archive/status/1399479238328295424), asking for help to recover one of a small number of games that he had recently recovered from cassette. The game in question was known simply as MAZE and, as the name suggests, was supposed to be some kind of maze game. Two versions were available: the raw, recovered program, which had various corruption; and a partially recovered version, in which all but a word named SCAN seemed to be okay.

I decided to have a go at recovering the game, and to see if I could find out more about it.

I downloaded both versions, though was initially unable to load the part-recovered version, so started from the original.

The good news was that the original _rip_ of the cassette loaded and could be run. It opened with a screen of instructions (which also confirmed the game name to be _A-Mouz-in-Mase_ (sic.), before asking you to choose a maze size, and then starting to build a maze. Unfortunately, shortly after starting the maze-build, the program crashed, resetting the Ace.

![](maze_instructions.png "Instructions Screen")

The source code had no information on the origins of the game: who wrote it, who published it, and when it was written. I still have not found any of this information, so would be happy to hear from anyone who knows more.

## Recovery Process

The game is encapsulated in a top-level word called RUN, which runs through the following steps, each time the game is played:

1. Print instructions
2. Ask user to choose maze size
3. Generate maze
4. Solve maze automatically or let user solve maze

I decided to work through each stage, in turn, attempting to repair any corrupted code and restore the intended functionality.

Steps 1 and 2 are very straightforward, with little corruption, so I quickly moved to tackle the maze-generation code. The first part of the setup is a word called CLEAR, which sets up an empty maze in memory, ready to be generated. The game supports three maze sizes, made up of 1x1 (small), 2x2 (medium), or 3x3 (large) maze _sections_, with each maze section being 31x20 cells in size. Although each section is 31x20 in size, it is held in a 32x21-byte section of memory, to accommodate the righthand and bottom boundaries, which are outside of the maze (as will be explained later).

The maze information is held in two data structures. One structure holds the screen content for each section of the maze, so it can be rapidly printed (by copying it into the display memory). The other structure stores the connectivity of the maze, again in sections, along with some state information used during maze generation and when automatically solving the maze. The maze state is based on bit logic, with the following roles assigned to individual bits:

* Bit 0 -- set, if can move right from cell, reset otherwise
* Bit 1 -- set, if can move left from cell, reset otherwise
* Bit 2 -- set, if can move up from cell, reset otherwise
* Bit 3 -- set, if can move down from cell, reset otherwise
* Bit 4 -- set, if already visited when auto-solving maze
* Bit 5 -- apparently, not used
* Bit 6 -- apparently, not used
* Bit 7 -- set, if already visited during maze generation.

I noted that Bits 5 and 6 are apparently not used, as they would be ideal candidates to work around one of the corruptions I discovered in the game.

The screen sections contain 32x21 arrays of character bytes, which correspond to characters 1 through 12, which are organised into three sets of four. Characters 1, 2, 3, and 4 contain graphics for walls on top and left, wall on top, wall on left, and top-left corner only. To box in a particular cell, then the actual cell needs to have top and left walls, the cell immediately to the right needs to have, at least, the left wall set, and the cell immediately below needs to have, at least, the top wall set, and the cell down and to the right needs to have at least the top-left corner set. This is why it takes 32x21 characters to store a 31x20 maze: the final column contains mostly 3s, the final row contains mostly 2s, and the bottom right corner contains 4.

If that seems confusing take a look at an example screenshots of a maze section. This section shows the top-left 4x3 section of a maze, with the corresponding character codes in yellow. The top left cell has both the top and left wall filled in, so is represented by character 1. The cell to the right of that has just the top wall filled in so is represented by a 2 (remember the bottom wall comes from the cell below). The first cell on the second row has a left wall and right, so will be represented by character 3 with character 1 to the right of it (to fill in the right wall). Hopefully that makes sense.

![](maze_section.png "Displaying the maze")

Characters 5,...8 and characters 9,...,12 contain the same wall sections, but also have either a large square or a small square in the middle of the cell. These are used to indicate, the current location, a cell on the solution, or a cell that has been visited but discounted from the solution. Look at the completed maze puzzle and see how the correct path is highlighted with large squares whereas wrong turns that needed to be backtracked are shown with small squares. The entrance to the maze is near the top-right corner and the exit is near the bottom-left corner.

![](maze_solution.png "The solution and wrong turns")

## Status

The program has now been recovered and, to the best of my knowledge, works are the author intended. I have anotated the [source code](maze.fs) for anyone who is interested to delve into the working of the game.

Studying the code has highlighted a few potential improvements, for future work:

* The game tends to produce the same mazes each time, as the random-number seed is initialised to a constant value. This could be easily addressed by, for example, initialising the seed using the low work of the internal clock.
* When the auto-solver completes, the game immediately returns to the main menu, which means you do not get a chance to study the solution. There is a loop in the code, which looks like a wait loop, though the duration of the wait is very short and could be extended.
* The game does not check availability of memory, but just assumes there is enough space between the end of the dictionary and the start of the return stack. With a 16 kilobyte RAM pack (that is, 19kb of RAM), there is not enough spare memory for the largest maze size. Attempting to generate the largest maze will cause the computer to crash.
* The game holds two copies of the maze in memory (along with the active maze segment in the display area). For the largest maze, this requires 2*3*3*32*21 = 12,096 bytes. It should be possible to reduce this by half, investing more time into displaying the active maze segment. However, this would slow-down redrawing the on-screen maze segment, though this might be okay, and could enable even bigger mazes to be supported.
