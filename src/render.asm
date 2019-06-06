  .model small
  .386

  .stack 100h

  .data

  .code

  include src\util.asm
  include src\gfxutil.asm

  public draw_rect
  public draw_filled_rect

  locals l_


  ;; draws the chessboard
draw_board proc near
  enter 0, 0

  mov ax, vram


  leave
  ret

  endp

  ;; draws a rectangle at x y with color c
  ;; args:
  ;; x | y | w | h | c
  ;; uses : { ax, bx, cx, di, es }
draw_rect proc near
x = [bp + 4 + 8]
y = [bp + 4 + 6]
w = [bp + 4 + 4]
h = [bp + 4 + 2]
c = [bp + 4]
  enter 0 ,0

  mov ax, vram
  mov es, ax

  ;; move to left top corner
  mov ax, y
  mov bx, 320
  mul bx
  mov di, ax
  add di, x
  mov al, c
  mov cx, w
  dec cx

  cld
  rep
  stosb

  mov cx, w
  dec cx
  mov bx, h
l_draw_v:
  mov es:[di], al
  sub di, cx
  mov es:[di], al
  add di, cx
  add di, 320

  dec bx
  jnz l_draw_v

  sub di, 320
  std
  rep
  stosb

  leave
  ret

  endp

  ;; draws filled rectangle at x y with color c and
  ;; border color cb
  ;; args:
  ;; x | y | w | h | c | cb
draw_filled_rect proc near
x = [bp + 4 + 10]
y = [bp + 4 + 8]
w = [bp + 4 + 6]
h = [bp + 4 + 4]
c = [bp + 4 + 2]
cb = [bp + 4]
  enter 0, 0

  mov ax, vram
  mov es, ax

  ;; move to left top corner
  mov ax, y
  mov bx, 320
  mul bx
  mov di, ax
  add di, x
  mov al, c
  mov bx, h
  mov cx, w
  dec cx

l_draw_v:
  cld
  rep
  stosb

  add di, 320
  mov cx, w
  dec cx
  sub di, cx
  dec bx
  jnz l_draw_v

  push word ptr x
  push word ptr y
  push word ptr w
  push word ptr h
  push word ptr cb

  call draw_rect
  pop_args 5

  leave
  ret

  endp

  end
