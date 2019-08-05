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

  xor dx, dx

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
  xor dx, dx
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
  xor dx, dx
  push ax
  call board_at
  cmp ax, 0ffffh
  je done
  cmp al, 0
  je select
  mov dx, 1
  cmp al, 8
  jc done

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
  xor dx, dx
  push ax
  call board_at
  cmp ax, 0ffffh
  je done
  cmp al, 0
  je select
  mov dx, 1
  cmp al, 8
  jnc done

select:
  pop ax
  push ax
  call set_selected

done:
  pop ax
  endm


;;; selects a position
;;; if black piece at location
;;; location at ax
sel_white_only macro
  local done, select, select_p
  xor dx, dx
  push ax
  call board_at
  cmp ax, 0ffffh
  je done
  cmp al, 0
  je done
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

;;; selects a position
;;; if white piece at location
;;; location at ax
sel_black_only macro
  local done, select, select_p
  xor dx, dx
  push ax
  call board_at
  cmp ax, 0ffffh
  je done
  cmp al, 0
  je done
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

;;; --------------------------
;;; ---------- PAWN ----------
;;; --------------------------

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
  sel_white_only

  add ah, 2
  sel_white_only

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
  sel_black_only

  add ah, 2
  sel_black_only

  leav
  ret
  endp

;;; --------------------------
;;; ---------- KNIGHT --------
;;; --------------------------


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

valid_knight_b proc near
  entr 0

  sub al, 2
  add ah, 1
  sel_black

  inc ah
  inc al
  sel_black

  add al, 2
  sel_black

  inc al
  dec ah
  sel_black

  sub ah, 2
  sel_black

  dec al
  dec ah
  sel_black

  sub al, 2
  sel_black

  dec al
  inc ah
  sel_white

  leav
  ret
  endp

;;; --------------------------
;;; ---------- BISHOP --------
;;; --------------------------


valid_bishop_w proc near
  entr 0

@@left_up:
  sub ah, 1
  jc @@next0
  sub al, 1
  jc @@next0
  sel_white
  cmp dx, 1
  je @@next0

  jmp @@left_up

@@next0:
  mov ax, word ptr [pos]
@@left_down:
  sub ah, 1
  jc @@next1
  inc al
  cmp al, 8
  jnc @@next1
  sel_white
  cmp dx, 1
  je @@next1

  jmp @@left_down

@@next1:
  mov ax, word ptr [pos]
@@right_up:
  inc ah
  cmp ah, 8
  jnc @@next2
  sub al, 1
  jc @@next2
  sel_white
  cmp dx, 1
  je @@next2

  jmp @@right_up

@@next2:
  mov ax, word ptr [pos]
@@right_down:
  inc ah
  cmp ah, 8
  jnc @@done
  inc al
  cmp al, 8
  jnc @@done
  sel_white
  cmp dx, 1
  je @@done

  jmp @@right_down

@@done:

  leav
  ret
  endp

valid_bishop_b proc near
  entr 0

@@left_up:
  sub ah, 1
  jc @@next0
  sub al, 1
  jc @@next0
  sel_black
  cmp dx, 1
  je @@next0

  jmp @@left_up

@@next0:
  mov ax, word ptr [pos]
@@left_down:
  sub ah, 1
  jc @@next1
  inc al
  cmp al, 8
  jnc @@next1
  sel_black
  cmp dx, 1
  je @@next1

  jmp @@left_down

@@next1:
  mov ax, word ptr [pos]
@@right_up:
  inc ah
  cmp ah, 8
  jnc @@next2
  sub al, 1
  jc @@next2
  sel_black
  cmp dx, 1
  je @@next2

  jmp @@right_up

@@next2:
  mov ax, word ptr [pos]
@@right_down:
  inc ah
  cmp ah, 8
  jnc @@done
  inc al
  cmp al, 8
  jnc @@done
  sel_black
  cmp dx, 1
  je @@done

  jmp @@right_down

@@done:

  leav
  ret
  endp

;;; --------------------------
;;; ---------- ROOK ----------
;;; --------------------------


valid_rook_w proc near
  entr 0

@@left:
  sub ah, 1
  jc @@next0
  sel_white
  cmp dx, 1
  je @@next0
  jmp @@left

@@next0:
  mov ax, word ptr [pos]
@@right:
  inc ah
  cmp ah, 8
  jnc @@next1
  sel_white
  cmp dx, 1
  je @@next1
  jmp @@right

@@next1:
  mov ax, word ptr [pos]
@@up:
  sub al, 1
  jc @@next2
  sel_white
  cmp dx, 1
  je @@next2
  jmp @@up

@@next2:
  mov ax, word ptr [pos]
@@down:
  inc al
  cmp al, 8
  jnc @@done
  sel_white
  cmp dx, 1
  je @@done
  jmp @@down

@@done:

  leav
  ret
  endp

valid_rook_b proc near
  entr 0

@@left:
  sub ah, 1
  jc @@next0
  sel_black
  cmp dx, 1
  je @@next0
  jmp @@left

@@next0:
  mov ax, word ptr [pos]
@@right:
  inc ah
  cmp ah, 8
  jnc @@next1
  sel_black
  cmp dx, 1
  je @@next1
  jmp @@right

@@next1:
  mov ax, word ptr [pos]
@@up:
  sub al, 1
  jc @@next2
  sel_black
  cmp dx, 1
  je @@next2
  jmp @@up

@@next2:
  mov ax, word ptr [pos]
@@down:
  inc al
  cmp al, 8
  jnc @@done
  sel_black
  cmp dx, 1
  je @@done
  jmp @@down

@@done:

  leav
  ret
  endp

;;; --------------------------
;;; ---------- QUEEN ---------
;;; --------------------------


valid_queen_w proc near
  entr 0

  call valid_bishop_w
  mov ax, word ptr [pos]
  xor dx, dx
  call valid_rook_w

  leav
  ret
  endp

valid_queen_b proc near
  entr 0

  call valid_bishop_b
  mov ax, word ptr [pos]
  xor dx, dx
  call valid_rook_b

  leav
  ret
  endp

;;; --------------------------
;;; ---------- KING ----------
;;; --------------------------


valid_king_w proc near
  entr 0

  dec al
  sel_white
  inc ah
  sel_white
  inc al
  sel_white
  inc al
  sel_white
  dec ah
  sel_white
  dec ah
  sel_white
  dec al
  sel_white
  dec al
  sel_white

  leav
  ret
  endp


valid_king_b proc near
  entr 0

  dec al
  sel_black
  inc ah
  sel_black
  inc al
  sel_black
  inc al
  sel_black
  dec ah
  sel_black
  dec ah
  sel_black
  dec al
  sel_black
  dec al
  sel_black

  leav
  ret
  endp

  end
