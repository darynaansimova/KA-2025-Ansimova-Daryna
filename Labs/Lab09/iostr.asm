.model small
.stack 100h
.data
    strings db 1000h dup(0)       ; Array to store the string
    pointers dw 20 dup(0)         ; Array of pointers
    message db 0Dh, 0Ah, 'Enter a string: $' ; Message with CR and LF
    output_msg db 0Dh, 0Ah, 'Your input: $' ; Message to display after input

.code
main PROC
    ; Display the message
    mov ah, 09h                  ; DOS function to display a string
    lea dx, message              ; Load the address of the message into DX
    int 21h                      ; Call DOS interrupt to print the string

    ; Store the address of 'strings' in the first pointer
    lea ax, strings              ; Load the address of 'strings' into AX
    mov word ptr pointers, ax    ; Store the address in the first element of 'pointers'

    ; Read user input
    lea di, strings              ; Load the address of 'strings' into DI
read_loop:
    mov ah, 01h                  ; DOS function to read a character
    int 21h                      ; Read a character into AL
    mov [di], al                 ; Store the character in the strings array
    cmp al, 0Dh                  ; Check if the character is Carriage Return (Enter key)
    je check_empty_input         ; If yes, check if input is empty
    inc di                       ; Move to the next position in the array
    jmp read_loop                ; Repeat the loop

check_empty_input:
    lea ax, strings              ; Load the address of 'strings' into AX
    cmp di, ax                   ; Compare DI with the address in AX
    je display_output            ; If yes, input is empty, display "Your input: "
    jmp end_input                ; Otherwise, terminate input normally

display_output:
    mov ah, 09h                  ; DOS function to display a string
    lea dx, output_msg           ; Load the address of the output message into DX
    int 21h                      ; Call DOS interrupt to print the message
    jmp terminate_program        ; Skip normal input termination

end_input:
    mov byte ptr [di], '$'       ; Replace 0Dh with '$' to terminate the string

terminate_program:
    ; Terminate the program
    mov ah, 4Ch                  ; DOS function to terminate the program
    int 21h                      ; Exit to DOS
main ENDP
end main