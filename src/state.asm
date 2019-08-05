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
  include boardm.asm

  public main_loop

  extrn mouse_board_pos:proc
  extrn board_at:proc
  extrn board_move:proc
  extrn draw_board:proc

  extrn set_player_white:proc
  extrn set_player_black:proc

  extrn clear_selected:proc

  extrn valid_moves:proc

  .data

;;; the var holding the state
;;;  end (0) - choosing_white (1) - selected_white (2) - choosing_black (3) - selected_black (4) - done (5)
game_state db 1


selected_xpos db 0
selected_ypos db 0

  .code


main_loop proc near
  entr 0

@@next_it:

  cmp byte ptr [game_state], 0
  je @@end

  cmp byte ptr [game_state], 1
  je @@next_choosing_white
  cmp byte ptr [game_state], 2
  je @@next_selected_white
  cmp byte ptr [game_state], 3
  je @@next_choosing_black
  cmp byte ptr [game_state], 4
  je @@next_selected_black
  cmp byte ptr [game_state], 5
  je @@next_done


;;; TODO: invalid state here exit with error

@@next_choosing_white:
  call choosing_state_white
  jmp @@next_state
@@next_selected_white:
  call selected_state_white
  jmp @@next_state
@@next_choosing_black:
  call choosing_state_black
  jmp @@next_state
@@next_selected_black:
  call selected_state_black
  jmp @@next_state
@@next_done:
  call done_state


@@next_state:
  call draw_board

  jmp @@next_it

@@end:

  leav
  ret
  endp

done_state proc near
  entr 0

  mov byte ptr [game_state], 0

  leav
  ret
  endp


;;; selects piece whiteat ax
select_white proc near
  ;; set next state
  mov byte ptr [game_state], 2

  ;; set possible moves on board
  call clear_selected
  call valid_moves

  ;; set selected pos
  mov byte ptr [selected_xpos], ah
  mov byte ptr [selected_ypos], al

  ret
  endp

;;; selects piece black at ax
select_black proc near
  ;; set next state
  mov byte ptr [game_state], 4

  ;; set possible moves on board
  call clear_selected
  call valid_moves

  ;; set selected pos
  mov byte ptr [selected_xpos], ah
  mov byte ptr [selected_ypos], al

  ret
  endp

choosing_state_white proc near
  entr 0

  ;; ah - xpos (0-7) | bl - ypos (0-7)
  ;; dx - 1 valid | 0 invalid
  call mouse_board_pos
  cmp dx, 1
  jne @@done

  ;; check if selected piece is white
  push ax
  call board_at

  ;; if first bit is set piece is black
  cmp al, 8
  jnc @@done
  cmp al, 0
  je @@done

  pop ax
  call select_white
@@done:
  leav
  ret
  endp

selected_state_white proc near
  entr 0

  ;; ah - xpos (0-7) | al - ypos (0-7)
  ;; dx - 1 valid | 0 invalid
  call mouse_board_pos
  cmp dx, 1
  jne @@done

  push ax
  call board_at
  ;; check if move is possible
  cmp ah, 1
  je @@move_possible

  ;; move not possible
  cmp al, 0
  je @@reset

  ;; if first bit is set piece is black
  cmp al, 8
  jnc @@reset

  pop ax
  call select_white
  jmp @@done

@@reset:
  mov byte ptr [game_state], 1
  call clear_selected
  pop ax
  jmp @@done

@@move_possible:
  pop ax
  mov bx, ax

  mov ah, byte ptr [selected_xpos]
  mov al, byte ptr [selected_ypos]

  ;; check if black king is checkmate

  call board_move

  ;; change state selecting black
  mov byte ptr [game_state], 3

  ;; set current player on board
  call set_player_black

  ;; clear board selection
  call clear_selected

@@done:
  leav
  ret
  endp

choosing_state_black proc near
  entr 0

  ;; ah - xpos (0-7) | bl - ypos (0-7)
  ;; dx - 1 valid | 0 invalid
  call mouse_board_pos
  cmp dx, 1
  jne @@done

  ;; check if selected piece is black
  push ax
  call board_at

  ;; if first bit is set piece is black
  cmp al, 8
  jc @@done
  cmp al, 0
  je @@done

  pop ax
  call select_black
@@done:
  leav
  ret
  endp

selected_state_black proc near
  entr 0

  ;; ah - xpos (0-7) | al - ypos (0-7)
  ;; dx - 1 valid | 0 invalid
  call mouse_board_pos
  cmp dx, 1
  jne @@done

  push ax
  call board_at
  ;; check if move is possible
  cmp ah, 1
  je @@move_possible

  ;; move not possible
  cmp al, 0
  je @@reset

  ;; if first bit is set piece is black
  cmp al, 8
  jc @@reset

  pop ax
  call select_black
  jmp @@done

@@reset:
  mov byte ptr [game_state], 3
  call clear_selected
  pop ax
  jmp @@done

@@move_possible:
  pop ax
  mov bx, ax

  mov ah, byte ptr [selected_xpos]
  mov al, byte ptr [selected_ypos]

  ;; check if white king is checkmate

  call board_move

  ;; change state selecting white
  mov byte ptr [game_state], 1

  ;; set current player on board
  call set_player_white

  ;; clear board selection
  call clear_selected

@@done:
  leav
  ret
  endp

  end
