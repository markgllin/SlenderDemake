TODO:
- ~~psrng (LFSR)~~
- maze generation - so many bugs ):
- ~~sprite design~~
- audio

  (Technically) working but currently using TIMER2 instead of TIMER1. Need to figure out TIMER1 since the new in-game timer I added uses TIMER2. I think TIMER1 is a better fit for music anyway, it's just way more confusing. So more work needs to be done here. PLUS the music itself is still garbage but that is honestly something that can be done once we have a better idea of how much space we have left to use.

- ~~collision detection~~

  **a32_collision_test.asm:** Basic idea is done but could (possibly) use some refactoring.
  
- title screen
- end game screen
- score
- ~~timer~~

  **a34_end_game_condition.asm:** I think this is mostly done. Sprite code + timer code together along with the game ending (i.e. player is unable to move and timer stops) when time runs out. 


Maybes
- text box (e.g. 'You here some rustling')
- add slenderman
