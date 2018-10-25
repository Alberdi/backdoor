
At the *Front Stage*, from the *Fateful Dream* Endless saga:
The *Outermaze* Book of Rhapsodies'

# BACKDOOR ROUTE

*Backdoor Route* is a card-collecting deck-building rogue-like cyberpunk
computer game developed in partnership with **project:v**. Abandoned in a
colossal planet-ship traveling across the rifts of the multiverse, the survivors
of a long-forgotten tragedy must venture through the ruins of a dead and
hopeless world in search of the Fruits of Vanth while drifting towards what they
believe to be their salvation. Play the role of one of these interdimensional
immigrants in a game that closely follows the format of classic rogue-likes save
for one particularity: your actions, your items, your skills, and even your
character progression are all represented by cards you assemble in decks while
you crawl, hack and slash your way through the world the Gods have left
behind.

## Running the project

### On Unix systems (Linux and MacOS)

Dependencies:

+ git
+ CMake
+ Make
+ löve
+ wget
+ luajit (dev package)

If all the above are properly installed, the command

```bash
$ make
```

Should be enough to download, setup, and run the game.

### On Windows (experimental)

Download:

+ [love 11.1 for windows 32bits](https://bitbucket.org/rude/love/downloads/love-11.1-win32.zip), and extract it somewhere easy to remember (this will be a copy specifically for Backdoor)
+ [imgui.dll](https://uspgamedev.org/downloads/libs/windows/x86/imgui.dll) into the love folder
+ [lua51.dll](https://uspgamedev.org/downloads/libs/windows/x86/imgui.dll) into the love folder (substitute if necessary)
+ [libs.zip](https://uspgamedev.org/downloads/projects/backdoor/libs.zip) and extract it on `game/libs/` on this repository

Then drag and drop the game folder over the LÖVE executable to run the game!

