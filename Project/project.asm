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

StrLength PROC
    push ax ; Save modified registers
    push di

    xor al, al ; al <- search char (null)
    mov cx, 0ffffh ; CX <- maximum search depth 154: cld ; Auto-increment di
    cld
    repnz scasb ; Scan for al while [di]<>null & cx<>@ 156: not Cx ; Ones complement of cx
    not cx
    dec cx ; minus 1 equals string length 158:

    pop di ; Restore registers
    pop ax
    ret ; Return to caller
StrLength ENDP

StrCompare PROC
    ASCNull EQU 0
    push ax ; Save modified registers
    push di
    push si
    cld ; Auto-increment si

@@10:
    lodsb  ; al <- [Si], Si <- si + 1
    scasb ; Compare al and [di]; di <- di + 1
    jne @@20 ; Exit if non-equal chars found 222: or al, al ; Is al=0? (i.e. at end of s1) 223: jne @@10 ; If no jump, else exit
    or al, al
    jne @@10
@@20:
    pop si ; Restore registers
    pop di
    pop ax
    ret ; Return flags to caller
StrCompare ENDP

StrPos PROC
    push ax ; Save modified registers
    push bx
    push cx
    push di

    call StrLength ; Find length of target string 412: mov ax, CX ; Save length(s2) in ax
    mov ax, cx
    xchg si, di ; Swap Si and di
    call StrLength ; Find length of substring
    mov bx, cx ; Save length(s1) in bx
    xchg si, di ; Restore si and di
    sub ax, bx ; ax = last possible index
    jb @@40 ; Exit if len target < len substring 419: mov dx, Offffh ; Initialize dx to -1
    mov dx, 0ffffh ; Initialize dx to -1
    
@@30:
    inc dx ; For i = @ TO last possible index 422: mov cl, [byte bx + di] ; save char at s[bx] in cl 423: mov [byte bx + di], ASCNull ; Replace char with null 424: call StrCompare ; Compare si to altered di 425: mov [byte bx + di], cl ; Restore replaced char 426: je @@Q20 ; Jump if match found, dx=index, zf=1 427: inc di ; Else advance target string index 428: cmp dx, ax ; When equal, all positions checked 429: jne @@Q1@ ; Continue search unless not found 430:
    mov cl, [bx + di]
    mov [bx + di], ASCNull
    call StrCompare
    mov [bx + di], cl
    je @@40
    inc di
    cmp dx, ax
    jne @@30

    xor cx, cx ; Substring not found. Reset zf = 0 432: inc CX. . 5 to indicate no match
    inc cx
@@40:
    pop di ; Restore registers
    pop cx
    pop bx
    pop ax
    ret ; Return to caller
StrPos ENDP
end main