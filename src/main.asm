  include std.asm

  public txt_mode_flag
  public exitp

  extrn draw_rect:proc
  extrn draw_filled_rect:proc
  extrn error:proc
  extrn read_bmp:proc
  extrn tileset_load:proc
  extrn tile_draw:proc
  extrn draw_board:proc
  extrn board_init:proc
  extrn board_move:proc

  extrn piece_at:proc

  .data

txt_mode_flag db 0

  .code

;;; init procedure
;;; called at the start of
;;; execution.
;;; sets ds to datasegment
;;; and es to vram
initp proc near
  set_video_mode

  ;; move dataseg to ds
  mov ax, @data
  mov ds, ax

  ;; move vram (0a000h) to es
  ;; this shouldnt change
  mov ax, vram
  mov es, ax

  ;; load tileset
  call tileset_load

  ;; initialize board
  call board_init

  ret
  endp

;;; procedure called on exit
exitp proc near
  ;; check if other proc (error) has
  ;; already set txt mode
  mov al, [byte ptr txt_mode_flag]
  cmp al, 0
  jne @@txt_mode_set
  set_txt_mode
@@txt_mode_set:

  ;; return to dos
  mov ah, 4ch
  int 21h

  ret
  endp

;;; main proc
main:
  call initp

  ;; -- TESTING --

  call draw_board

  mov ah, 0
  int 16h

  mov ah, 066h
  mov al, 044h

  push_args <ax>
  call board_move
  pop_args

  call draw_board

  mov ah, 0
  int 16h

  mov ah, 0
  int 16h


  ;; -- TESTING --


  ;; loop till esc
inputl:
  mov ah, 0
  int 16h

  cmp al, esc_char
  jne inputl
  ;; -- --------------------------------

  call exitp

;;;---------------------------------------
;;;   STACK_SEGMENT
;;;---------------------------------------
stseg segment stack use16 'stack'
  dw 200h dup (?)
  ends
;;;---------------------------------------

  end main
