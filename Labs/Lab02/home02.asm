.model small
.stack 100h
.data
    start_number db "123$", 0  ; Initial number in ASCII format, followed by null terminator
    msg db ' $'
.code
main    proc
    mov ax, @data
    mov ds, ax

    ; Ensure start_number contains only valid digits and ends with $
    mov bx, offset start_number

check_loop:
    mov al, [bx]
    cmp al, '$'
    je end_check
    cmp al, '0'
    jb end_program
    cmp al, '9'
    ja end_program
    inc bx
    jmp check_loop

end_check:
    ; Reset BX to start of start_number for printing
    mov bx, offset start_number
    mov cx, 0

; Determine the length of the number
count_digits:
    cmp byte ptr [bx], '$'
    je print_loop
    inc cx
    inc bx
    jmp count_digits

print_loop:
    mov bx, offset start_number
    mov si, cx

print:
    mov dl, [bx]
    cmp dl, '$'
    je decrement_number
    mov ah, 2
    int 21h

    inc bx
    dec si
    jnz print

decrement_number:
    ; Decrement the number from right to left
    mov bx, offset start_number
    add bx, cx
    dec bx

    dec byte ptr [bx]
    cmp byte ptr [bx], '0'
    jge continue_printing

borrow_loop:
    cmp bx, offset start_number
    je end_program

    dec bx
    dec byte ptr [bx]
    mov byte ptr [bx+1], '9'
    cmp byte ptr [bx], '0'
    jl borrow_loop

continue_printing:
    mov dl, ' '
    int 21h
    jmp print_loop

handle_zero:
    jmp end_program

end_program:
    mov ax, 4c00h
    int 21h
main    endp
end main
