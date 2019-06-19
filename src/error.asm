  include std.asm

  public error

  extrn txt_mode_flag
  extrn exitp:proc

.data

undefined_err db "undefined error$"
file_err      db "file io error$"
file_open_err db "error opening file$"
file_read_err db "error reading from file$"

err_table dw undefined_err, file_err, file_open_err, file_read_err

.code


;;; prints_error and exits to dos
;;; error message should be in ax
;;; uses { ax, bx, ds, dx }
error proc near
  mov bx, ax
  ;; set text mode
  mov ax, 3
  int 10h

  shl bx, 1
  add bx, offset err_table
  mov dx, bx

  ;; print to screen
  mov dx, [bx]
  mov ah, 09h
  int 21h

  set_txt_mode
  mov al, 1
  mov [byte ptr txt_mode_flag], al

  call exitp
  endp

  end
