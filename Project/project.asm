.model small
.stack 100h
.data
    oneChar db 0
    buffer db 256 dup(?)  ; Allocate 256 bytes for input buffer
    bufIndex dw 0          ; Pointer to the next free position in the buffer
    substring db 256 dup(?)  ; Allocate 256 bytes for substring
.code 
main PROC
    ; Save the PSP segment in ES
    mov ax, ds          ; Save the initial value of DS (PSP segment)
    mov es, ax          ; Store it in ES for later use
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
    mov [di + bx], al       ; Save oneChar into buffer
    inc word ptr [si]       ; Increment buffer index
    cmp word ptr [si], 256  ; If index >= 256, stop reading
    jae end_read
    
    jmp read_next

end_read:
    ; Add a null terminator to the buffer (if needed for ASCIIZ strings)
    mov si, offset bufIndex ; Get current buffer index
    mov di, offset buffer   ; Base address of the buffer
    mov bx, word ptr [si]
    mov byte ptr [di + bx], 0        ; Add null terminator
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
end main