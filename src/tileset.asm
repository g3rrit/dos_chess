  include "util.asm"

  public tileset_load

  extrn error:proc

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

  .data

bmp_header bmp_header_t <>

tileset_path db "tileset.bmp", 0
tileset_buffer dw 20000 dup (0)

  .code

tileset_load proc near
  entr 8

fhandle = get_var 2
pal_b = get_var 4
pal_g = get_var 5
pal_r = get_var 6
pal_count = get_var 8

  mov word ptr [pal_count], 0


  ;; open file for writing
  mov ah, 3dh
  mov dx, offset fpath
  xor al, al
  xor cx, cx
  int 21h
  jc ioerr

  mov word ptr [fhandle], ax

  ;; read from file
  ;; read bitmapfileheader and infoheader to buffer
  mov ah, 3fh
  mov bx, word ptr [fhandle]
  mov cx, 54
  mov dx, offset tileset_buffer
  int 21h
  jc cleanup_ioerr
  cmp ax, cx
  jne cleanup_ioerr

  xor al, al

  ;; set color palette
  mov dx, 03c8h                 ; RGB write register
  out dx, al                    ; Set the palette index
  inc dx                        ; 03C9 RGB data register

  ;; read color palette
set_pal_l:
  mov ah, 3fh
  mov bx, word ptr [fhandle]
  mov cx, 4
  mov dx, bp + 2
  int 21h
  jc cleanup_ioerr
  cmp ax, cx
  jne cleanup_ioerr

  mov bx, word ptr [pal_count]
  xor al, al

  mov cl, 2
  mov al, byte ptr [pal_b]
  shr al, cl
  out dx, al                    ; Blue component
  mov al, byte ptr [pal_g]
  shr al, cl
  out dx, al                    ; Green component
  mov al, byte ptr [pal_r]
  shr al, cl
  out dx, al                    ; Red component

  add word ptr [pal_count], 4
  cmp word ptr [pal_count], 1024
  jne set_pal_l

  ;; read image to buffer
  mov ah, 3fh
  mov bx, word ptr [fhandle]
  mov cx, 100
  mov dx, offset tileset_buffer
  xor al, al
  int 21h
  jc cleanup_ioerr
  cmp ax, cx
  jne cleanup_ioerr


@@cleanup:
  mov ah, 3eh
  mov bx, word ptr [fhandle]
  int 21h

  ret

@@cleanup_ioerr:
  mov ah, 3eh
  mov bx, word ptr [fhandle]
  int 21h
@@ioerr:
  mov ax, 1
  call error

  endp
