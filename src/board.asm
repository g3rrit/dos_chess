  include std.asm

  public board_init
  public board_at_pos
  public board_at
  public board_set_pos
  public board_set
  public board_move


  public board

  .data

;;; -- BOARD -----------------------------
;;; + - - - - - - - - +
;;; | R K B Q K B K R | black side
;;; | P P P P P P P P |
;;; |                 |
;;; |                 |
;;; |                 |
;;; |                 |
;;; | P P P P P P P P |
;;; | R K B Q K B K R | white side
;;; + - - - - - - - - +
;;;
;;; the nibble prepending each piece is used to store
;;; special attributes of that position
;;;
;;; 0000 0000 - 0 - Empty
;;;
;;; 0000 0001 - 1 - Pawn (w)
;;; 0000 0010 - 2 - Knight (w)
;;; 0000 0011 - 3 - Bishop (w)
;;; 0000 0100 - 4 - Rook (w)
;;; 0000 0101 - 5 - Queen (w)
;;; 0000 0110 - 6 - King (w)
;;;
;;; 0000 1001 - 9 - Pawn (b)
;;; 0000 1010 - a - Knight (b)
;;; 0000 1011 - b - Bishop (b)
;;; 0000 1100 - c - Rook (b)
;;; 0000 1101 - d - Queen (b)
;;; 0000 1110 - e - King (b)
;;; --  ----------------------------------

;;; current active board
board db 64 dup (0)

;;; --  ----------------------------------


  .code

;;; converts position xy
;;; to a representation in al
;;; describing the location on the board 0 - 63
board_xy_pos macro
  push cx
  push dx
  mov dx, ax
  xor ah, ah
  mov cx, 8
  mul cl
  add al, dh
  xor ah, ah
  pop dx
  pop cx
  endm

;;; converts a position in al 0 - 63
;;; to a representation in ah al
board_pos_xy macro
  push dx
  push cx
  mov dx, 0
  mov cx, 8
  div cl
  pop cx
  pop dx
  endm

;;; initializes board
board_init proc near
  entr 0

  mov bx, offset board
  mov word ptr [bx],     0a0ch
  mov word ptr [bx + 2], 0d0bh
  mov word ptr [bx + 4], 0b0eh
  mov word ptr [bx + 6], 0c0ah
  mov word ptr [bx + 8], 0909h
  mov word ptr [bx + 10], 0909h
  mov word ptr [bx + 12], 0909h
  mov word ptr [bx + 14], 0909h

  mov word ptr [bx + 16], 0
  mov word ptr [bx + 18], 0
  mov word ptr [bx + 20], 0
  mov word ptr [bx + 22], 0
  mov word ptr [bx + 24], 0
  mov word ptr [bx + 26], 0
  mov word ptr [bx + 28], 0
  mov word ptr [bx + 30], 0
  mov word ptr [bx + 32], 0
  mov word ptr [bx + 34], 0
  mov word ptr [bx + 36], 0
  mov word ptr [bx + 38], 0
  mov word ptr [bx + 40], 0
  mov word ptr [bx + 42], 0
  mov word ptr [bx + 44], 0
  mov word ptr [bx + 46], 0

  mov word ptr [bx + 48], 0101h
  mov word ptr [bx + 50], 0101h
  mov word ptr [bx + 52], 0101h
  mov word ptr [bx + 54], 0101h
  mov word ptr [bx + 56], 0204h
  mov word ptr [bx + 58], 0503h
  mov word ptr [bx + 60], 0306h
  mov word ptr [bx + 62], 0402h

  leav
  ret
  endp

;;; moves piece from ax to bx
;;; x in high y in low
;;; args:
;;;     ax: src
;;;     bx: dest
board_move proc near
  entr 0

  push cx
  push dx
  mov cx, ax
  mov dx, bx
  call board_at
  push ax
  mov al, 0
  mov bx, ax
  mov ax, cx
  call board_set
  pop bx
  mov ax, dx
  call board_set

  pop dx
  pop cx
  leav
  ret
  endp

;;; retrieves piece at location pos
;;; args:
;;;     ax: pos
;;; returns:
;;;     ax: piece
board_at_pos proc near
  entr 0
  push bx

  cmp ax, 64
  jnc @@invalid_pos

  add ax, offset board
  mov bx, ax
  mov al, byte ptr [bx]
  byte_to_word
  pop bx
  leav
  ret

@@invalid_pos:
  mov ax, 0ffffh
  pop bx
  leav
  ret
  endp

;;; sets board at position ax to bx
;;; args:
;;;     ax: pos
;;;     bx: new value
board_set_pos proc near
  entr 0
  push bx

  cmp ax, 64
  jnc @@invalid_pos

  push ax
  mov ax, bx
  pop bx

  word_to_byte

  add bx, offset board
  mov byte ptr [bx], al

  pop bx
  leav
  ret

 @@invalid_pos:
  mov ax, 0ffffh
  pop bx
  leav
  ret
  endp

;;; retrieves piece at location x y
;;;  args:
;;;     ax: pos x in high y in low
;;;  returns:
;;;     ax: piece
board_at proc near
  entr 0
  board_xy_pos
  call board_at_pos
  leav
  ret
  endp

;;; sets value at location x y
;;; args:
;;;     ax: pos x in high y in low
;;;     bx: value
board_set proc near
  entr 0
  board_xy_pos
  call board_set_pos
  leav
  ret
  endp


  end
