  .model small
  .386

  .data

buffer db 200 dup (0)

fpath db "test.txt$", 0

  .code

  public read_bmp

  locals l_

  extrn error:proc
  extrn print:proc

read_bmp proc near
l_fh = [bp]
l_fs = [bp + 2]
  enter 4, 0

  mov dx, offset fpath

  ;; open file and save handle to ax
  ;; exit on error
  mov ah, 3dh
  mov ax, 0                     ; reading only
  int 21h
  jc l_open_err

  mov dx, offset buffer         ; desination
l_read_byte:
  ;; read from file
  mov ah, 3fh
  mov cx, 1                     ; 1 byte
  mov bx, l_fh
  int 21h
  jc l_read_err

  inc dx
  cmp ax, cx
  je l_read_byte

  ;; eof
  mov [buffer], 24h

  ;; print content of file
  mov ax, offset buffer
  call print

  ;; close file
  mov bx, l_fh
  mov ah, 3eh
  int 21h
  jc l_close_err


  leave
  ret

l_open_err:
  mov ax, 1
  call error
l_read_err:
  ;; close file
  mov bx, l_fh
  mov ah, 3eh
  int 21h
  jc l_close_err
  mov ax, 2
  call error
l_close_err:
  mov ax, 3
  call error

  endp

  end
