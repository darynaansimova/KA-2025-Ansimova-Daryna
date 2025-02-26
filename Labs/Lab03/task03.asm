.model small
.stack 100h
.data
    a dw 1
    b dw 10b
.code
main    proc

mov ax, @data
mov ds, ax

mov ax, a
mov bx, b

and ax, bx
cmp ax, bx
jnz not_eq
mov a, 1
jmp end_program

not_eq:
mov a, 0
end_program:
    mov ax, 4c00h
    int 21h
main    endp
end main