  ;; general purpose util functions

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
