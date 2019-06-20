  include std.asm

  public init_board

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

  mov word ptr [board],     0cabdh
  mov word ptr [board + 2], 0ebach
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
  mov word ptr [board + 28], 04235h
  mov word ptr [board + 30], 06324h

  leav
  ret
  endp

;;; executes procudure for each location on board
;;; proc get piece in al and location in bx
;;; args:
;;;     pe ppw pknw pbw prw pqw pkw
;;;     ppb pknb pbb prb pqb pkb
board_for_each proc near
  entr 0

pe   = bp + 6 + 24
ppw  = bp + 6 + 22
pknw = bp + 6 + 20
pbw  = bp + 6 + 18
prw  = bp + 6 + 16
pqw  = bp + 6 + 14
pkw  = bp + 6 + 12
ppb  = bp + 6 + 10
pknb = bp + 6 + 8
pbb  = bp + 6 + 6
prb  = bp + 6 + 4
pqb  = bp + 6 + 2
pkb  = bp + 6

  xor ax, ax
  xor bx, bx

@@nibble_l:
  mov al, byte ptr [board + bx]
  mov ch, ah
  and ch, 1
  jnz @@for_nibble
  jz @@next_byte

  jmp @@sh_nibble

@@next_byte:
  inc bx

@@sh_nibble:
  mov cl, 4
  shr al, cl

@@for_nibble:
  and al, 0fh
  inc ah

  ;; do stuff with piece in al and position in bx

  push_args <>

  cmp al, 0
  je @@empty

  cmp al, 1
  je @@pawn_w
  cmp al, 2
  je @@knight_w
  cmp al, 3
  je @@bishop_w
  cmp al, 4
  je @@rook_w
  cmp al, 4
  je @@queen_W
  cmp al, 4
  je @@king_w

  cmp al, 9
  je @@pawn_b
  cmp al, 0ah
  je @@knight_b
  cmp al, 0bh
  je @@bishop_b
  cmp al, 0ch
  je @@rook_b
  cmp al, 0dh
  je @@queen_b
  cmp al, 0eh
  je @@king_b

  jmp @@next_p


@@empty:
  call [pe]
  jmp @@next_p

@@pawn_w:
  call [ppw]
  jmp @@next_p
@@knight_w:
  call [pknw]
  jmp @@next_p
@@bishop_w:
  call [pbw]
  jmp @@next_p
@@rook_w:
  call [prw]
  jmp @@next_p
@@queen_w:
  call [pqw]
  jmp @@next_p
@@king_w:
  call [pkw]
  jmp @@next_p

@@pawn_b:
  call [ppb]
  jmp @@next_p
@@knight_b:
  call [pknb]
  jmp @@next_p
@@bishop_b:
  call [pbb]
  jmp @@next_p
@@rook_b:
  call [prb]
  jmp @@next_p
@@queen_b:
  call [pqb]
  jmp @@next_p
@@king_b:
  call [pkb]

  ;; -----
@@next_p:
  pop_args

  cmp ah, 64
  jl @@nibble_l

  leav
  ret
  endp


  end
