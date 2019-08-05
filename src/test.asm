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

  mov ah, 2
  mov al, 7

  mov bh, 3
  mov bl, 3
  call board_move

  call draw_board

  mov ah, 3
  mov al, 3
  call valid_moves

  ;; call mouse_board_pos
  ;; call mouse_board_pos
  ;; call mouse_board_pos

  ret

  endp

  end
