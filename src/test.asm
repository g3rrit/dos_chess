;;; This file is just used for testing

include std.asm

  public testp

  extrn mouse_pos:proc
  extrn mouse_board_pos:proc
  extrn board_move:proc
  extrn draw_board:proc
  extrn cboard_at:proc

  extrn set_flag0:proc

  extrn select_moves:proc

  extrn valid_moves:proc


  .data

  .code

testp proc near

  mov ah, 4
  mov al, 7

  mov bh, 0
  mov bl, 3
  call board_move

  call draw_board

  mov ah, 1
  mov al, 1
  mov bx, offset select_moves
  call valid_moves

  mov ah, 0
  mov al, 3
  mov bx, offset select_moves
  call valid_moves



  ;; call mouse_board_pos
  ;; call mouse_board_pos
  ;; call mouse_board_pos

  ret

  endp

  end
