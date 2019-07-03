;;; This file is just used for testing

include std.asm

  public test_p

  extrn mouse_get_pos:proc
  extrn board_move:proc
  extrn draw_board:proc


  .data

  .code

test_p proc near

  call draw_board

  mov ah, 0
  int 16h

  mov ah, 077h
  mov al, 0

  push_args <ax>
  call board_move
  pop_args

  call draw_board

  mov ah, 0
  int 16h

  mov ah, 0
  int 16h


  endp

  end
