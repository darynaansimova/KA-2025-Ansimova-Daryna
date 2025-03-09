.model small
.stack 100h
.data
    array dw 12*12 dup(0) ; 12x12 array initialized to zero
.code
main    proc

start:
    mov ax, @data
    mov ds, ax
    
    mov ch, 0 ; Initialize X (row) to 0
    mov cl, 0 ; Initialize Y (column) to 0

myloop:
    push cx
    push bx

    call calculate_y_minus_yx
    
    call store_result

    pop bx
    pop cx

    inc cl ; Move to the next column
    cmp cl, 12 ; Check if we've reached the end of the row
    jne myloop

    mov cl, 0 ; Reset column to 0
    inc ch ; Move to the next row
    cmp ch, 12 ; Check if we've reached the last row
    jne myloop

end_program:
    mov ax, 4c00h
    int 21h
main    endp

; Function to calculate Y - Y * X
calculate_y_minus_yx proc
    xor ah, ah
    mov al, cl ; AL = Y
    mov bl, ch ; BL = X
    imul bl ; AX = Y * X (signed multiplication)
    mov bl, cl ; BL = Y
    xor bh, bh ; BH = 0
    sub bx, ax ; BX = Y - Y * X
    mov ax, bx ; Move result to AX
    ret
calculate_y_minus_yx endp

; Procedure to store the result in the array
store_result proc
    mov ax, 12
    mul ch ; AX = 12 * X

    xor dx, dx
    mov dl, cl
    xor dh, dh

    add ax, dx ; Add the column offset (Y)
    shl ax, 1 ; Multiply by 2 (each element is a word, 2 bytes)
    xchg ax, bx

    mov [array + bx], ax ; Store the result in the array

    ret
store_result endp
end main
