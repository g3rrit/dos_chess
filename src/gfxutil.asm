  ;; gfx util functions

locals l_

vram = 0a000h

  ;; set video mode to 320 x 200 256 colors vga
  ;; uses { es, ax }
set_video_mode macro
  mov al, 13h
  mov ah, 0
  int 10h
endm

  ;; resets video mode
  ;; uses { ax }
set_txt_mode macro
  mov ax, 3
  int 10h
endm

  ;; draws a pixel at x y with color c
  ;; es needs to be set to vram bevorhand
  ;; uses { ax, bx, di }
draw_px macro x ,y, color
  mov ax, y
  mov bx, 320
  mul bx
  mov di, ax
  add di, x
  mov al, color
  mov es:[di], al
endm
