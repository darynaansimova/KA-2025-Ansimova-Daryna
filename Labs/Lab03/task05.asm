.model small
.stack 100h
.code
main    proc

mov ax, 255
mov dx, 0

xor ax, dx ;replace bits that are the same with 0
xor dx, ax ;we cancel out all the dx information, now dx contains the original ax
xor ax, dx ;we cancel out all the ax information, now ax contains the original dx

mov ax, 4c00h
int 21h
main    endp
end main