TODO:
- ~~psrng (LFSR)~~
- ~~maze generation~~
- ~~sprite design~~
- ~~audio~~
- ~~multiple rooms~~

- ~~collision detection~~
- ~~title screen~~
- end game screen - doneish but I want it to be BETTER, plus "you win" condition is wrong
- ~~score~~
- ~~timer~~
- ~~flashlight effect~~
- ~~sprite animations~~

FIXES:
- ~~fix timer + score after changing rooms (i.e. fix clear screen subroutine)~~
- ~~fix letter generation/placement + remember if letter has been found in a room~~ DONE :)
- OPTIMIZE, OPTIMIZE, OPTIMIZE

Maybes
- ~~remember if a room has been visited~~
- text box (e.g. 'You here some rustling')
- add slenderman
- cheat codes
  - code that will show the maze
  - code that will teleport player to the letter
  - etc.

Possible Optimizations:
- use same add/subOffset macro/routines
- set 'blank' character to something NOT 0. Set PATH tile to 0 so that we can omit a cmp everytime player moves (not as simple as actually swapping the values. Some 
  debugging required) 
- i think...we can modify the sub/addoffset subroutines to use indirect indexing and get rid of the garbage math w/ updating lsb and msb's separately...dont fix what's not broken though ¯\_(ツ)_/¯. will deal with it when i have time
