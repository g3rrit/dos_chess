  ;; gfx util functions

locals l_

vram = 0a000h

  ;; set video mode to 320 x 200 256 colors vga
  ;; uses { es, ax }
set_video_mode macro
  mov al, 13h
  mov ah, 0
  int 10h
endm

  ;; resets video mode
  ;; uses { ax }
reset_video_mode macro
  mov ax, 3
  int 10h
endm

  ;; draws a pixel at x y with color c
  ;; es needs to be set to vram bevorhand
  ;; uses { ax, bx, di }
draw_px macro x ,y, color
  mov ax, y
  mov bx, 320
  mul bx
  mov di, ax
  add di, x
  mov al, color
  mov es:[di], al
endm

  ;; draws a rectangle at x y with color c
  ;; args:
  ;; x | y | w | h | c
  ;; uses : { ax, bx, cx, di, es }
draw_rect proc near
  enter 0 ,0

  mov ax, vram
  mov es, ax

  ;; move to left top corner
  mov ax, [bp + 4 + 6]          ; y -> ax
  mov bx, 320
  mul bx
  mov di, ax
  add di, [bp + 4 + 8]          ; x + di
  mov al, [bp + 4]              ; c -> al
  mov cx, [bp + 4 + 4]          ; w -> cx
  dec cx

  cld
  rep
  stosb

  mov cx, [bp + 4 + 4]          ; w -> cx
  dec cx
  mov bx, [bp + 4 + 2]          ; h -> bx
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
  enter 0, 0

  mov ax, vram
  mov es, ax

  ;; move to left top corner
  mov ax, [bp + 4 + 8]          ; y -> ax
  mov bx, 320
  mul bx
  mov di, ax
  add di, [bp + 4 + 10]         ; x + di
  mov al, [bp + 4 + 2]          ; c -> al
  mov bx, [bp + 4 + 4]          ; h -> bx
  mov cx, [bp + 4 + 6]          ; w -> cx
  dec cx

l_draw_v:
  cld
  rep
  stosb

  add di, 320
  mov cx, [bp + 4 + 6]          ; w -> cx
  dec cx
  sub di, cx
  dec bx
  jnz l_draw_v

  push word ptr [bp + 4 + 10]
  push word ptr [bp + 4 + 8]
  push word ptr [bp + 4 + 6]
  push word ptr [bp + 4 + 4]
  push word ptr [bp + 4]

  call draw_rect

  leave
  ret
endp
