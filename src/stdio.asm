  .model small
  .386

  .data

  .code

  include src\gfxutil.asm

  public print

  ;; address of printable string in ax
  ;; string needs to end with $
print proc near
  mov bx, ax
  set_txt_mode

  mov dx, bx
  mov ah, 09h
  int 21h

  ret
  endp

  end
