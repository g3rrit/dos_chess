  .model small
  .486

  extrn stack_arg_count

;;;---------------------------------------
;;;   UTIL_FUNCTIONS
;;;---------------------------------------

locals @@

esc_char = 1bh

word_to_byte macro
  push cx
  mov cx, 4
  shl ah, cl
  or al, ah
  xor ah, ah
  pop cx
  endm

byte_to_word macro
  push cx
  mov ah, al
  and al, 0fh
  mov cx, 4
  shr ah, cl
  pop cx
  endm

;;; ax: src
;;; bx: dest
;;; cx: count
memcpy macro
  push ax
  push bx
  push cx
  mov di, ax
@@loop:
  mov al, byte ptr [di]
  mov byte ptr [bx], al
  inc bx
  inc di
  dec cx
  cmp cx, 0
  jne @@loop

  pop cx
  pop bx
  pop ax
  endm

;;; pushed args to stack
push_args macro args
  mov word ptr [stack_arg_count], 0
  irp a, <args>
      add word ptr [stack_arg_count], 2
      push a
  endm
  push word ptr [stack_arg_count]
  endm

;;; pops count words from stack
pop_args macro
  pop word ptr [stack_arg_count]
  add sp, word ptr [stack_arg_count]
  endm

;;; gets the n-th argument
get_arg macro n
  bp + 6 + n
  endm

;;; gets the n-th variable
get_var macro n
  bp - n
  endm

;;; builds a stack frame with n
;;; local 16bit variables
entr macro n
  push bp
  mov bp, sp
  sub sp, n
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

screen_width = 320
screen_height = 200
screen_size = screen_width * screen_height

indicator_s = 8
indicator_l = 40

board_width = 160
board_height = 160
board_xpos = 80
board_ypos = 20

tile_size = 20

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
