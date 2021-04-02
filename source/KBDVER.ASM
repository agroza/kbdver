; ---------------------------------------------------------------------------
; - KBDVER - Keyboard Controller Version (kbdver.asm)                       -
; - Copyright (C) 1998-2021 Alexandru Groza of Microprogramming TECHNIQUES  -
; - All rights reserved.                                                    -
; ---------------------------------------------------------------------------
; - License: GNU General Public License v3.0                                -
; ---------------------------------------------------------------------------

MODEL TINY

CODESEG

STARTUPCODE

  jmp start

; Constants Section
; ---------------------------------------------------------------------------
  sHeader      DB 'KBDVER ù Copyright (C) 2021 Alexandru Groza',13,10,0
  sKeyboardVer DB 'Keyboard controller version: ',0
  sAddition1   DB 'h (',0
  sAddition2   DB ')',13,10,0

; Prints a single character.
; Input:
;     AL - character to print
; Output:
;     none
; Affects:
;     AH, BX
; Preserves:
;     none
; ---------------------------------------------------------------------------
printChar:
  mov ah,0Eh
  mov bx,0007h
  int 10h

  ret

; Prints a null-terminated string.
; Input:
;     SI - pointer to string to print
; Output:
;     none
; Affects:
;     BX
; Preserves:
;     AX
; ---------------------------------------------------------------------------
printString:
  push ax

  mov ah,0Eh
  mov bx,0007h

.repeat:
  lodsb

  cmp al,00h
  je .done
  int 10h

  jmp .repeat

.done:
  pop ax

  ret

; Prints a hexadecimal digit.
; Input:
;     AL - hexadecimal digit to print (0..F)
; Output:
;     none
; Affects:
;     none
; Preserves:
;     AX
; ---------------------------------------------------------------------------
printHexDigit:
  push ax

.continue:
  and al,0Fh
  add al,'0'
  cmp al,'9'
  jna .print
  add al,19h

.print:
  call printChar

  pop ax

  ret

; Prints a hexadecimal number.
; Input:
;     AL - hexadecimal number to print
; Output:
;     none
; Affects:
;     none
; Preserves:
;     AX
; ---------------------------------------------------------------------------
printHexByte:
  push ax

  mov ah,al
  shr al,1
  shr al,1
  shr al,1
  shr al,1

  call printHexDigit

  mov al,ah
  and al,0Fh

  call printHexDigit

  pop ax

  ret

; Waits for the keyboard controller to be ready.
; Input:
;     CX - number of retries
; Output:
;     none
; Affects:
;     AL
; Preserves:
;     CX
; ---------------------------------------------------------------------------
waitKbd:
.try:
  push cx

  xor cx,cx

.poll:
  in al,64h
  test al,1
  loope .poll

  pop cx
  loope .try

  ret

; Main Program Entrypoint
; ---------------------------------------------------------------------------
start:
  lea si,sHeader
  call printString
  lea si,sKeyboardVer
  call printString

  pushf

  cli

  mov al,0A1h
  out 64h,al

  mov cx,1
  call waitKbd
  jz .finish

  in al,60h

  sti

  call printHexByte

  lea si,sAddition1
  call printString

  call printChar

  lea si,sAddition2
  call printString

.finish:
  popf

  mov ax,4C00h
  int 21h

end
