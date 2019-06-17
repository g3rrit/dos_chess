;;;---------------------------------------
;;;   UTIL_FUNCTIONS
;;;---------------------------------------
locals @@

esc_char = 1bh

;;; pushed args to stack
push_args macro args
  xor ax, ax
  irp a, <args>
      push a
      add ax, 2
  endm
  push ax
  endm

;;; pops count words from stack
pop_args macro count
  pop ax
  add sp, ax
  endm

;;; gets the n-th argument
get_arg macro n
  [bp + 6 + 2 * n]
  endm

;;; gets the n-th variable
get_var macro n
  [bp - 2 + n]
  endm

;;; builds a stack frame with n
;;; local 16bit variables
entr macro n
  push bp
  mov bp, sp
  sub sp, n * 2
  endm

leav macro
  mov sp, bp
  pop bp
  endm

;;; saves all registers
save_reg macro args
  push ax
  push bx
  push cx
  push dx
  endm

;;; restores all registers
res_reg macro args
  pop dx
  pop cx
  pop bx
  pop ax
  endm

;;; enables the cursor
;;; uses { ax }
enable_cursor macro
  mov ax, 1
  int 33h
  endm

;;; disables the cursor
;;; uses { ax }
disable_cursor macro
  mov ax, 2
  int 33h
  endm

;;; returns to dos
exit_to_dos macro
  ;; restore text mode
  mov ax, 3
  int 10h

  mov ah, 4ch
  int 21h
  endm

;;;---------------------------------------
;;; GFX_UTIL_FUNCTIONS
;;;---------------------------------------

vram = 0a000h

;;; set video mode to 320 x 200 256 colors vga
;;; uses { es, ax }
set_video_mode macro
  mov al, 13h
  mov ah, 0
  int 10h
endm

;;; resets video mode
;;; uses { ax }
set_txt_mode macro
  mov ax, 3
  int 10h
endm

;;; draws a pixel at x y with color c
;;; es needs to be set to vram bevorhand
;;; uses { ax, bx, di }
draw_px macro x ,y, color
  mov ax, y
  mov bx, 320
  mul bx
  mov di, ax
  add di, x
  mov al, color
  mov es:[di], al
endm
