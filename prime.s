; Tasks:
;   request a heap
;   print prime number < 100,000
;   use c call convention

global main

extern printf

NULL equ 0x00
PROT_EXEC equ 0x04
PROT_READ equ 0x01
PROT_WRITE equ 0x2
MAP_ANON equ 0x20
MAP_PRIVATE equ 0x02 ;MALLOC Variables definition


section .data

format: db "%d ", 0x00


TRUE equ 0x1
FALSE equ 0x0

section .text 

main:
    ; initialize stack
    push rbp
    mov rbp, rsp

    ; declare int array_size and 
    ; pointer *array(is null for now)
    sub rsp, 12
    mov dword [rsp + 8], 0x186A0

    ; Request for a heap with a size of 100,000 bytes
    mov rax, 0x09
    mov rdi, 0x00
    mov esi, dword [rsp + 8] ; array size
    mov rdx, PROT_READ
    or rdx, PROT_WRITE
    mov r10, MAP_ANON
    or r10, MAP_PRIVATE
    mov r8, NULL
    mov r9, NULL 
    syscall ;syscall for malloc to allocate memory for initial buffer

    ; a pointer to the heap(or array)
    mov qword [rsp], rax

    ; fill array with 1(true)
    xor rcx, rcx ; clear rcx
    mov rax, qword [rsp] ; array pointer
    .fill_array:
        inc rcx
        mov byte [rax + rcx], TRUE
        cmp ecx, dword [rsp + 8] ; if greater than array size then move on
        jle .fill_array

    ; call function to find prime with 2 arguments
    mov rdi, qword [rsp]
    mov esi, dword [rsp + 8]
    call _sieve_of_eratosthenes

    ; call function to print prime with 2 arg
    mov rdi, qword [rsp]
    mov esi, dword [rsp + 8]
    call _print

    ; delocate local vars and restore stack
    add rsp, 12
    pop rbp
    ; exit(0)
    mov rax, 0
    ret

    _print:
        ; Arguments:
        ; rdi: pointer to prime array
        ; rsi: n

        ; initialize stack
        push rbp
        mov rbp, rsp
        ; 16 bytes for 3 variables: int counter, *array, int n
        sub rsp, 16
        ; might be a bit waste of memory 'cause we can just use 
        ; the variables on main but
        ; then it would not be local variable
        ; and harder to read

        mov dword [rsp], 0x1             ; int counter = 1, will increment to 2 later, 0 and 1 is not considered prime
        mov qword [rsp + 4], rdi         ; *array = pointer to prime array
        mov dword [rsp + 12], esi        ; int n = array size
            .loop_print:
            ; rcx = counter
            mov ecx, dword [rsp]
            inc ecx
            mov dword [rsp], ecx

            ; compare to array size to end function call
            cmp ecx, dword [rsp + 12] 
            jg .end
            
            ; Check if array[counter] is false (not prime number)
            ; if so then go back
            ; r8 is now hold address to array
            mov r8, qword [rsp + 4]
            mov r11b, byte [r8 + rcx]
            cmp r11b, FALSE
            je .loop_print

            mov rdi, format
            mov rsi, rcx
            xor rax, rax ; clear rax before function call to prevent problem
            call printf wrt ..plt
            jmp .loop_print
    .end:
    ; dealocate local variables and restore stack
    add rsp, 16
    pop rbp
    ret

    _sieve_of_eratosthenes:
        ; Arguments:
        ; rdi: pointer to prime array
        ; rsi: n

        ; Initialize registers
        mov rcx, 0x1        ; p = 1, will increment to 2 later, 0 and 1 is not considered prime
        mov r8, rdi         ; r8 = pointer to prime array
        mov r9, rsi         ; r9 = n

        .outer_loop:
            ; p++
            inc rcx

            ; Check if p * p <= n
            mov rax, rcx
            mul rax
            cmp rax, r9
            jg .end_outer_loop   ; Jump if greater

            ; Check if prime[p] is true
            mov r11b, byte [r8 + rcx]; prime[p]
            cmp r11b, FALSE
            je .outer_loop   ; Jump if not prime

            ; Mark multiples of p as false
            mov rdx, rax     ; rdx = i = p * p
            ;movzx r11b, byte [r8 + rcx]
            .inner_loop:
                ; prime[i] = false
                mov byte [r8 + rdx], FALSE

                ; i += p
                add rdx, rcx
                cmp rdx, r9
                jbe .inner_loop

                jmp .outer_loop

        .end_outer_loop:
            ret

