  .model small
  .386

  .data

buffer db 200 dup ('$')

fpath db "test.txt$", 0

  .code

  public read_bmp

  locals l_

  extrn error:proc
  extrn print:proc

  ;; reads and prints contents of a file
read_bmp proc near
  enter 0, 0

  mov ax, @data
  mov ds, ax

  push offset fpath
  push offset buffer
  push 200
  call read_file
  add sp, 6

  ;; eof
  mov bx, dx
  mov [bx], 24h

  ;; print content of file
  mov ax, offset buffer
  call print

  leave
  ret
  endp


  ;; reads file from disk
  ;; args:
  ;;  path - pointer to filename
  ;;  buf -  pointer to buffer
  ;;  len - length of buffer
read_file proc near
path = [bp + 4 + 4]
buf = [bp + 4 + 2]
len = [bp + 4]
fhandle = [bp]
  enter 2, 0

  mov ax, @data
  mov ds, ax

  mov dx, path

  ;; open file and save handle to ax
  ;; exit on error
  mov ah, 3dh
  mov al, 0                     ; reading only
  int 21h
  jc l_open_err

  mov fhandle, ax

  mov dx, buf                   ; desination
l_read_byte:
  cmp len, 0
  je l_cleanup
  ;; read from file
  mov ah, 3fh
  mov cx, 1                     ; 1 byte
  mov bx, fhandle
  int 21h
  jc l_read_err

  dec len
  inc dx
  cmp ax, cx
  je l_read_byte

l_cleanup:
  ;; close file
  mov bx, fhandle
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
  mov bx, fhandle
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
