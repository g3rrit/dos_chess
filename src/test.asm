;;; This file is just used for testing

include std.asm

  public testp

  extrn mouse_pos:proc
  extrn mouse_board_pos:proc
  extrn cboard_move:proc
  extrn draw_board:proc
  extrn cboard_at:proc


  .data

  .code

testp proc near

  mov ax, 01644h
  push_args<ax>
  call cboard_move
  pop_args

  call draw_board

  ;; call mouse_board_pos
  ;; call mouse_board_pos
  ;; call mouse_board_pos

  call draw_board

  mov ah, 0
  int 16h

  mov ah, 077h
  mov al, 0

  push_args <ax>
  call cboard_move
  pop_args

  call draw_board

  mov ah, 0
  int 16h

  mov ah, 0
  int 16h

  ret

  endp

  end
