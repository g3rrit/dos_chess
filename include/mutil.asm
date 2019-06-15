  ;; general purpose util functions

locals l_

esc_char = 1bh

  ;; pushed args to stack
push_args macro args
  irp r, <args>
      push r
  endm
  endm

  ;; pops count words from stack
pop_args macro count
  add sp, 2 * count
  endm

  ;; enables the cursor
  ;; uses { ax }
enable_cursor macro
  mov ax, 1
  int 33h
  endm

  ;; disables the cursor
  ;; uses { ax }
disable_cursor macro
  mov ax, 2
  int 33h
  endm

  ;; returns to dos
exit_to_dos macro
  ;; restore text mode
  mov ax, 3
  int 10h

  mov ah, 4ch
  int 21h
  endm

  ;; gfx util functions

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
