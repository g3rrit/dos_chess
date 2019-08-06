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

  public get_move_count
  public reset_move_count

  public select_moves

  .data

move_count db 0

  .code

;;; returns count of possible moves
get_move_count proc near
  xor ah, ah
  mov al, byte ptr [move_count]
  ret
  endp

reset_move_count proc near
  mov byte ptr [move_count], 0
  ret
  endp


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

  ;; calculate all valid moves
  mov ax, offset set_flag1
  call valid_all

  cmp cl, 8
  jc @@white

  ;; check for black king
  mov ax, 1
  call board_get_king
  jmp @@next

  ;; check for white king
@@white:
  mov ax, 0
  call board_get_king

@@next:
  cmp ah, board_flag1
  je @@not_set

  call board_restore

  mov ax, bx
  call set_flag0

  inc byte ptr [move_count]

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
valid_all proc near
  entr 0
  save_reg

  xor cx, cx
  xor dx, dx

  mov bx, ax

  xor ax, ax
@@col:
  call valid_moves
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


  end
