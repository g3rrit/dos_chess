  include std.asm

  public draw_rect
  public draw_filled_rect
  public draw_board

  extrn cboard
  extrn tile_draw:proc
  extrn cboard_for_each:proc

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

  ;; draws the chessboard
draw_board proc near
  entr 0

  disable_cursor

  ;; draw board
  mov cx, board_xpos
  mov dx, board_ypos

  mov bx, 8
@@draw_square:
  save_reg
  push_args <bx, cx, dx>
  call tile_draw
  pop_args
  res_reg

  switch_color

  add cx, tile_size
  cmp cx, board_xpos + tile_size * 8
  je @@next_line
  jmp @@draw_square

@@next_line:
  mov cx, board_xpos
  add dx, tile_size

  switch_color

  cmp dx, board_ypos + tile_size * 8
  jne @@draw_square

  ;; --------

@@draw_pieces:

  save_reg
  push_args <offset draw_pieces>
  call cboard_for_each
  pop_args
  res_reg

  enable_cursor

  leav
  ret
  endp

;;; --   DRAW_PIECE_PROC -----------------

;;; args:
;;;  - piece x y
draw_pieces proc near
  entr 0

piece = bp + 6 + 4
xpos = bp + 6 + 2
ypos = bp + 6

  cmp word ptr [piece], 0
  je @@empty

  mov cx, word ptr [xpos]

  mov ax, cx
  mov cx, 20
  mul cx
  mov cx, ax
  add cx, 82

  mov dx, word ptr [ypos]

  mov ax, dx
  mov dx, 20
  mul dx
  mov dx, ax
  add dx, 22

  mov ax, word ptr [piece]

  save_reg
  push_args <ax, cx, dx>
  call tile_draw
  pop_args
  res_reg

@@empty:

  leav
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
