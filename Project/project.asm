.model small
.stack 100h
.data
    oneChar db 0
    buffer db 256 dup(?)  ; Allocate 256 bytes for input buffer
    bufIndex dw 0          ; Pointer to the next free position in the buffer
.code
main PROC
read_next:
    mov ah, 3Fh          ; DOS interrupt for reading from file (stdin here)
    mov bx, 0            ; File handle for stdin
    mov cx, 1            ; Number of bytes to read (1 character)
    mov dx, offset oneChar ; Read character into oneChar
    int 21h              ; Perform interrupt

    or ax, ax            ; Check if any bytes were read (AX == 0 means EOF)
    jz end_read          ; If zero, we reached EOF (stop reading)

    ; Save the character to the buffer
    mov si, offset bufIndex ; Get the current index in the buffer
    mov di, offset buffer   ; Base address of the buffer
    mov bx, word ptr [si]   ; Load buffer index
    mov al, oneChar         ; Load the character
    mov [di + bx], al       ; Save oneChar into buffer
    inc word ptr [si]       ; Increment buffer index

    ; Check for buffer overflow
    cmp word ptr [si], 256  ; If index >= 256, stop reading
    jae end_read

    jmp read_next           ; Continue reading

end_read:
    ; Add a null terminator to the buffer (if needed for ASCIIZ strings)
    mov si, offset bufIndex ; Get current buffer index
    mov di, offset buffer   ; Base address of the buffer
    mov bx, word ptr [si]
    mov [di + bx], 0        ; Add null terminator

    ; Exit program
    mov ax, 4C00h
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