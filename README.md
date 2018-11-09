TODO:
- ~~psrng (LFSR)~~
- ~~maze generation~~
- ~~sprite design~~
- audio
- multiple rooms

  (Technically) working but currently using TIMER2 instead of TIMER1. Need to figure out TIMER1 since the new in-game timer I added uses TIMER2. I think TIMER1 is a better fit for music anyway, it's just way more confusing. So more work needs to be done here. PLUS the music itself is still garbage but that is honestly something that can be done once we have a better idea of how much space we have left to use.

- ~~collision detection~~

  **a32_collision_test.asm:** Basic idea is done but could (possibly) use some refactoring.
  
- title screen
- end game screen
- ~~score~~

  Also (technically) working but the code does NOT account for the max score of 9900. BUT is this even necessary? That would mean collecting 99 letters... I really doubt (in the real game) that would happen. So I don't see a point adding this check if we just make sure it never happens! Is there a difference between just lazy coding and efficient coding? :P

- ~~timer~~

  **a34_end_game_condition.asm:** I think this is mostly done. Sprite code + timer code together along with the game ending (i.e. player is unable to move and timer stops) when time runs out. 

- flashlight effect - in progress

Maybes
- text box (e.g. 'You here some rustling')
- add slenderman

Possible Optimizations:
- use same add/subOffset macro/routines
- set 'blank' character to something NOT 0. Set PATH tile to 0 so that we can omit a
  cmp everytime player moves (not as simple as actually swapping the values. Some 
  debugging required) 