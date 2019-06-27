  include std.asm

  public init_board
  public board_for_each
  public piece_at

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
;;; 0000 - 0 - Empty
;;;
;;; 0001 - 1 - Pawn (w)
;;; 0010 - 2 - Knight (w)
;;; 0011 - 3 - Bishop (w)
;;; 0100 - 4 - Rook (w)
;;; 0101 - 5 - Queen (w)
;;; 0110 - 6 - King (w)
;;;
;;; 1001 - 9 - Pawn (b)
;;; 1010 - a - Knight (b)
;;; 1011 - b - Bishop (b)
;;; 1100 - c - Rook (b)
;;; 1101 - d - Queen (b)
;;; 1110 - e - King (b)
;;; --  ----------------------------------

  board db 32 dup (0)

;;; --  ----------------------------------


  .code

init_board proc near
  entr 0

  mov word ptr [board],     0bdcah
  mov word ptr [board + 2], 0acebh
  mov word ptr [board + 4], 09999h
  mov word ptr [board + 6], 09999h

  mov word ptr [board + 8], 0
  mov word ptr [board + 10], 0
  mov word ptr [board + 12], 0
  mov word ptr [board + 14], 0
  mov word ptr [board + 16], 0
  mov word ptr [board + 18], 0
  mov word ptr [board + 20], 0
  mov word ptr [board + 22], 0

  mov word ptr [board + 24], 01111h
  mov word ptr [board + 26], 01111h
  mov word ptr [board + 28], 03542h
  mov word ptr [board + 30], 02463h

  leav
  ret
  endp

;;; retrieves piece at location x y
;;;  args:
;;;     x y
;;;  returns:
;;;     ax: piece
piece_at proc near
  entr 0

xpos = bp + 6 + 2
ypos = bp + 6

  cmp word ptr [xpos], 8
  jg @@invalid_pos
  cmp word ptr [ypos], 8
  jg @@invalid_pos

  mov ax, 8
  mov bx, word ptr [ypos]
  mul bx
  mov cx, 1
  add ax, word ptr [xpos]
  shr ax, cl

  mov bx, ax
  mov al, byte ptr [board + bx]

  jnc @@sh_nibble

  jmp @@for_nibble

@@sh_nibble:
  mov cl, 4
  shr al, cl

@@for_nibble:
  and al, 0fh

  xor ah, ah

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

  xor cx, cx
  xor dx, dx

@@continue:

  push_args<cx, dx>
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
