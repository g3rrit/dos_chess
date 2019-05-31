  ;; gfx util functions

vid_seg = 0a000h

  ;; set video mode to 320 x 200 256 colors vga
  ;; uses { es, ax }
set_video_mode macro
  mov al, 13h
  mov ah, 0
  int 10h
endm

  ;; resets video mode
  ;; uses { ax }
reset_video_mode macro
  mov ax, 3
  int 10h
endm

set_px macro x ,y, color
  mov ax, y
  mov bx, 320
  mul bx
  mov di, ax
  add di, x
  mov al, color
  mov es:[di], al
endm
