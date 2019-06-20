  include std.asm

  public tileset_load
  public tileset_draw

  extrn error:proc

  .data

tileset_width = 96
tileset_height = 128
tileset_size = tileset_width * tileset_height

tileset_path db "res\tileset.bmp", 0
tileset_buffer db tileset_size dup (0)

bmp_header_t struc
  sig dw 0
  usize dd 0
  res dd 0
  imgoffset dd 0

  diheadersize dd 0
  biwidth dd 0
  biheight dd 0
  planes dw 0
  bitcount dw 0
  comp dd 0
  imgsize dd 0
  xppm dd 0
  yppm dd 0
  clrused dd 0
  clrimportant dd 0
  ends

bmp_header bmp_header_t <>

palette db 1024 dup (?)

palette_color dd 0


  .code

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
xp = bp + 6 + 8
yp = bp + 6 + 10

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
  mov es:[di], al
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
