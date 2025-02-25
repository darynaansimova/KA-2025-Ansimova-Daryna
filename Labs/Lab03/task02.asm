.model small
.stack 100h
.data
    a dw 13
    b db -30
.code
main    proc

mov ax, @data
mov ds, ax

mov ax, a
mov bl, b

test bl, bl
jns addition

negative:
    or bx, 0FF00h
addition:
    add ax, bx
    jns end_program
neg_res:
    not ax
    inc ax
    mov a, ax
end_program:
    mov ax, 4c00h
    int 21h
main    endp
end main