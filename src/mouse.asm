;;; This File basically creates an interface to a blocking mouse proc

  include std.asm

  public mouse_get_pos
  public mouse_delete
  public mouse_init


  .data

mouse_pos_x dw 0
mouse_pos_y dw 0

;;; flag the regulates access to the mouse pos vars
;;;  0 - mouse position is not set
;;;  1 - mouse position is set
;;;  2 - mouse position is being handled
mouse_flag db 0

  .code

;;; this function blocks until
;;; a left mouse click is registered
;;; args: empty
;;; returns:
;;;  ax - xpos bx - ypos
mouse_get_pos proc near
  entr 0

  xor ax, ax
  xor bx, bx

@@check_mouse:
  cmp byte ptr [mouse_flag], 0
  je @@check_mouse
  cmp byte ptr [mouse_flag], 1
  je @@mouse_set

;;; TODO: invalid mouse flag
  jmp @@check_mouse

@@mouse_set:
  mov byte ptr [mouse_flag], 2
  mov ax, word ptr [mouse_pos_x]
  mov bx, word ptr [mouse_pos_y]
  mov byte ptr [mouse_flag], 0

  leav
  ret
  endp

;;; mouse interrupt that writes xpos and ypos
mouse_int proc far

  push ds

  ;; move current datasegment to ds
  mov ax, @data
  mov ds, ax

  ;; dont set mouse pos if it currently being used
  cmp byte ptr [mouse_flag], 2
  je @@done

  ;; cx - xpos 640
  ;; dx - ypos 200

  mov byte ptr [mouse_flag], 0
  mov word ptr [mouse_pos_x], cx
  mov word ptr [mouse_pos_y], dx
  mov byte ptr [mouse_flag], 1

@@done:

  pop ds
  ret
  endp


;;; registers the mouse interrupt proc
;;; and enables the cursor
mouse_init proc near
  entr 0

  ;; enable cursor
  mov ax, 1
  int 33h

  push es

  ;; register mouse proc onclick
  mov ax, 0ch
  mov cx, 2ah
  push cs
  pop es
  mov dx, offset mouse_int
  int 33h

  pop es

  leav
  ret
  endp


;;; deregisters the mouse interrupt and
;;; disables cursor
mouse_delete proc near
  entr 0

  mov ax, 0
  int 33h

  leav
  ret
  endp


  end
