  include std.asm

  extrn board
  extrn board_at

  .data

  .code

;;; calculates all valid moves starting from a specific position
;;; args:
;;;     buf xy pos as lower byte
;;; returns:
;;;     valid moves in buf
;;;     move count in ax
valid_moves proc near
  entr 0

buf = bp + 6 + 2
pos = bp + 6

  ;; get piece at location pos to ax
  mov ax, word ptr [board]
  mov bx, word ptr [pos]
  push_args<ax, bx>
  call board_at

  ;; change position to low high byte
  push ax
  mov ax, word ptr [pos]
  mov word ptr [pos], ax
  pop ax

  mov bx, 8
  and bx, ax

  and ax, 111b

  mov cx, word ptr [board]
  mov dx, word ptr [buf]

  cmp ax, 0
  je @@empty
  cmp ax, 1
  je @@pawn
  cmp ax, 2
  je @@knight
  cmp ax, 3
  je @@bishop
  cmp ax, 4
  je @@rook
  cmp ax, 5
  je @@queen
  cmp ax, 6
  je @@king

@@empty:
  mov ax, 0
  jmp @@done

@@pawn:
  mov ax, word ptr [pos]
  push_args<cx, dx, ax, bx>
  call valid_pawn
  jmp @@done

@@knight:
  mov ax, word ptr [pos]
  push_args<cx, dx, ax, bx>
  call valid_knight
  jmp @@done

@@bishop:
  mov ax, word ptr [pos]
  push_args<cx, dx, ax, bx>
  call valid_bishop
  jmp @@done

@@rook:
  mov ax, word ptr [pos]
  push_args<cx, dx, ax, bx>
  call valid_rook
  jmp @@done

@@queen:
  mov ax, word ptr [pos]
  push_args<cx, dx, ax, bx>
  call valid_queen
  jmp @@done

@@king:
  mov ax, word ptr [pos]
  push_args<cx, dx, ax, bx>
  call valid_king

@@done:

  leav
  ret
  endp

valid_pawn proc near
  entr 2

count = bp - 2
  mov word ptr [count], 0

buf = bp + 6 + 4
pos = bp + 6 + 2
color = bp + 6

  cmp word ptr [color], 1
  je @@black

  ;; white pawn

  ;; check if at starting pos
  mov ax, word ptr [pos]
  cmp al, 7
  jne @@wnot_start

@@wnot_start:

  ;; black pawn
@@black:


  leav
  ret
  endp

valid_knight proc near
  entr 0

buf = bp + 6 + 4
pos = bp + 6 + 2
color = bp + 6

  leav
  ret
  endp

valid_bishop proc near
  entr 0

buf = bp + 6 + 4
pos = bp + 6 + 2
color = bp + 6

  leav
  ret
  endp

valid_rook proc near
  entr 0

buf = bp + 6 + 4
pos = bp + 6 + 2
color = bp + 6



  leav
  ret
  endp

valid_queen proc near
  entr 0

buf = bp + 6 + 4
pos = bp + 6 + 2
color = bp + 6



  leav
  ret
  endp

valid_king proc near
  entr 0

buf = bp + 6 + 4
pos = bp + 6 + 2
color = bp + 6



  leav
  ret
  endp

  end
