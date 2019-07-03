  include std.asm

  extrn cboard

  .data

  .code

;;; wrapper for current board
;;; args:
;;;     buf xy pos as lower byte
cvalid_moves proc near
  entr 0

buf = bp + 6 + 2
loc = bp + 6

  mov ax, offset cboard
  mov bx, word ptr [buf]
  mov cx, word ptr [loc]
  push_args<ax, bx, cx>
  call valid_moves

  leav
  ret
  endp

;;; calculates all valid moves starting from a specific position
;;; args:
;;;     board buf xy pos as lower byte
valid_moves proc near
  entr 2

piece = bp - 2

board = bp + 6 + 4
buf = bp + 6 + 2
loc = bp + 6


  leav
  ret
  endp

  end
