.model small
.stack 100h
.data
    msg db ' ',' ','$'
.code
main    proc
mov ax, SEG @data
mov ds, ax

mov dx, offset msg
mov ah, 9

mov di, offset msg
mov cx, 30h
mov [di], cx

print_loop:
    int 21h
    inc cx
    mov [di], cx
    cmp cx, 3Ah
    jnz print_loop

mov ax, 4c00h
int 21h
main    endp
end main