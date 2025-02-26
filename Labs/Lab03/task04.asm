.model small
.stack 100h
.code
main    proc

xor dx, dx
;every bit of dx is the same as dx, because it is the same number,
;so of one dx's bits is 1, xor dx,dx makes it 0, and if it is 0, it remains 0

end_program:
    mov ax, 4c00h
    int 21h
main    endp
end main