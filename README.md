TODO:
- ~~psrng (LFSR)~~
- ~~maze generation~~
- ~~sprite design~~
- ~~audio~~

  Besides making a song that actually sounds good, this is done.
  That is honestly a pretty minor detail though; more just annoying work than an actual hard thing. 
  Once game is closer to being "done" we can focus on this.
  
- multiple rooms - in progress

- ~~collision detection~~
- ~~title screen~~
- end game screen - in progress along with optimization
- ~~score~~

  Also (technically) working but the code does NOT account for the max score of 9900. BUT is this even necessary? That would mean collecting 99 letters... I really doubt (in the real game) that would happen. So I don't see a point adding this check if we just make sure it never happens! Is there a difference between just lazy coding and efficient coding? :P

- ~~timer~~
- ~~flashlight effect~~
- ~~sprite animations~~

FIXES:
- fix timer + score after changing rooms (i.e. fix clear screen subroutine)
- fix letter generation/placement + remember if letter has been found in a room 
- OPTIMIZE, OPTIMIZE, OPTIMIZE

Maybes
- remember if a room has been visited
- text box (e.g. 'You here some rustling')
- add slenderman
- cheat codes
  - code that will show the maze
  - code that will teleport player to the letter
  - etc.

Possible Optimizations:
- use same add/subOffset macro/routines
- set 'blank' character to something NOT 0. Set PATH tile to 0 so that we can omit a
  cmp everytime player moves (not as simple as actually swapping the values. Some 
  debugging required) 
- do we really need a `SPRITE_LSB/MSB` and `SPRITE_CLR_LSB/MSB`? as far I can tell, they're always equivalent?
- i think...we can modify the sub/addoffset subroutines to use indirect indexing and get rid of the garbage math w/ updating lsb and msb's separately...dont fix what's not broken though ¯\_(ツ)_/¯. will deal with it when i have time
