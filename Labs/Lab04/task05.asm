.model small
.stack 100h
.data
.code
main    proc

start:
    mov ax, 5
    mov bx, 3
    push bx  ; 2 число
    push ax  ; 1 число

    call find_min

    add sp, 4 ; Очистити стек від параметрів

    ; В AX вже міститься результат (менше з двох чисел)

    mov ax, 4c00h
    int 21h

main    endp

find_min proc
    ; Збереження регістрів, які можуть змінитися
    push bp
    mov bp, sp

    ; Збереження регістрів AX і BX
    push bx
    push ax

    ; Зчитування параметрів зі стеку
    mov ax, [bp+6] ; Перше число у AX
    mov bx, [bp+4] ; Друге число у BX

    cmp ax, bx
    jle end_find_min  ; Якщо AX <= BX, результат вже в AX.

    ; Якщо AX > BX, тоді поміняти значення
    mov ax, bx

end_find_min:
    ; Відновлення регістрів
    pop ax
    pop bx
    mov sp, bp
    pop bp

    ret 4 ; Очистити стек від параметрів
find_min endp

end main
