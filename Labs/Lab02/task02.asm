.model small
.stack 100h
.data
    start_number db 34h
    msg db ' $'
.code
main    proc
    mov ax, @data
    mov ds, ax

    ; Check if the start_number is within the range 0-9
    mov al, start_number
    cmp al, '0'
    jb end_program
    cmp al, '9'
    ja end_program

    mov cl, [start_number]

print_loop:
    mov dl, cl
    mov ah, 2
    int 21h

    mov dl, ' '
    int 21h

    inc cl
    cmp cl, '9' + 1
    jnz print_loop

end_program:
    mov ax, 4c00h
    int 21h
main    endp
end main