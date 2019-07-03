;;; This file contains the main loop and
;;; procedures for handling all the state
;;; of the game being:
;;;     choosing - the player is expected to left click the mouse on the board
;;;                to declare the piece he wants to move
;;;     selected - the player has selected a piece to move
;;;     ai       - the player has selected the destination of the piece and its the ais turn
;;;     done     - the game has concluded
;;;     end      - the game returns to main waiting for player to press any key to close the program
;;;


  include std.asm

  public main_loop

  .data

;;; the var holding the state
;;;  end (0) - choosing (1) - selected (2) - ai (3) - done (4)
game_state db 1

  .code


main_loop proc near
  entr 0

@@next_it:

  push_args<>
  cmp byte ptr [game_state], 0
  je @@end

  cmp byte ptr [game_state], 1
  je @@next_choosing
  cmp byte ptr [game_state], 2
  je @@next_selected
  cmp byte ptr [game_state], 3
  je @@next_ai
  cmp byte ptr [game_state], 4
  je @@next_done

;;; TODO: invalid state here exit with error

@@next_choosing:
  call choosing_state
  jmp @@next_state
@@next_selected:
  call selected_state
  jmp @@next_state
@@next_ai:
  call ai_state
  jmp @@next_state
@@next_done:
  call done_state


@@next_state:
  pop_args<>
  jmp @@next_it

@@end:
  pop_args<>

  leav
  ret
  endp

done_state proc near
  entr 0

  mov byte ptr [game_state], 0

  leav
  ret
  endp


choosing_state proc near
  entr 0

  leav
  ret
  endp

selected_state proc near
  entr 0

  leav
  ret
  endp

ai_state proc near
  entr 0


  leav
  ret
  endp


  end
