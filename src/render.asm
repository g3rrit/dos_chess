include std.asm
include tilem.asm
include boardm.asm

  public draw_rect
  public draw_filled_rect
  public draw_board
  public draw_exit_button

  extrn tile_draw:proc

  extrn board_at_pos:proc
  extrn get_player:proc

  .data

  .code

draw_exit_button proc
  entr 0

  disable_cursor

  push_args<tile_exit, 0, 0>
  call tile_draw
  pop_args

  enable_cursor

  leav
  ret
  endp

color_black = 0ffh
color_white = 0

draw_white_box macro x, y, w, h
  save_reg
  push_args<x, y, w, h, color_black, color_white>
  call draw_filled_rect
  pop_args
  res_reg
  endm

draw_black_box macro x, y, w, h
  save_reg
  push_args<x, y, w, h, color_white, color_black>
  call draw_filled_rect
  pop_args
  res_reg
  endm


;;; draw the chessboard
draw_board proc near
  entr 0

  disable_cursor

  ;; draw player indicator
  call get_player
  cmp ax, 0
  jne @@player_black

@@player_white:
  draw_white_box board_xpos, <board_ypos - 10>, board_width, 10
  draw_white_box board_xpos, <board_ypos + board_height>, board_width, 10
  draw_white_box <board_xpos - 10>, board_ypos, 10, board_height
  draw_white_box <board_xpos + board_width>, board_ypos, 10, board_height
  draw_white_box <board_xpos - 10>, <board_ypos - 10>, 10, 10
  draw_white_box <board_xpos + board_width>, <board_ypos - 10>, 10, 10
  draw_white_box <board_xpos - 10>, <board_ypos + board_height>, 10, 10
  draw_white_box <board_xpos + board_width>, <board_ypos + board_height>, 10, 10

  jmp @@done_player
@@player_black:
  draw_black_box board_xpos, <board_ypos - 10>, board_width, 10
  draw_black_box board_xpos, <board_ypos + board_height>, board_width, 10
  draw_black_box <board_xpos - 10>, board_ypos, 10, board_height
  draw_black_box <board_xpos + board_width>, board_ypos, 10, board_height
  draw_black_box <board_xpos - 10>, <board_ypos - 10>, 10, 10
  draw_black_box <board_xpos + board_width>, <board_ypos - 10>, 10, 10
  draw_black_box <board_xpos - 10>, <board_ypos + board_height>, 10, 10
  draw_black_box <board_xpos + board_width>, <board_ypos + board_height>, 10, 10

@@done_player:
  ;; ------------

  ;; draw board
  mov cx, board_xpos
  mov dx, board_ypos

  mov bx, 0
  ;; draw black
@@draw_black:

  mov ax, bx
  call board_at_pos

  cmp ax, 0ffffh
  je @@done

  push bx
  mov bx, 1

  call draw_piece

  pop bx

  ;; inc and check for next line
  inc bx
  add cx, tile_size
  cmp cx, board_xpos + tile_size * 8
  je @@next_line_black
  jmp @@draw_white

@@next_line_black:
  mov cx, board_xpos
  add dx, tile_size

  cmp dx, board_ypos + tile_size * 8
  je @@done
  jmp @@draw_black


  ;; draw white
@@draw_white:

  mov ax, bx
  call board_at_pos

  cmp ax, 0ffffh
  je @@done

  push bx
  mov bx, 0

  call draw_piece

  pop bx

  ;; inc and check for next line
  inc bx
  add cx, tile_size
  cmp cx, board_xpos + tile_size * 8
  jne @@draw_black

  mov cx, board_xpos
  add dx, tile_size

  cmp dx, board_ypos + tile_size * 8
  jne @@draw_white


  ;; --------
@@done:

  enable_cursor

  leav
  ret
  endp

draw_piece proc near
  push ax

  cmp bx, 0
  je @@black_sq

  ;; white square
  cmp ah, board_flag0
  je @@white_sel

  mov ax, tile_empty_w
  jmp @@done_sq

@@white_sel:
  mov ax, tile_empty_ws
  jmp @@done_sq

  ;; black square
@@black_sq:

  cmp ah, board_flag0
  je @@black_sel

  mov ax, tile_empty_b
  jmp @@done_sq

@@black_sel:
  mov ax, tile_empty_bs

  ;; -----
@@done_sq:
  push_args<ax, cx, dx>
  call tile_draw
  pop_args

  pop ax

  cmp al, 0
  je @@done

  xor ah, ah
  add cx, 2
  add dx, 2
  push_args<ax, cx, dx>
  call tile_draw
  pop_args
  sub cx, 2
  sub dx, 2

@@done:

  ret
  endp

;;; --  ----------------------------------

  ;; draws a rectangle at x y with color c
  ;; args:
  ;; x | y | w | h | c
  ;; uses : { ax, bx, cx, di, es }
draw_rect proc near
  entr 0

x = bp + 6 + 8
y = bp + 6 + 6
w = bp + 6 + 4
h = bp + 6 + 2
c = bp + 6

  mov ax, vram
  mov es, ax

  ;; move to left top corner
  mov ax, word ptr [y]
  mov bx, 320
  mul bx
  mov di, ax
  add di, word ptr [x]
  mov ax, word ptr [c]
  mov cx, word ptr [w]
  dec cx

  cld
  rep
  stosb

  mov cx, word ptr [w]
  dec cx
  mov bx, word ptr [h]
@@draw_v:
  mov es:[di], al
  sub di, cx
  mov es:[di], al
  add di, cx
  add di, 320

  dec bx
  jnz @@draw_v

  sub di, 320
  std
  rep
  stosb

  leav
  ret
  endp

  ;; draws filled rectangle at x y with color c and
  ;; border color cb
  ;; args:
  ;; x | y | w | h | c | cb
draw_filled_rect proc near
  entr 0

x = bp + 6 + 10
y = bp + 6 + 8
w = bp + 6 + 6
h = bp + 6 + 4
c = bp + 6 + 2
cb = bp + 6

  ;; move to left top corner
  mov ax, word ptr [y]
  mov bx, 320
  mul bx
  mov di, ax
  add di, word ptr [x]
  mov ax, word ptr [c]
  mov bx, word ptr [h]
  mov cx, word ptr [w]
  dec cx

@@draw_v:
  cld
  rep
  stosb

  add di, 320
  mov cx, word ptr [w]
  dec cx
  sub di, cx
  dec bx
  jnz @@draw_v

  push_args<word ptr [x], word ptr [y], word ptr [w], word ptr [h], word ptr [cb]>
  call draw_rect
  pop_args

  leav
  ret
  endp


  end
