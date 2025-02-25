.model small
.stack 100h
.code
main    proc

mov ax, 255
mov dx, 0
mov bx, ax
mov ax, dx
mov dx, bx

mov ax, 4c00h
int 21h
main    endp
end main