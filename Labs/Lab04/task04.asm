.model small
.stack 100h
.data
.code
main    proc

start:
    push 5  ; Перше число
    push 3  ; Друге число

    call find_min

    mov ax, 4c00h
    int 21h

main    endp

find_min proc
    ; Збереження регістрів, які можуть змінитися
    push bp
    mov bp, sp

    ; Збереження регістрів AX і BX
    push ax
    push bx

    ; Зчитування параметрів зі стеку
    mov ax, [bp+4] ; Перше число у AX
    mov bx, [bp+6] ; Друге число у BX

    cmp ax, bx
    jle end_find_min  ; Якщо AX <= BX, результат вже в AX.

    ; Якщо AX > BX, тоді поміняти значення
    mov ax, bx

end_find_min:
    ; Відновлення регістрів
    pop bx
    pop ax
    mov sp, bp
    pop bp

find_min endp

end main
