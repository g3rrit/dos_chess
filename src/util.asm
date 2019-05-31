  ;; general purpose util functions

esc_char = 1bh

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
  mov ah, 4ch
  int 21h
endm
