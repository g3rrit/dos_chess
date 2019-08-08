  include std.asm

  public board_init
  public board_at_pos
  public board_at
  public board_set_pos
  public board_set
  public board_move

  public board_get_king

  public set_player_white
  public set_player_black
  public get_player

  public set_flag0
  public set_flag1
  public set_flag2
  public set_flag3

  public unset_flag0
  public unset_flag1
  public unset_flag2
  public unset_flag3

  public clear_flag0
  public clear_flag1
  public clear_flag2
  public clear_flag3

  public clear_flags

  public board_save
  public board_restore

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

;;; board
board db 64 dup (0)

board_buf db 64 dup (0)

;;; current_player 0 - white | 1 - black
player db 0

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

;;; saves the state of the board to a
;;; temporary location
board_save proc near
  save_reg
  mov ax, offset board
  mov bx, offset board_buf
  mov cx, 64
  memcpy
  res_reg
  ret
  endp


;;; restores the state of the board
board_restore proc near
  save_reg
  mov ax, offset board_buf
  mov bx, offset board
  mov cx, 64
  memcpy
  res_reg
  ret
  endp

set_flag0 proc near
  push bx
  mov bx, 8
  call set_flag
  pop bx
  ret
  endp

set_flag1 proc near
  push bx
  mov bx, 4
  call set_flag
  pop bx
  ret
  endp

set_flag2 proc near
  push bx
  mov bx, 2
  call set_flag
  pop bx
  ret
  endp

set_flag3 proc near
  push bx
  mov bx, 1
  call set_flag
  pop bx
  ret
  endp

unset_flag0 proc near
  push bx
  mov bx, 8
  call unset_flag
  pop bx
  ret
  endp

unset_flag1 proc near
  push bx
  mov bx, 4
  call unset_flag
  pop bx
  ret
  endp

unset_flag2 proc near
  push bx
  mov bx, 2
  call unset_flag
  pop bx
  ret
  endp

unset_flag3 proc near
  push bx
  mov bx, 1
  call set_flag
  pop bx
  ret
  endp

clear_flag0 proc near
  push bx
  mov bx, 8
  call clear_flag
  pop bx
  ret
  endp

clear_flag1 proc near
  push bx
  mov bx, 4
  call clear_flag
  pop bx
  ret
  endp

clear_flag2 proc near
  push bx
  mov bx, 2
  call clear_flag
  pop bx
  ret
  endp

clear_flag3 proc near
  push bx
  mov bx, 1
  call clear_flag
  pop bx
  ret
  endp

;;; sets flag in board
;;; args:
;;;     ax: pos
;;;     bx: flag
set_flag proc near
  push ax
  push cx
  push bx
  mov cx, ax
  call board_at
  cmp ax, 0ffffh
  je @@done

  or ah, bl
  mov bx, ax
  mov ax, cx
  call board_set

@@done:
  pop bx
  pop cx
  pop ax
  ret
  endp

;;; clears flag
;;; args:
;;;     ax: pos
;;;     bx: flag
unset_flag proc near
  push ax
  push cx
  push bx
  mov cx, ax
  call board_at
  cmp ax, 0ffffh
  je @@done

  xor bl, 0fh
  and ah, bl
  mov bx, ax
  mov ax, cx
  call board_set

@@done:
  pop bx
  pop cx
  pop ax
  ret
  endp

;;; clears the complete board from the specific flag
;;; args:
;;;     ax: pos
;;;     bx: flag
clear_flag proc near
  push ax
  push bx
  push cx
  mov bx, cx

  mov bx, 0
@@loop:
  mov ax, bx
  board_pos_xy
  push bx
  mov bx, cx
  call unset_flag
  pop bx
  inc bx
  cmp bx, 64
  jne @@loop

  pop cx
  pop bx
  pop ax
  ret
  endp

;;; clears all flags
clear_flags proc near
  push ax
  push bx

  mov bx, 0
@@loop:
  mov ax, bx
  board_pos_xy
  push bx
  mov bx, 0fh
  call unset_flag
  pop bx
  inc bx
  cmp bx, 64
  jne @@loop

  pop bx
  pop ax
  ret
  endp


set_player_white proc near
  mov byte ptr [player], 0
  ret
  endp

set_player_black proc near
  mov byte ptr [player], 1
  ret
  endp

get_player proc near
  xor ax, ax
  mov al, byte ptr [player]
  ret
  endp

;;; initializes board
board_init proc near
  entr 0
  push bx

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

  pop bx
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
  save_reg

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

  res_reg
  leav
  ret
  endp

;;; returns the state of kind of
;;; args:
;;;     ax: 0 white king
;;;     ax: 1 black king
board_get_king proc near
  entr 0
  push bx
  push cx
  push dx

  mov bx, ax
  mov ax, 0
  mov cx, 0

  cmp bx, 0
  je @@white

  ;; black king
@@black:
  call board_at_pos
  cmp al, 0eh
  je @@done
  inc cx
  mov ax, cx
  jmp @@black

  ;; white king
@@white:
  call board_at_pos
  cmp al, 6
  je @@done
  inc cx
  mov ax, cx
  jmp @@white

@@done:
  pop dx
  pop cx
  pop bx
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
  push ax
  push bx

  push ax
  mov ax, bx
  pop bx

  word_to_byte

  add bx, offset board
  mov byte ptr [bx], al

  pop bx
  pop ax
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
  cmp ah, 8
  jnc @@invalid_pos
  cmp al, 8
  jnc @@invalid_pos

  board_xy_pos
  call board_at_pos

  jmp @@done

@@invalid_pos:
  mov ax, 0ffffh
@@done:
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
