  include std.asm

  public tileset_load
  public tile_draw

  extrn error:proc

  .data

tileset_width = 96
tileset_height = 128
tileset_size = tileset_width * tileset_height

tileset_path db "res\tileset.bmp", 0
tileset_buffer db tileset_size dup (0)

palette_color dd 0

transparent_color = 0fdh

;;; -- TILE_MAP --------------------------
tile_pawn_w dw 0, 0, 16, 16
tile_knight_w dw 16, 0, 16, 16
tile_bishop_w dw 32, 0, 16, 16
tile_rook_w dw 48, 0, 16, 16
tile_queen_w dw 64, 0, 16, 16
tile_king_w dw 80, 0, 16, 16

tile_pawn_b dw 0, 16, 16, 16
tile_knight_b dw 16, 16, 16, 16
tile_bishop_b dw 32, 16, 16, 16
tile_rook_b dw 48, 16, 16, 16
tile_queen_b dw 64, 16, 16, 16
tile_king_b dw 80, 16, 16, 16

tile_empty_w dw 0, 32, 20, 20
tile_empty_b dw 20, 32, 20, 20

tile_map dw tile_pawn_w, tile_knight_w, tile_bishop_w, tile_rook_w, tile_queen_w, tile_king_w, tile_pawn_b, tile_knight_b, tile_bishop_b, tile_rook_b, tile_queen_b, tile_king_b, tile_empty_w, tile_empty_b


;;; --  ----------------------------------

  .code

;;; draw the specified tile at position x y
;;; args t x y
tile_draw proc near
  entr 0

y = bp + 6
x = bp + 6 + 2
t = bp + 6 + 4

  push word ptr [x]
  push word ptr [y]
  mov ax, word ptr [t]
  mov bx, 2
  mul bx
  mov bx, ax
  mov cx, word ptr [tile_map + bx]
  mov bx, cx
  push word ptr [bx]
  push word ptr [bx + 2]
  push word ptr [bx + 4]
  push word ptr [bx + 6]
  push ax
  call tileset_draw

  leav
  ret
  endp

;;; draws region of tileset with w h at x y
;;; to position xp yp on screen
;;; doesnt draw it region outside
;;; of tileset is selected
;;; uses {}
;;; args: xp yp x y w h
tileset_draw proc near
  entr 0

h = bp + 6
w = bp + 6 + 2
y = bp + 6 + 4
x = bp + 6 + 6
yp = bp + 6 + 8
xp = bp + 6 + 10

  ;; check if postion in tileset is valid
  mov ax, word ptr [y]
  add ax, word ptr [h]
  mov bx, tileset_width
  mul ax
  add ax, word ptr [x]
  add ax, word ptr [w]
  cmp ax, tileset_size
  jg @@invalid_pos

  ;; check if position on screen is valid
  mov ax, word ptr [yp]
  add ax, word ptr [h]
  mov bx, screen_width
  mul bx
  add ax, word ptr [xp]
  add ax, word ptr [w]
  mov bx, screen_size
  cmp ax, bx
  ;; TODO: wtf
  ;; jg @@invalid_pos

  ;; get starting position for screen
  mov ax, word ptr [yp]
  mov bx, screen_width
  mul bx
  add ax, word ptr [xp]
  mov di, ax

  ;; get starting position for tileset
  mov ax, word ptr [y]
  mov bx, tileset_width
  mul bx
  add ax, word ptr [x]
  mov bx, ax

  mov cx, word ptr [w]
  mov dx, word ptr [h]

  ;; draw tile
@@draw:
  mov al, byte ptr [tileset_buffer + bx]
  cmp al, transparent_color
  je @@skip_px
  mov es:[di], al
@@skip_px:
  inc di
  inc bx

  dec cx
  jz @@draw_width
  jmp @@draw

@@draw_width:
  mov cx, word ptr [w]
  add di, screen_width
  sub di, cx
  add bx, tileset_width
  sub bx, cx

  dec dx
  jnz @@draw
  ;; -----

@@invalid_pos:
  leav
  ret
  endp

;;; load the tileset into memory
tileset_load proc near
  entr 12

fhandle = bp - 2
pal_count = bp - 4
height_count = bp - 6

  mov word ptr [pal_count], 0

  ;; open file for writing
  mov ah, 3dh
  mov dx, offset tileset_path
  xor al, al
  xor cx, cx
  int 21h
  jc @@ioerr

  mov word ptr [fhandle], ax

  ;; read from file
  ;; read bitmapfileheader and infoheader to buffer
  mov ah, 3fh
  mov bx, word ptr [fhandle]
  mov cx, 54
  mov dx, offset tileset_buffer
  int 21h
  jc @@cleanup_ioerr
  cmp ax, cx
  jne @@cleanup_ioerr

  ;; read color palette color by color
  xor ax, ax
  mov dx, 03c8h
  out dx, al

  mov word ptr [pal_count], 0
  xor ax, ax
  xor bx, bx
  mov bx, word ptr [fhandle]
@@set_pal:
  mov dx, offset palette_color
  mov ah, 3fh
  mov cx, 4
  int 21h
  jc @@cleanup_ioerr
  cmp ax, cx
  jne @@cleanup_ioerr

  mov dx, 03c9h
  mov cl, 2

  mov al, byte ptr [palette_color + 2]
  shr al, cl
  out dx, al                    ; Blue component
  mov al, byte ptr [palette_color + 1]
  shr al, cl
  out dx, al                    ; Green component
  mov al, byte ptr [palette_color]
  shr al, cl
  out dx, al                    ; Red component

  inc word ptr [pal_count]
  cmp word ptr [pal_count], 256
  jne @@set_pal

  ;; read image to buffer
  mov word ptr [height_count], tileset_height
  mov bx, word ptr [fhandle]
  mov dx, offset tileset_buffer
  add dx, tileset_size
@@read_ts:
  sub dx, tileset_width
  mov ah, 3fh
  mov cx, tileset_width
  int 21h
  jc @@cleanup_ioerr
  cmp ax, cx
  jne @@cleanup_ioerr

  sub word ptr [height_count], 1
  jnz @@read_ts

@@cleanup:
  mov ah, 3eh
  mov bx, word ptr [fhandle]
  int 21h

  leav
  ret

@@cleanup_ioerr:
  mov ah, 3eh
  mov bx, word ptr [fhandle]
  int 21h
@@ioerr:
  mov ax, 1
  call error

  endp


  end
