.model huge
.386

.data

.code

include src\gfxutil.asm
include src\util.asm

main:
  set_video_mode

  mov ax, vram
  mov es, ax
  draw_px 10, 10, 42

  push 10
  push 15
  push 3
  push 3
  push 49
  push 100
  call draw_filled_rect

  ;; loop till esc
inputl:
  mov ah, 0
  int 16h

  cmp al, esc_char
  jne inputl


  reset_video_mode
  exit_to_dos

.stack 100h

end main
