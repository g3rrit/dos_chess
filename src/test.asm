;;; This file is just used for testing

include std.asm

  public testp

  extrn mouse_pos:proc
  extrn mouse_board_pos:proc
  extrn board_move:proc
  extrn draw_board:proc
  extrn cboard_at:proc

  extrn valid_moves:proc


  .data

  .code

testp proc near

  mov ah, 1
  mov al, 1
  call valid_moves

  ;; call mouse_board_pos
  ;; call mouse_board_pos
  ;; call mouse_board_pos

  ret

  endp

  end
