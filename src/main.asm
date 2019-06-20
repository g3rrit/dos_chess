  include std.asm

  public txt_mode_flag
  public exitp

  extrn draw_rect:proc
  extrn draw_filled_rect:proc
  extrn error:proc
  extrn read_bmp:proc
  extrn tileset_load:proc
  extrn tile_draw:proc

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

  push_args <9, 0, 0>
  call tile_draw
  pop_args



  ;; mov ax, vram
  ;; mov es, ax
  ;; draw_px 10, 10, 42

  ;; push_args <10, 15, 3, 3, 49, 100>
  ;; call draw_filled_rect
  ;; pop_args 6

  ;; push_args <30, 15, 3, 3, 49, 100>
  ;; call draw_filled_rect
  ;; pop_args 6


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
