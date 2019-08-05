  include std.asm

  public draw_rect
  public draw_filled_rect
  public draw_board

  extrn tile_draw:proc

  extrn board_at_pos:proc

  .data

  .code

switch_color macro
  local nblack, conn
  ;; set white or black
  cmp bx, 8
  jne nblack
  ;; else
  mov bx, 7
  jmp conn
nblack:
  mov bx, 8
conn:
  endm

;;; draw the chessboard
draw_board proc near
  entr 0

  disable_cursor

  ;; draw board
  mov cx, board_xpos
  mov dx, board_ypos

  mov bx, 0
  ;; draw black
@@draw_black:

  mov ax, 7
  push_args<ax, cx, dx>
  call tile_draw
  pop_args

  mov ax, bx
  call board_at_pos

  cmp ax, 0ffffh
  je @@done

  ;; check for marking in ah

  xor ah, ah
  add cx, 2
  add dx, 2
  call draw_piece
  sub cx, 2
  sub dx, 2

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

  mov ax, 8
  push_args<ax, cx, dx>
  call tile_draw
  pop_args

  mov ax, bx
  call board_at_pos

  cmp ax, 0ffffh
  je @@done

  xor ah, ah
  add cx, 2
  add dx, 2
  call draw_piece
  sub cx, 2
  sub dx, 2

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

  push_args<ax, cx, dx>
  call tile_draw
  pop_args

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

  mov ax, vram
  mov es, ax

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

  push word ptr [x]
  push word ptr [y]
  push word ptr [w]
  push word ptr [h]
  push word ptr [cb]

  call draw_rect
  pop_args 5

  leav
  ret
  endp

  end
