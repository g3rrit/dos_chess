  include std.asm

  public draw_rect
  public draw_filled_rect
  public draw_board

  extrn board
  extrn tile_draw:proc

  .data

  .code

switch_color macro
  local nblack, conn
  ;; set white or black
  cmp bx, 13
  jne nblack
  ;; else
  mov bx, 12
  jmp conn
nblack:
  mov bx, 13
conn:
  endm

  ;; draws the chessboard
draw_board proc near
  entr 0

  ;; draw board
  mov cx, 80
  mov dx, 20

  mov bx, 13
@@draw_square:
  push_args <bx, cx, dx>
  call tile_draw
  pop_args

  switch_color

  add cx, 20
  cmp cx, 80 + 20 * 8
  je @@next_line
  jmp @@draw_square

@@next_line:
  mov cx, 80
  add dx, 20

  switch_color

  cmp dx, 20 + 20 * 8
  jne @@draw_square

  ;; --------

@@draw_pieces:

  leav
  ret
  endp

;;; --   DRAW_PIECE_PROC -----------------
;;; converts a position in to form from 0 - 63
;;; to a representation in x y coordinates
convert_pos_to_coord macro


  endm

draw_empty proc near


  ret
  endp

draw_piece proc near

  push_args <offset draw_empty>

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
