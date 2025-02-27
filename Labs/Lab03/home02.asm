.model small
.stack 100h
.data
    a dw 30
    b dw 400
    c dw 120
.code
main    proc

mov ax, @data
mov ds, ax

mov ax, a
mov bx, b
mov cx, c

; if ((a < b && b > c)||(a < 10 && c >= b && a <= b)){
;   if (a != 40){
;     a = b + c
;   }
;   b = a & c
;}
; else{
;   a = 0
;   b = 1
;}

comp1:
cmp ax, bx ;(a < b)
jnb comp2 ;if (a < b) = false then goto comp2
cmp bx, cx ;(b > c)
jna comp2 ;if (b > c) = false then goto comp2
ja comp11
comp2:
cmp ax, 10d ;a < 10
jnb comp1_else
cmp cx, bx ;c >= b
jb comp1_else
cmp ax, bx ;a <= b
ja comp1_else
comp11:
cmp ax, 40d ;(a != 40)
jz comp12 ;if (a != 40) = false then goto next
add bx, cx 
mov ax, bx ;a = b + c
sub bx, cx
comp12: ;next:
mov dx, ax
and dx, cx
mov bx, dx ;b = a & c
jmp assign_vars

comp1_else:
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