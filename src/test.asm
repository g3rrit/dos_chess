;;; This file is just used for testing

include std.asm

  public testp

  extrn mouse_pos:proc
  extrn mouse_board_pos:proc
  extrn board_move:proc
  extrn draw_board:proc
  extrn cboard_at:proc


  .data

  .code

testp proc near

  mov ax, 0
  mov bh, 1
  mov bl, 1
  call board_move

  call draw_board

  ;; call mouse_board_pos
  ;; call mouse_board_pos
  ;; call mouse_board_pos

  ret

  endp

  end
