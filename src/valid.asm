  include std.asm

  extrn board:proc
  extrn board_at:proc

  extrn set_selected:proc

  public valid_moves

  .data

pos dw 0

  .code

;;; calculates all valid moves starting from a specific position
;;; args:
;;;     ax: pos
valid_moves proc near
  entr 0

  save_reg

  push ax
  call board_at
  mov bx, ax
  pop ax
  mov bh, 0

  mov word ptr [pos], ax

  cmp bx, 0
  je @@empty
  cmp bx, 1
  je @@pawn_w
  cmp bx, 2
  je @@knight_w
  cmp bx, 3
  je @@bishop_w
  cmp bx, 4
  je @@rook_w
  cmp bx, 5
  je @@queen_w
  cmp bx, 6
  je @@king_w

  cmp bx, 9
  je @@pawn_b
  cmp bx, 10
  je @@knight_b
  cmp bx, 11
  je @@bishop_b
  cmp bx, 12
  je @@rook_b
  cmp bx, 13
  je @@queen_b
  cmp bx, 14
  je @@king_b

@@empty:
  jmp @@done

@@pawn_w:
  call valid_pawn_w
  jmp @@done

@@knight_w:
  call valid_knight_w
  jmp @@done

@@bishop_w:
  call valid_bishop_w
  jmp @@done

@@rook_w:
  call valid_rook_w
  jmp @@done

@@queen_w:
  call valid_queen_w
  jmp @@done

@@king_w:
  call valid_king_w
  jmp @@done


@@pawn_b:
  call valid_pawn_b
  jmp @@done

@@knight_b:
  call valid_knight_b
  jmp @@done

@@bishop_b:
  call valid_bishop_b
  jmp @@done

@@rook_b:
  call valid_rook_b
  jmp @@done

@@queen_b:
  call valid_queen_b
  jmp @@done

@@king_b:
  call valid_king_b

@@done:

  res_reg
  leav
  ret
  endp

;;; position in ax

;;; selects a position if empty
sel_empty macro
  local done, select
  push ax
  call board_at
  cmp ax, 0ffffh
  je done
  cmp al, 0
  je select
  mov dx, 1
  jmp done

select:
  pop ax
  push ax
  call set_selected

done:
  pop ax
  endm

;;; selects a position if empty
;;; or if black piece at location
;;; location at ax
sel_white macro
  local done, select, select_p
  push ax
  call board_at
  cmp ax, 0ffffh
  je done
  cmp al, 0
  je select
  cmp al, 8
  jnc select_p
  jmp done

select_p:
  mov dx, 1

select:
  pop ax
  push ax
  call set_selected

done:
  pop ax
  endm

;;; selects a position if empty
;;; or if white piece at location
;;; location at ax
sel_black macro
  local done, select, select_p
  push ax
  call board_at
  cmp ax, 0ffffh
  je done
  cmp al, 0
  je select
  cmp al, 8
  jc select_p
  jmp done

select_p:
  mov dx, 1

select:
  mov dx, 1
  pop ax
  push ax
  call set_selected

done:
  pop ax
  endm

valid_pawn_w proc near
  entr 0

  dec al
  sel_empty
  cmp dx, 1
  je @@no_two

  cmp al, 5
  jne @@no_two

  dec al
  sel_empty
  inc al

@@no_two:

  dec ah
  sel_white

  add ah, 2
  sel_white

  leav
  ret
  endp

valid_pawn_b proc near
  entr 0

  inc al
  sel_empty
  cmp dx, 1
  je @@no_two

  cmp al, 2
  jne @@no_two

  inc al
  sel_empty
  dec al

@@no_two:

  dec ah
  sel_black

  add ah, 2
  sel_black

  leav
  ret
  endp

valid_knight_w proc near
  entr 0

  sub al, 2
  add ah, 1
  sel_white

  inc ah
  inc al
  sel_white

  add al, 2
  sel_white

  inc al
  dec ah
  sel_white

  sub ah, 2
  sel_white

  dec al
  dec ah
  sel_white

  sub al, 2
  sel_white

  dec al
  inc ah
  sel_white

  leav
  ret
  endp

valid_bishop_w proc near
  entr 0

  leav
  ret
  endp

valid_rook_w proc near
  entr 0


  leav
  ret
  endp

valid_queen_w proc near
  entr 0


  leav
  ret
  endp

valid_king_w proc near
  entr 0

  leav
  ret
  endp


valid_knight_b proc near
  entr 0

  leav
  ret
  endp

valid_bishop_b proc near
  entr 0

  leav
  ret
  endp

valid_rook_b proc near
  entr 0


  leav
  ret
  endp

valid_queen_b proc near
  entr 0


  leav
  ret
  endp

valid_king_b proc near
  entr 0

  leav
  ret
  endp

  end
