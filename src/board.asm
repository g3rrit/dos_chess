  include std.asm

  public board_init
  public board_for_each
  public piece_at
  public board_move

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
;;; 0000 0001 - 1 - Pawn (b)
;;; 0000 0010 - 2 - Knight (b)
;;; 0000 0011 - 3 - Bishop (b)
;;; 0000 0100 - 4 - Rook (b)
;;; 0000 0101 - 5 - Queen (b)
;;; 0000 0110 - 6 - King (b)
;;;
;;; 0000 1001 - 9 - Pawn (w)
;;; 0000 1010 - a - Knight (w)
;;; 0000 1011 - b - Bishop (w)
;;; 0000 1100 - c - Rook (w)
;;; 0000 1101 - d - Queen (w)
;;; 0000 1110 - e - King (w)
;;; --  ----------------------------------

  board db 64 dup (0)

;;; --  ----------------------------------


  .code

;;; converts the byte in al
;;; where the first nibble represents
;;; the x pos and second one the y pos
;;; to a representation in al
;;; describing the location on the board 0 - 63
board_xy_pos macro
  push bx
  push cx

  xor ah, ah
  ;; save x pos to bx
  mov bx, ax
  mov cx, 4
  shr bx, cl

  mov cx, bx
  mov bx, ax
  mov ax, cx

  ;; multiply by 8 and add xpos
  mov cx, 8
  mul cx
  and bx, 0fh
  add ax, bx

  pop cx
  pop bx
  endm

;;; moves piece from location xy to x0y0
;;; args:
;;;     xy dxy as 2 8bit values
board_move proc near
  entr 0

src = bp + 6 + 1
dst = bp + 6

  xor ax, ax
  xor bx, bx

  mov al, byte ptr [src]
  board_xy_pos
  mov bl, al

  mov al, byte ptr [board + bx]
  push ax
  mov byte ptr [board + bx], 0

  mov al, byte ptr [dst]
  board_xy_pos
  mov bl, al

  pop ax
  mov byte ptr [board + bx], al

  leav
  ret

  endp

board_init proc near
  entr 0

  mov word ptr [board],     0a0ch
  mov word ptr [board + 2], 0d0bh
  mov word ptr [board + 4], 0b0eh
  mov word ptr [board + 6], 0c0ah
  mov word ptr [board + 8], 0909h
  mov word ptr [board + 10], 0909h
  mov word ptr [board + 12], 0909h
  mov word ptr [board + 14], 0909h

  mov word ptr [board + 16], 0
  mov word ptr [board + 18], 0
  mov word ptr [board + 20], 0
  mov word ptr [board + 22], 0
  mov word ptr [board + 24], 0
  mov word ptr [board + 26], 0
  mov word ptr [board + 28], 0
  mov word ptr [board + 30], 0
  mov word ptr [board + 32], 0
  mov word ptr [board + 34], 0
  mov word ptr [board + 36], 0
  mov word ptr [board + 38], 0
  mov word ptr [board + 40], 0
  mov word ptr [board + 42], 0
  mov word ptr [board + 44], 0
  mov word ptr [board + 46], 0

  mov word ptr [board + 48], 0101h
  mov word ptr [board + 50], 0101h
  mov word ptr [board + 52], 0101h
  mov word ptr [board + 54], 0101h
  mov word ptr [board + 56], 0204h
  mov word ptr [board + 58], 0503h
  mov word ptr [board + 60], 0306h
  mov word ptr [board + 62], 0402h

  leav
  ret
  endp

;;; retrieves piece at location x y
;;;  args:
;;;     xy as lower byte
;;;  returns:
;;;     ax: piece
piece_at proc near
  entr 0

pos = bp + 6

  xor ax, ax
  xor bx, bx

  ;; x pos in bl
  mov al, byte ptr [pos]
  mov cx, 4
  shr al, cl
  mov bl, al

  ;; y pos in al
  mov al, byte ptr [pos]
  and al, 0fh

  cmp al, 8
  jge @@invalid_pos
  cmp bl, 8
  jge @@invalid_pos

  mov cx, 8
  mul cx

  add al, bl

  mov bx, ax
  mov al, byte ptr [board + bx]

  leav
  ret

@@invalid_pos:
  mov ax, 0ffffh
  leav
  ret

  endp


;;; executes procudure for each location on board
;;; proc get location as stack args: piece x y
;;; args:
;;;     cb
board_for_each proc near
  entr 2

piece = bp - 2

cb = bp + 6

  xor ax, ax
  xor bx, bx
  xor cx, cx
  xor dx, dx

@@continue:

  ;; save cx
  push cx

  mov al, cl
  mov cx, 4
  shl al, cl
  add al, dl

  ;; restore cx
  pop cx

  push_args<ax>
  call piece_at
  mov word ptr [piece], ax
  pop_args
  mov ax, word ptr [piece]

  push_args <ax, cx, dx>
  call word ptr [cb]
  pop_args

  inc cx

  cmp cx, 8
  jne @@continue

  mov cx, 0
  inc dx

  cmp dx, 8
  jne @@continue

  leav
  ret
  endp


  end
