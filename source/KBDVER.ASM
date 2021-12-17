; ---------------------------------------------------------------------------
; - KBDVER - Keyboard Controller Version (kbdver.asm)                       -
; - Copyright (C) 1998-2021 Alexandru Groza of Microprogramming TECHNIQUES  -
; - All rights reserved.                                                    -
; ---------------------------------------------------------------------------
; - License: GNU General Public License v3.0                                -
; ---------------------------------------------------------------------------

LOCALS @@

P8086
MODEL TINY

CODESEG
  org 100h

STARTUPCODE

  jmp @start

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
printChar proc

  mov ah,0Eh
  mov bx,0007h
  int 10h

  ret

printChar endp

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
printString proc

  push ax

  mov ah,0Eh
  mov bx,0007h

@@repeat:
  lodsb

  or al,al
  jz @@exit
  int 10h

  jmp @@repeat

@@exit:
  pop ax

  ret

printString endp

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
printHexDigit proc

  push ax

@@continue:
  and al,0Fh
  add al,'0'
  cmp al,'9'
  jna @@print
  add al,19h

@@print:
  call printChar

  pop ax

  ret

printHexDigit endp

; Prints a hexadecimal number.
; Input:
;     AL - hexadecimal number to print
; Output:
;     none
; Affects:
;     CL
; Preserves:
;     AX
; ---------------------------------------------------------------------------
printHexByte proc

  push ax

  mov ah,al
  mov cl,04h
  shr al,cl

  call printHexDigit

  mov al,ah
  and al,0Fh

  call printHexDigit

  pop ax

  ret

printHexByte endp

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
waitKbd proc

@@try:
  push cx

  xor cx,cx

@@poll:
  in al,64h
  test al,01h
  
  loope @@poll

  pop cx

  loope @@try

  ret

waitKbd endp

; Main Program Entrypoint
; ---------------------------------------------------------------------------
@start:
  lea si,sHeader
  call printString
  lea si,sKeyboardVer
  call printString

  pushf

  cli

  mov al,0A1h
  out 64h,al

  mov cx,01h
  call waitKbd
  jz @exit

  in al,60h

  call printHexByte

  lea si,sAddition1
  call printString

  call printChar

  lea si,sAddition2
  call printString

@exit:
  sti

  popf

  mov ax,4C00h
  int 21h

end
