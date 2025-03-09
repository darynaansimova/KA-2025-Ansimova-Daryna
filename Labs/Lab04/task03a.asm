.model small
.stack 100h
.data
.code
main    proc

start:
    
    push 5  ; Перше число в AX
    push 3  ; Друге число в BX

    call find_min

    mov ax, 4c00h
    int 21h

main    endp

find_min proc
    pop dx ; pop return address
    pop bx
    pop ax
    push dx ; push return address
    cmp ax, bx
    jle end_find_min  ; Якщо AX <= BX, результат вже в AX.

    ; Якщо AX > BX, тоді поміняти значення.
    xchg ax, bx

end_find_min: 
    ret
find_min endp

end main
