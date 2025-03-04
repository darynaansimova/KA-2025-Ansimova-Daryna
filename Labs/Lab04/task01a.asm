.model small
.stack 100h
.data
    msg dw 16 dup(3)
.code
main    proc

mov ax, @data
mov ds, ax
mov dx, offset msg

mov bx, 2
mov cx, 3

loop1:
    add [msg+bx], cx
    add cx, 3
    inc bx
    inc bx
    cmp bx, 32
    jnz loop1

xor bx, bx
cleanup:
    mov [msg+bx], 0
    inc bx
    cmp bx, 32
    jl cleanup

mov [msg+2], 1
mov bx, 4
fibonacci:
    mov cx, [msg+bx-4]
    add cx, [msg+bx-2]
    mov [msg+bx], cx
    inc bx
    inc bx
    cmp bx, 32
    jnz fibonacci

end_program:
    mov ax, 4c00h
    int 21h
main    endp
end main