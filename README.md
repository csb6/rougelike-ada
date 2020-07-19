# Rougelike-Ada

A rougelike game written in Ada.

## Installation

### Prerequisites

You must have the
[AdaCore GNAT Community Edition](https://www.adacore.com/download)
installed, which includes a version of the GCC compiler with support
for Ada, as well as the `gprbuild` tool needed to build the game.

### Building

When you first clone the repo, run `./build-initial.sh`. This will
build the Ada ncurses bindings found in the `AdaCurses/` subdirectory.

There may be an error shown at the end of the build process, but as long
as `AdaCurses/lib/libAdaCurses.a` (or whatever the library file format of
your OS is) exists, then you are good. The ncurses build process seems to
incorrectly build some of the sample files, but the library code that the
rougelike game (located in `src/`) relies on should build fine.

To build the game code, simply run `gprbuild` in the repo's root directory.
An executable named `rougelike` should be produced in the `obj/` directory.

## Running

Simply run `obj/rougelike` in your terminal.
