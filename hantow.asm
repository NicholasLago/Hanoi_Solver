%include "asm_io.inc"

SECTION .data

; Initialize pegs

; setup from Lab 4 b

peg1: dd 0,0,0,0,0,0,0,0,9
peg2: dd 0,0,0,0,0,0,0,0,9
peg3: dd 0,0,0,0,0,0,0,0,9

Base: db "   XXXXXXXXXXXXXXXXXXX      XXXXXXXXXXXXXXXXXXXX      XXXXXXXXXXXXXXXXXXXX", 10, 0

; setup from Lab 4 a

err1: db "Incorrect Number of Arguments", 10, 0
err2: db "Out Of Range", 10, 0


SECTION .bss

; Lab 4 b

line: resb 80
N: resd 3

SECTION .test

	global  asm_main

; Display of arrays from Lab a
display_array:


   enter 0,0             ; setup routine
   pusha                 ; save all registers

   mov eax, [ebp+8]      ; the parameter
   mov ebx, peg1 	;peg1 is our array
   mov ecx, dword 8     ;8 disks
   sub ecx, eax  ; The difference between our total (8 pegs) and the given (2-8) is 
   ; where we should end
   mov eax, ecx     ; now the difference is in eax 


   display:
   ; ebx points to the beginning of the array
   ; we will use ecx to control the counting loop

   mov ecx, dword 1


   DISPLAYLOOP:  ; has to be named different, already have LOOP
   cmp eax, ecx
   ; 
    ja EmptyFill
	; Count has to be ABOVE the difference at this point (if they input 3, difference is 5
	; count is now above the difference, these are NOT empty spots this is where disks go.
mov edx, ecx    ; make a copy of ecx so we wont lose count
sub ecx, eax    ; the difference in count and (8- input)
mov [ebx], ecx     ; Our printing should be = to the index value
mov ecx, edx      ; putting our count back in place
inc ecx		;counter ++
add ebx, 4		; next index
cmp ecx, dword 9	; is our counter at nine yet?
jbe DISPLAYLOOP 	; if it isn't its time to do it again! this time with 
			; the next index of our array
popa
leave
ret
	EmptyFill:
   ; if the counter is below the difference, we need to put 0's in the disk spaces
   ; this is because it works from the top down, so if our difference is 5 (if they input 3)
   ; 0-5 (from top to bottom) should be 0's
   mov [ebx], dword 0  
   add ebx, 4   ; increment array
   add ecx,dword 1   ; increment count
   jmp DISPLAYLOOP
 
popa
leave
ret




; Error template from Lab 4 a

NotInRange:
mov eax, err2
call print_string
jmp asm_main_end

NotRightBro:
mov eax, err1
call print_string
jmp asm_main_end


; Changed '.' to ' ' to print out what we want. 
; Renamed all loops and L jmps to avoid errors

line1:   
   enter 0,0                ; setup routine
   pusha                    ; save all registers
   mov ebx, [ebp+8]         ; address of N1
   mov ecx, dword [ebx]     ; ecx=N1
   mov [N], ecx             ; remember N1
   add ebx, dword 36        ; address of N2
   mov ecx, dword [ebx]     ; ecx=N2
   mov [N+4],ecx            ; remember N2
   add ebx, dword 36        ; address of N3
   mov ecx, dword [ebx]     ; ecx=N3
   mov [N+8], ecx           ; remember N3
   mov ecx, line            ; pointer to line

 
   mov edi, N
   mov esi, 0
   ANOTHERLOOP: 
     mov ebx, 12
     sub ebx, dword [edi]    ; ebx=number of spaces needed -- 12-N
     mov eax, 0              ; counter
     AL11: cmp eax, ebx
     jae AL12
     mov [ecx], byte ' '
     inc eax
     inc ecx
     jmp AL11 
     ; now we need N pluses
     AL12: mov eax, 0            ; counter
     AL13: cmp eax, dword [edi]
     jae AL14
     mov [ecx], byte '+'
     inc eax
     inc ecx
     jmp AL13
     ; now we need |
     AL14: mov [ecx], byte '|'
     inc ecx
     ; now we need N pluses
     mov eax, 0            ; counter
     AL15: cmp eax, dword [edi]
     jae AL16
     mov [ecx], byte '+'
     inc eax
     inc ecx
     jmp AL15
     ; now we need 12-N spaces, we remembered the value in ebx
     AL16: mov eax, 0            ; counter
     AL17: cmp eax, ebx
     jae ANOTHERLOOP_END
     mov [ecx], byte ' '
     inc ecx
     inc eax
     jmp AL17
  
   ANOTHERLOOP_END: 
   add esi, dword 1
   add edi, 4
   cmp esi, dword 3
   jb ANOTHERLOOP

   ; the line is complete, print it
   mov eax, line
   call print_string
   call print_nl
   
   popa
   leave
   ret



PressEnter:

; from class:
; hantow (m < user input 8, orig < original 12, dest < destinaton 16, help < third array 20)
; move (orig, dest)  base case = 1
; for switching hantow (m-1, orig, help, dest)
;move (orig, dest)
mov eax, 3   ; need this to get key
	mov ebx, 0
	mov edx, 1
	int 80h

; Going to put arrays and input into registers
	jmp Recursion
AfterRec:
	jmp Disks
	
Recursion:
enter 0,0
pusha

;check if base case
cmp dword [ebp+8], 1
je BaseCase 
mov eax, [ebp + 16]
push eax
mov eax, [ebp +20]
push eax
mov eax, [ebp +12]
push eax
mov eax, [ebp + 8]
sub eax, dword 1
push eax
call Recursion
add esp, 16

; move pegs
mov esi, dword 0
jmp MovePeg
AfterJumpMovePeg:
call Disks
AfterDisk:
mov eax, [ ebp + 12]
push eax
mov eax, [ebp + 16]
push eax
mov eax, [ebp + 20]
push eax
mov eax, [ebp + 8]
sub eax, dword 1
push eax
call Recursion
add esp, 16
popa 
leave
ret


BaseCase:
; mov pegs
mov esi, dword 1
jmp MovePeg
BaseCaseAfterPeg:
call Disks
AfterDiskBase:
popa
leave
ret

MovePeg:
mov eax, [ebp+12]  ; orig
mov ebx, [ebp+16]  ; dest
mov ecx, dword 0
ARRAYLOOP:
cmp [eax], dword 0
jne NUMBER
add eax, 4
jmp ARRAYLOOP
NUMBER:
cmp [ebx], dword 0
jne NUMBER2
inc ecx
add ebx, 4
jmp NUMBER
NUMBER2:
sub ebx, 4
mov edi, eax
mov eax, dword [eax]
mov [ebx], eax
mov eax, edi
mov [eax], dword 0

cmp esi, 1
je BaseCaseAfterPeg
jmp AfterJumpMovePeg






asm_main:

enter 0,0
pusha

	; Error testing setup from lab 4 a
  
; checks if two arguements
   mov eax, dword [ebp+8]   ; argc
   cmp eax, dword 2         ; argc should be 2
   Jne NotRightBro



   mov ebx, dword [ebp+12]  ; address of argv[]
   
   mov eax, dword [ebx+4]   ; argv[1]
   mov bl, byte [eax]       ; 1st byte of argv[1]

; Using jump above and jump below we can test our range
   try1: cmp bl, '2'   ; min of 2
   jb NotInRange
 

   try2: cmp bl, '8'
   ja NotInRange

  
   sub bl, '0'
   mov ecx,0
   mov cl, bl               ; so ecx holds either 1 or 2
	mov bl, byte [eax+1] ; 2nd byte of argv[1]
	cmp bl, byte 0
	jne NotInRange
	mov esi, ecx  ; a copy of our arg for recursion
  
	push ecx
	call display_array

	push peg3
	push peg2
	push peg1
	push esi
	call PressEnter
	add esp, 20
	popa
	leave
	ret
; Displaying pegs from Lab 4 b

Disks:
	; 8 height 
	mov eax, peg1
	push eax
	call line1

	mov eax, peg1
	add eax, 4
	push eax
	call line1


	mov eax, peg1
	add eax, 8
	push eax
	call line1
	

	mov eax, peg1
	add eax, 12
	push eax
	call line1
	

	mov eax, peg1
	add eax, 16
	push eax
	call line1
	

	mov eax, peg1
	add eax, 20
	push eax
	call line1
	

	mov eax, peg1
	add eax, 24
	push eax
	call line1
	
	
	mov eax, peg1
	add eax, 28
	push eax
	call line1
	
	
	; 1 base
	mov eax, Base
	call print_string

	
	add esp, 36
	; Press enter
	mov eax, 3   ; need this to get key
	mov ebx, 0
	mov edx, 1
	int 80h
	cmp esi, 1
	je AfterDiskBase
	jmp AfterDisk
	



; Lab 4 a
asm_main_end:
popa
leave
ret 

