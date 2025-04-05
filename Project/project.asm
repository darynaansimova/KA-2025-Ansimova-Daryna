.model small
.stack 100h
.data
    oneChar db 0
    buffer db 256 dup(?)  ; Allocate 256 bytes for input buffer
    bufIndex dw 0          ; Pointer to the next free position in the buffer
    substring db 256 dup(?)  ; Allocate 256 bytes for substring
    indexes dw 100 dup(?) ; Array to store indexes of strings
    strIndex dw 0         ; Pointer to the next free position in the indexes array
    occurences dw 100 dup(?) ; Array to store occurrences of strings
.code 
main PROC
    ; Save the PSP segment in ES
    mov ax, ds          ; Save the initial value of DS (PSP segment)
    mov es, ax          ; Store it in ES for later use

    ; Set up DS for the data segment
    mov ax, @data
    mov ds, ax

    xor ch,ch
    mov cl, es:[80h]   ; at offset 80h length of "args"

write_substring:
    mov si, 81h        ; Set SI to the offset of the first character of "args"
    mov al, es:[si]     ; Load the first character
    cmp al, 20h         ; Check if it's a space (ASCII 0x20)
    jne skip_space      ; If not a space, skip the adjustment
    inc si              ; Skip the space
    dec cl              ; Adjust the length to exclude the space

skip_space:
    test cl, cl
    jz write_end        ; Exit the loop if CL is zero

write_loop:
    mov dl, es:[si]     ; Load the current character from the PSP
    mov substring[bx], dl ; Store the character in the substring
    inc bx              ; Increment the substring index
    inc si              ; Move to the next character
    dec cl              ; Decrement the character count
    jnz write_loop      ; Repeat the loop if CL is not zero

write_end:
    mov byte ptr substring[bx], 0 ; Add null terminator to substring
    LEA SI, substring      ; Load address of substring into SI

read_next:
    mov ah, 3Fh
    mov bx, 0h  ; stdin handle
    mov cx, 1   ; 1 byte to read
    mov dx, offset oneChar   ; read to ds:dx 
    int 21h   ;  ax = number of bytes read

    or ax, ax
    jz end_read ; If zero, we reached EOF (stop reading)

    mov si, offset bufIndex ; Get the current index in the buffer
    mov di, offset buffer   ; Base address of the buffer
    mov bx, word ptr [si]   ; Load buffer index
    mov al, oneChar         ; Load the character

    cmp al, 0dh ; Check if the character is a carriage return (CR)
    jz end_string ; If it is, stop reading
    cmp al, 0ah ; Check if the character is a line feed (LF)
    jz read_next ; If it is, continue reading

    mov [di + bx], al       ; Save oneChar into buffer
    inc word ptr [si]       ; Increment buffer index
    cmp word ptr [si], 256  ; If index >= 256, stop reading
    jae end_read
    
    jmp read_next

end_string:
    ; If we reach here, we have a complete string in the buffer
    ; Add a null terminator to the buffer (if needed for ASCIIZ strings)
    mov si, offset bufIndex ; Get current buffer index
    mov di, offset buffer   ; Base address of the buffer
    mov bx, word ptr [si]
    mov byte ptr [di + bx], 0

    push si
    push di
    push bx
    push ax

    mov si, offset substring ; Get the current index in the buffer
    mov di, offset buffer    ; Base address of the buffer
    call strCount            ; Get the number of occurrences of substring in buffer

    mov bx, offset occurences ; Base address of the occurrences array
    mov ax, word ptr [strIndex] ; Load the current index from strIndex
    shl ax, 1                 ; Multiply by 2 (word size) to get the correct offset
    add bx, ax                ; Add the offset to BX
    mov word ptr [bx], cx     ; Store the count in the occurrences array
    
    mov si, offset strIndex ; Get the current index in the buffer
    mov di, offset indexes  ; Base address of the indexes array
    mov ax, word ptr [si]   ; Load the current index from strIndex
    add di, ax              ; Add the offset to DI
    add di, ax
    mov word ptr [di], ax   ; Store the index in the indexes array
    inc word ptr [si] ; Increment the index for the next occurrence
    
    pop ax
    pop bx
    pop di
    pop si

    push di
    push si
    mov di, offset buffer
    mov si, bufIndex
    call clear
    pop si
    pop di

    ;clear the buffer for the next read
    xor bx, bx ; Clear the buffer index
    mov word ptr [si], 0 ; Reset buffer index to 0

    jmp read_next ; Continue reading the next character
end_read:
    ; Add a null terminator to the buffer (if needed for ASCIIZ strings)
    mov si, offset bufIndex ; Get current buffer index
    mov di, offset buffer   ; Base address of the buffer
    mov bx, word ptr [si]
    mov byte ptr [di + bx], 0        ; Add null terminator

    mov si, offset substring ; Get the current index in the buffer
    mov di, offset buffer    ; Base address of the buffer
    call strCount            ; Get the number of occurrences of substring in buffer

    mov bx, offset occurences ; Base address of the occurrences array
    mov ax, word ptr [strIndex] ; Load the current index from strIndex
    shl ax, 1                 ; Multiply by 2 (word size) to get the correct offset
    add bx, ax                ; Add the offset to BX
    mov word ptr [bx], cx     ; Store the count in the occurrences array
    
    mov si, offset strIndex ; Get the current index in the buffer
    mov di, offset indexes  ; Base address of the indexes array
    mov ax, word ptr [si]   ; Load the current index from strIndex
    add di, ax              ; Add the offset to DI
    add di, ax
    mov word ptr [di], ax   ; Store the index in the indexes array
; now we have two arrays: indexes and occurences
; we need to sort the indexes array and the occurences array

    mov cx, word ptr [strIndex] ; Get the number of elements in the indexes array
    inc cx ; Increment to include the last element
    mov di, offset occurences ; Base address of the occurences array
    mov si, offset indexes ; Base address of the indexes array
    call sort ; Sort the indexes array
; we now have the arrays sorted
; we need to print the indexes and the occurences arrays

    mov cx, word ptr [strIndex] ; Get the number of elements in the indexes array
    inc cx ; Increment to include the last element
print_loop:
    cmp cx, 0 ; Check if we've printed all elements
    je end_print ; If yes, exit the loop

    mov ax, word ptr [di] ; Load the occurrence from the occurences array
    call to_decimal ; Convert the occurrence to decimal and print it
    mov ah, 02h
    mov dl, ' ' ; Print a space
    int 21h
    mov ax, word ptr [si] ; Load the index from the indexes array
    call to_decimal ; Convert the index to decimal and print it
    

    mov ah, 02h
    mov dl, 0dh ; Print a cr
    int 21h
    mov ah, 02h
    mov dl, 0ah ; Print a lf
    int 21h

    dec cx ; Decrement the count of elements to print
    add si, 2 ; Move to the next index in the indexes array
    add di, 2 ; Move to the next occurrence in the occurences array
    jmp print_loop ; Repeat the process

end_print:
    mov ax, 4c00h
    int 21h
main ENDP

;description: returns the length of a string in CX.
; input: DS:SI points to the string
; output: CX = length of string
; note: the string must be terminated with a null character.
strLength PROC
str_length:    
    push ax ; Save modified registers
    push di
    xor cx, cx ; Clear CX to count the length
    cld ; Clear direction flag for forward string operations
    mov di, si ; Set DI to point to the start of the string

str_length_loop:
    mov al, [di] ; Load the first character of the string
    cmp al, 0 ; Check if it's the null terminator
    je end_strLength ; If it is, jump to the end
    inc cx ; Increment the length counter

    inc di ; Move to the next character
    jmp str_length_loop ; Repeat the process
end_strLength:
    pop ax ; Restore registers
    pop di ; Restore registers
    ret ; Return to caller    
strLength ENDP

;description: compares two strings.
; input: DS:SI points to the first string, ES:DI points to the second string
; output: AX = 1 if equal, AX = 0 if not equal
; cx = number of chars to compare
StrCompare proc
    push cx
    push di
    push si

compare_loop:
    mov al, [si] ; Load a character from the first string
    mov ah, [di] ; Load a character from the second string
    cmp al, ah   ; Compare the characters
    jne strings_not_equal ; If not equal, jump to not equal

    inc si       ; Move to the next character in the first string
    inc di       ; Move to the next character in the second string
    dec cx
    cmp cx, 0    ; Check if we've compared all characters
    je strings_equal ; If yes, strings are equal
    jmp compare_loop ; Repeat the process

strings_not_equal:
    mov ax, 0    ; Explicitly set AX to 0 (not equal)
    jmp compare_end

strings_equal:
    mov ax, 1    ; Set AX to 1 (equal)

compare_end:
    pop si       ; Restore registers
    pop di
    pop cx
    ret          ; Return to caller
StrCompare ENDP

; get number of times a string appears in another string
; input: ES:DI points to the bigger string, DS:SI points to the smaller string
; output: CX = number of occurrences
strCount proc
    push si
    push di
    push bx
    push ax
    
    push di
    call strLength ; get the length of the smaller string
    pop di

    mov bx, 0 ; clear bx to count occurrences
search_loop:
    call StrCompare ; compare the two strings
    cmp ax, 1 ; check if they are equal
    je found_occurrence ; if equal, jump to found_occurrence

    inc di ; move to the next character in the main string
    cmp byte ptr [di], 0 ; check if we reached the end of the main string
    jne search_loop ; if not, continue searching

    jmp end_search ; jump to end_search
found_occurrence:
    inc bx ; increment the occurrence count
    add di, cx ; move si to the next character after the found substring
    cmp byte ptr [di], 0 ; check if we reached the end of the main string
    jne search_loop ; if not, continue searching
end_search:
    mov cx, bx ; set cx to the number of occurrences
    pop ax
    pop bx
    pop di
    pop si
    ret    
strCount ENDP

; Subroutine to print a 16-bit number in decimal
; Input: AX = number to convert
; Output: Number printed to standard output
to_decimal PROC
    push ax            ; Save AX
    push bx            ; Save BX
    push cx            ; Save CX
    push dx            ; Save DX
    push si
    push di

    mov di, 0          ; CX will count the number of digits
    mov bx, 10         ; Divisor for decimal conversion

convert_loop:
    xor dx, dx         ; Clear DX for division
    div bx             ; AX = AX / 10, remainder in DX
    push dx            ; Push remainder onto stack
    inc di             ; Increment digit count
    test ax, ax        ; Check if AX is 0
    jnz convert_loop   ; If not, continue dividing
    mov si, 0

write_number:
    pop dx             ; Get the last digit from the stack
    add dl, '0'        ; Convert to ASCII
    mov ah, 02h
    int 21h         ; Print the character
    dec di             ; Decrement digit count
    cmp di, 0         ; Check if all digits are printed
    jne write_number    ; If there are more digits, continue

    ; Restore registers
    pop di
    pop si             ; Restore SI
    pop dx             ; Restore DX
    pop cx             ; Restore CX
    pop bx             ; Restore BX
    pop ax             ; Restore AX
    ret
to_decimal ENDP

;description: sort an array of numbers in ascending order.
;cx = number of elements in the array (    mov cx, word ptr count)
;di = address of the first element in the first array
;si = address of the first element in the second array
sort PROC
    push ax
    push bx
    push cx
    push si
    push di

    dec cx  ; count-1
outerLoop:
    push si
    push cx
    mov bx, si
    mov si, di
innerLoop:
    mov ax, [si]
    cmp ax, [si+2]
    jl nextStep
    xchg [si+2], ax
    mov [si], ax

    mov ax, [bx+2]    ; Load the value at [bx+2] into AX
    mov dx, [bx]      ; Load the value at [bx] into DX
    mov [bx+2], dx    ; Store the value from DX into [bx+2]
    mov [bx], ax      ; Store the value from AX into [bx]
nextStep:
    add si, 2
    add bx, 2
    loop innerLoop
    pop cx
    pop si
    loop outerLoop

    pop di
    pop si
    pop cx
    pop bx
    pop ax
    ret
sort ENDP

;description: clear the buffer of 256 bytes.
;input: di = address of the buffer
;       si = number of bytes to clear (256)
;output: buffer is cleared (filled with null characters)
clear PROC
    push ax
    push bx
    push cx
    push di
    push si

    mov bx, 0 ; Clear the buffer index
clear_loop:
    cmp bx, si ; Check if we've cleared the entire buffer
    jg clear_end ; If yes, exit the loop    
    mov byte ptr [di + bx], 0 ; Clear the buffer at the current index
    inc bx ; Increment the buffer index
    jmp clear_loop ; Repeat the process
clear_end:
    pop si
    pop di
    pop cx
    pop bx
    pop ax
    ret
clear ENDP
  
end main