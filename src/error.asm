.model small
.386

.data

undefined_err db "undefined error$"
file_open_err db "error opening file$"
file_read_err db "error reading from file$"

err_table dw undefined_err, file_open_err, file_read_err

.code

  public error

  ;; prints_error and exits to dos
  ;; error message should be in ax
  ;; uses { ax, bx, ds, dx }
error proc near
  mov ax, bx

  mov ax, @data
  mov ds, ax

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

  ;; return to dos
  mov ah, 4ch
  int 21h

  endp

  end
