.model small
.stack 100h
.data
    a dw 40
    b dw 400
    c dw 1200
.code
main    proc

mov ax, @data
mov ds, ax

mov ax, a
mov bx, b
mov cx, c

; if ((a < b) && (b > c))
;   if (a != c)
;     a = b + c
;   else
;     b = a & c
; else
;   a = 0
;   b = 1

comp1:
cmp ax, bx ;(a < b)
jnb comp2 ;if (a < b) = false then goto else
cmp bx, cx ;(b > c)
jna comp2 ;if (b > c) = false then goto else
comp11:
cmp ax, cx ;(a != c)
jz comp12 ;if (a != c) = false then goto else
add bx, cx 
mov ax, bx ;a = b + c
sub bx, cx
jmp assign_vars
comp12: ;else:
mov dx, ax
and dx, cx
mov bx, dx ;b = a & c
jmp assign_vars

comp2:
mov ax, 0 ;a = 0
mov bx, 1 ;b = 1

assign_vars:
mov a, ax
mov b, bx
mov c, cx

end_program:
    mov ax, 4c00h
    int 21h
main    endp
end main