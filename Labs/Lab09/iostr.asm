.model small
.stack 100h
.data
    strings db 1000h dup(0)       ; Array to store the string
    pointers dw 20 dup(0)         ; Array of pointers
    message db 'Enter something:', 0Dh, 0Ah, '$' ; Message with CR and LF
    output_msg db 'Your input:',0Dh, 0Ah, '$' ; Message to display after input

.code
main PROC
    mov ax, @data                ; Initialize data segment
    mov ds, ax                  ; Set DS to point to the data segment
    ;add counter to count the number of lines
    mov si, 0                   ; Initialize line counter to 0
    lea bx, strings           ; Load the address of 'strings' into BX
    ; Loop to read up to 20 lines of input
new_line:    
    ; Display the message
    mov ah, 09h                  ; DOS function to display a string
    lea dx, message              ; Load the address of the message into DX
    int 21h                      ; Call DOS interrupt to print the string

    mov ax, bx                   ; Load the current value of BX (offset in strings) into AX
    mov di, si                    ; Copy si to di
    shl di, 1                     ; Multiply di by 2 (scale for word-sized array)
    mov word ptr pointers[di], ax ; Store the absolute address (offset) in the correct word-sized offset of 'pointers'

    ; Read user input
read_loop:
    mov ah, 01h                  ; DOS function to read a character
    int 21h                      ; Read a character into AL

check_end:
    cmp al, 0Dh                  ; Check if the character is Carriage Return (Enter key)
    jne next                     ; If not, continue reading
    mov byte ptr [bx], '$'       ; Add '$' to terminate the string
    inc bx                   ; Increment DI to point to the next position in the array
    jmp check_empty_input         ; If yes, check if input is empty

next:    
    mov [bx], al                 ; Store the character in the strings array
    inc bx                       ; Move to the next position in the array
    jmp read_loop                ; Repeat the loop

check_empty_input:
    dec bx 
    mov di, si                    ; Copy si to di
    shl di, 1                     ; Multiply di by 2 (scale for word-sized array)
    mov ax, pointers[di]              ; Load the address of 'strings' into AX
    cmp bx, ax                   ; Compare DI with the address in AX
    je display_output            ; If yes, input is empty, display "Your input: "
    inc bx                   ; Increment DI to point to the next position in the array
    ; If input is not empty, increment the line counter
    cmp si, 19                  ; Check if the line counter has reached 20
    je display_output         ; If yes, terminate the program
    inc si                       ; Increment the line counter
    jne new_line              ; If not, continue to the next line

display_output:
    mov ah, 09h                  ; DOS function to display a string
    lea dx, output_msg           ; Load the address of the output message into DX
    int 21h                      ; Call DOS interrupt to print the message

display_input:
    cmp si, 0                   ; Check if the line counter is zero
    jl terminate_program         ; If yes, terminate the program
    ; Display the input string
    mov di, si                    ; Copy si to di
    shl di, 1                     ; Multiply di by 2 (scale for word-sized array)
    mov ah, 09h                  ; DOS function to display a string
    mov dx, pointers[di]           ; Load the address of the input string into DX
    int 21h                      ; Call DOS interrupt to print the message
    dec si
    mov ah, 06h                  ; DOS function to display a character
    mov dl, 0dh           ; Load the address of the CR into DX
    int 21h                 ; Call DOS interrupt to print the CR
    mov ah, 06h                  ; DOS function to display a character
    mov dl, 0ah           ; Load the address of the LF into DX
    int 21h                 ; Call DOS interrupt to print the LF
    jmp display_input         ; Repeat for the next line

terminate_program:
    ; Terminate the program
    mov ah, 4Ch                  ; DOS function to terminate the program
    int 21h                      ; Exit to DOS
main ENDP
end main
