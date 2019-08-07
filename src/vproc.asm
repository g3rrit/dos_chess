include std.asm
include boardm.asm

  extrn valid_moves:proc

  extrn set_flag0:proc

  extrn board_save:proc
  extrn board_restore:proc

  extrn board_at:proc
  extrn board_move:proc

  extrn set_flag1:proc

  extrn board_get_king:proc

  public select_moves

  public checkmate_w
  public checkmate_b

  .data

move_count dw 0

  .code


;;; procedure that gets
;;; called if a move could be valid
select_moves proc near
  entr 0
  save_reg

  call board_save

  push ax
  mov ax, bx
  pop bx
  ;; src in ax
  ;; dst in bx

  ;; save piece to cx
  push ax
  call board_at
  mov cx, ax
  pop ax

  call board_move

  ;; set proc for valid moves
  mov ax, offset set_flag1

  cmp cl, 8
  jc @@white

  ;; check for black king and all white moves
  call valid_all_w
  mov ax, 1
  call board_get_king
  jmp @@next

  ;; check for white king and all black moves
@@white:
  call valid_all_b
  mov ax, 0
  call board_get_king

@@next:
  cmp ah, board_flag1
  je @@not_set

  call board_restore

  mov ax, bx
  call set_flag0

  jmp @@done

@@not_set:
  call board_restore

@@done:

  res_reg
  leav
  ret
  endp

;;; procedure that
;;; counts if a move is possible
count_moves proc near
  entr 0
  save_reg

  call board_save

  push ax
  mov ax, bx
  pop bx
  ;; src in ax
  ;; dst in bx

  ;; save piece to cx
  push ax
  call board_at
  mov cx, ax
  pop ax

  call board_move

  ;; set proc for valid moves
  mov ax, offset set_flag1

  cmp cl, 8
  jc @@white

  ;; check for black king and all white moves
  call valid_all_w
  mov ax, 1
  call board_get_king
  jmp @@next

  ;; check for white king and all black moves
@@white:
  call valid_all_b
  mov ax, 0
  call board_get_king

@@next:
  cmp ah, board_flag1
  je @@not_set

  call board_restore

  inc word ptr [move_count]

  jmp @@done

@@not_set:
  call board_restore

@@done:

  res_reg
  leav
  ret
  endp

;;; calculates all valid moves for all positions
;;; args:
;;;     ax: proc
;;;     bx: color 0 - white 8 - black
valid_all proc near
  entr 0
  save_reg

  xor cx, cx

  mov dx, bx

  mov bx, ax

  xor ax, ax
@@col:
  ;; check for piece color
  push ax
  call board_at
  and ax, 8
  xor ax, dx
  pop ax
  jnz @@skip

  call valid_moves
@@skip:
  inc ah
  cmp ah, 8
  jc @@col

  mov ah, 0

  inc al
  cmp al, 8
  jc @@col

  res_reg
  leav
  ret
  endp

;;; gets all valid moves for black
;;; args:
;;;     ax: proc
valid_all_b proc near
  push bx
  mov bx, 8
  call valid_all
  pop bx
  ret
  endp

;;; gets all valid moves for white
;;; args:
;;;     ax: proc
valid_all_w proc near
  push bx
  mov bx, 0
  call valid_all
  pop bx
  ret
  endp

;;; checks if player is checkmate
;;; args:
;;;     ax: color 0 - white 8 - black
;;; returns:
;;;     ax: 0 - checkmate | !0 - not
checkmate proc near
  entr 0
  push bx
  push cx
  push dx

  mov bx, ax

  ;; set the movecount to 0
  mov word ptr [move_count], 0

  mov ax, offset count_moves
  cmp bx, 0
  je @@white

  ;; black
  call valid_all_b
  jmp @@next

  ;; white
@@white:
  call valid_all_w

@@next:

  ;; get move count
  mov ax, word ptr [move_count]

  pop dx
  pop cx
  pop bx
  leav
  ret
  endp

;;; check if white is checkmate
;;; returns:
;;;     ax: 0 - checkmate | !0 - not
checkmate_w proc near
  mov ax, 0
  call checkmate
  ret
  endp

;;; check if black is checkmate
;;; returns:
;;;     ax: 0 - checkmate | !0 - not
checkmate_b proc near
  mov ax, 8
  call checkmate
  ret
  endp

  end
