  .model small
  .386

  .stack 100h

  .data

  .code

  include mutil.asm

  extrn draw_rect:proc
  extrn draw_filled_rect:proc
  extrn error:proc
  extrn read_bmp:proc

main:
  set_video_mode

  call read_bmp
  mov ah, 4ch
  int 21h

  mov ax, 1
  call error

  mov ax, vram
  mov es, ax
  draw_px 10, 10, 42

  push_args <10, 15, 3, 3, 49, 100>
  call draw_filled_rect
  pop_args 6

  push_args <30, 15, 3, 3, 49, 100>
  call draw_filled_rect
  pop_args 6


  ;; loop till esc
inputl:
  mov ah, 0
  int 16h

  cmp al, esc_char
  jne inputl

  exit_to_dos

  end main
