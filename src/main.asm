.model huge
.386

.data

.code

include src\gfxutil.asm
include src\util.asm

main:
  set_video_mode

  set_px 10, 10, 42

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
