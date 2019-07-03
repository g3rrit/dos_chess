

;;; converts a location x y in ax bx
;;; to a location xy in al
board_dword_byte macro
  push cx

  mov cx, 4
  shl ax, cl
  add bx, ax
  mov ax, bx
  xor bx, bx

  pop cx
  endm

;;; converts a location xy in al
;;; to a location x y in ax bx
board_byte_dword macro
  push cx

  mov bx, ax
  and ax, 0f0h
  mov cx, 4
  shr ax, cl

  and bx, 0fh

  pop cx
  endm
