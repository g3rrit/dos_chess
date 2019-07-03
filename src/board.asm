  include std.asm

  public board_init
  public board_for_each
  public board_at
  public board_move

  public cboard_init
  public cboard_for_each
  public cboard_at
  public cboard_move

  public cboard

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
cboard db 64 dup (0)

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

  ;; multiply by 8 and add xpos
  mov cx, 8
  and ax, 0fh
  mul cx
  add ax, bx

  pop cx
  pop bx
  endm

;;; wrapper without explicit board
;;; args:
;;;     xy dxy as 2 8 bit values
cboard_move proc near
  entr 0

loc = bp + 6
  mov ax, offset cboard
  mov bx, word ptr [loc]
  push_args<ax, bx>
  call board_move

  leav
  ret
  endp

;;; moves piece from location xy to x0y0
;;; args:
;;;     board xy dxy as 2 8bit values
board_move proc near
  entr 0

board = word ptr [bp + 6 + 2]
src = bp + 6 + 1
dst = bp + 6

  xor ax, ax
  xor bx, bx

  mov al, byte ptr [src]
  board_xy_pos
  mov bl, al

  add bx, word ptr [board]
  mov al, byte ptr [bx]
  push ax
  mov byte ptr [bx], 0
  xor bx, bx

  mov al, byte ptr [dst]
  board_xy_pos
  mov bl, al

  pop ax
  add bx, word ptr [board]
  mov byte ptr [bx], al

  leav
  ret

  endp

;;; wrapper without explicit board
cboard_init proc near
  entr 0

  mov ax, offset cboard
  push_args<ax>
  call board_init

  leav
  ret
  endp

;;; initializes board
;;; args:
;;;     board
board_init proc near
  entr 0

board = bp + 6

  mov bx, word ptr [board]
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

;;; wrapper without explicit board
;;; args:
;;;     xy as lower byte
;;; retruns:
;;;     ax: piece
cboard_at proc near
  entr 0

pos = bp + 6
  mov ax, offset cboard
  mov bx, word ptr [pos]
  push_args<ax, bx>
  call board_at

  leav
  ret
  endp

;;; retrieves piece at location x y
;;;  args:
;;;     board xy as lower byte
;;;  returns:
;;;     ax: piece
board_at proc near
  entr 0

board = bp + 6 + 2
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
  add bx, word ptr [board]
  mov al, byte ptr [bx]

  leav
  ret

@@invalid_pos:
  mov ax, 0ffffh
  leav
  ret

  endp


;;; wrapper without explicit board
;;; args:
;;;     cb
cboard_for_each proc near
  entr 0
cb = bp + 6

  mov ax, offset cboard
  mov bx, word ptr [cb]
  push_args<ax, bx>
  call board_for_each
  pop_args

  leav
  ret
  endp

;;; executes procudure for each location on board
;;; proc get location as stack args: piece x y
;;; args:
;;;     board cb
board_for_each proc near
  entr 2

piece = bp - 2

board = bp + 6 + 2
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

  save_reg
  mov bx, word ptr [board]
  push_args<bx, ax>
  call board_at
  pop_args
  mov word ptr [piece], ax
  res_reg
  mov ax, word ptr [piece]

  save_reg
  mov bx, word ptr [board]
  push_args <bx, ax, cx, dx>
  call word ptr [cb]
  pop_args
  res_reg

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
